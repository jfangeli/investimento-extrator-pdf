# CLEAR
# Exportar nota de negociacao
# 

# Exemplo chamada: ./extrator-pdf-clear-nota-negociacao.sh clear-nota-negociacao.pdf
# 
#
#

DIR=`pwd`;
TMP_DIR="$DIR/tmp/nota-negociacao";

#extrai para texto
java -jar pdfbox-app-2.0.23.jar ExtractText $1 $TMP_DIR/clear-saida-nota-negociacao.txt
if [ $? -ne 0 ]; then
  echo "$1 Erro extracao";
  exit 1
fi

#extrai apenas as negociacoes localizando registros
cat $TMP_DIR/clear-saida-nota-negociacao.txt | grep -E '^(1-BOVESPA).*(D|C)' > $TMP_DIR/clear-saida-nota-negociacao-lancamentos.txt

#extrai data do pregao
DATA_PREGAO=`cat $TMP_DIR/clear-saida-nota-negociacao.txt |grep -E 'Data pregão' -A1 | grep -E '^([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9]'`;
DATA_PREGAO_=`echo $DATA_PREGAO | sed 's/\//\-/g'`;
echo $DATA_PREGAO;

#extrai valor das taxas e impostos
VLR_LIQUIDO=`cat $TMP_DIR/clear-saida-nota-negociacao.txt| grep -E '(Líquido para).([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9]' | cut -d'L' -f1 | sed 's/\.\|\,//g'`;
#echo $VLR_LIQUIDO;
VLR_OPERACOES=`cat $TMP_DIR/clear-saida-nota-negociacao.txt| grep -E 'Valor líquido das operações' | cut -d'V' -f1 | sed 's/\.\|\,//g'`;
#echo $VLR_OPERACOES;
VLR_TAXA_IMPOSTO=`echo $(($VLR_LIQUIDO - $VLR_OPERACOES)) | awk '{printf "%.2f", ($1 / 100)}' | sed 's/\./\,/g'`;
#echo $VLR_TAXA_IMPOSTO;

#------------ACOES

encontrar_ticket_acao() {
  #$1 nome acoes
  #$2 tipo acao ON, PN...
  ACAO=`echo "^$1$2\=" | sed s/' '//g`;
  #echo $ACAO;
  TICKER=`cat acoes-ticker.cfg | sed s/' '//g | grep "$ACAO" | awk -F"=" '{print $2}'`;
  if [ -n "$TICKER" ]; then
    echo $TICKER;
  else
    echo "$1 $2";
  fi
}

#extrai ACOES
cat $TMP_DIR/clear-saida-nota-negociacao-lancamentos.txt | grep -vE '(FII).*11' > $TMP_DIR/clear-saida-acoes-nota-negociacao-$DATA_PREGAO_.txt

#extrai ACOES para csv formatando 'data;acao;C/V;quantidade;valor;taxa;Acões Dividendos;;CLEAR'
cat /dev/null > clear-acoes-nota-negociacao-$DATA_PREGAO_.csv;
while read LINHA; 
do
  
  #echo $LINHA;
  ACAO=`echo $LINHA | awk -F"C FRACIONARIO|C VISTA|V FRACIONARIO|V VISTA" '{print $2}' | awk -F"PN.*N1|PN.*N2|ON NM|PNB.*N1|UNT.*N2" '{print $1}'`;
  TIPO=`echo $LINHA | awk -F"$ACAO" '{print $2}' | awk -F" " '{print $1}'`;
  TICKER=$( encontrar_ticket_acao "$ACAO" $TIPO );
  echo $TICKER;
  #compra ou venda
  CV=`echo $LINHA | awk -F" " '{print $2}'`;
  QTD_VALOR=`echo $LINHA | awk '{ for(i=length;i!=0;i--) x=(x substr($0,i,1))}{print x;x=""}' | awk -F" " '{print $3,$4}' OFS=';'| awk '{ for(i=length;i!=0;i--) x=(x substr($0,i,1))}{print x;x=""}'`;
  REGISTRO="$DATA_PREGAO;$TICKER;$CV;$QTD_VALOR;$VLR_TAXA_IMPOSTO;Ações Dividendos;;CLEAR";
  #echo $REGISTRO;
  echo $REGISTRO >> clear-acoes-nota-negociacao-$DATA_PREGAO_.csv;
  
done < $TMP_DIR/clear-saida-acoes-nota-negociacao-$DATA_PREGAO_.txt



#------------FII

#extrai FII
cat $TMP_DIR/clear-saida-nota-negociacao-lancamentos.txt | grep -E '(FII).*11' > $TMP_DIR/clear-saida-fii-nota-negociacao-$DATA_PREGAO_.txt

#extrai FII para csv formatando 'data;acao;C/V;quantidade;valor;taxa;CLEAR'
cat /dev/null > clear-fii-nota-negociacao-$DATA_PREGAO_.csv;
while read LINHA;
do
  
  #echo $LINHA;
  TICKER=`echo $LINHA | grep -o ' ....11 ' | sed s/' '//g`;
  echo $TICKER;
  #compra ou venda
  CV=`echo $LINHA | awk -F" " '{print $2}'`;
  QTD_VALOR=`echo $LINHA | awk '{ for(i=length;i!=0;i--) x=(x substr($0,i,1))}{print x;x=""}' | awk -F" " '{print $3,$4}' OFS=';'| awk '{ for(i=length;i!=0;i--) x=(x substr($0,i,1))}{print x;x=""}'`;
  REGISTRO="$DATA_PREGAO;$TICKER;$CV;$QTD_VALOR;$VLR_TAXA_IMPOSTO;CLEAR";
  #echo $REGISTRO;
  echo $REGISTRO >> clear-fii-nota-negociacao-$DATA_PREGAO_.csv;
  
done < $TMP_DIR/clear-saida-fii-nota-negociacao-$DATA_PREGAO_.txt

exit 0