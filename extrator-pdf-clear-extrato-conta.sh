# CLEAR
# No site da clear, filtrar extrato por periodo, selecionar o resultado em tela, clicar em imprimir com layout paisagem e em opções colocar apenas seleção.
# É necessario imprimir pdf paisagem para listar os valores completos e exportar nome clear-extrato-conta.pdf

# Exemplo chamada: ./extrator-pdf-clear.sh clear-extrato-conta.pdf
# 
#
#

DIR=`pwd`;
TMP_DIR="$DIR/tmp/extrato-conta";
DESCRICAO=`echo $1 | sed s/'clear\-extrato\-conta'//g`;

#extrai para texto
java -jar pdfbox-app-2.0.23.jar ExtractText $1 $TMP_DIR/clear-saida.txt
if [ $? -ne 0 ]; then
  echo "$1 Erro extracao";
  return -1
fi

#extrai apenas os lancamentos localizando registros com data 'DD/MM/YYYY DD/MM/YYYY xxxxxxx R$xxxx'
cat $TMP_DIR/clear-saida.txt | grep -E '^([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9] ([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9].*R\$.*[0-9].*' | sort > $TMP_DIR/clear-saida-lancamentos.txt



#------------ACOES

#extrai ACOES JCP
cat $TMP_DIR/clear-saida-lancamentos.txt | grep -E '(JUROS S\/CAPITAL)' > $TMP_DIR/clear-saida-acoes-jcp.txt
#extrai ACOES JCP para csv formatando 'data;acao;D;quantidade;valor;0;JCP;CLEAR'
cat $TMP_DIR/clear-saida-acoes-jcp.txt | awk -F" " '{print $1,$7,"D",$6,$8,"0;;JCP;CLEAR"}' OFS=';' > $TMP_DIR/clear-saida-acoes-jcp.csv

#extrai ACOES DIVIDENDOS
cat $TMP_DIR/clear-saida-lancamentos.txt | grep -E '(DIVIDENDOS)' > $TMP_DIR/clear-saida-acoes-dividendo.txt
#extrai ACOES DIVIDENDOS para csv formatando 'data;acao;D;quantidade;valor;0;DIVIDENDO;CLEAR'
cat $TMP_DIR/clear-saida-acoes-dividendo.txt | awk -F" " '{print $1,$6,"D",$5,$7,"0;;DIVIDENDO;CLEAR"}' OFS=';' > $TMP_DIR/clear-saida-acoes-dividendo.csv

#agrupa proventos ACOE JCP + DIVIDENDOS ordenado
cat $TMP_DIR/clear-saida-acoes-jcp.csv $TMP_DIR/clear-saida-acoes-dividendo.csv |sort > clear-acoes-proventos$DESCRICAO.csv



#------------FII

#extrai FII
cat $TMP_DIR/clear-saida-lancamentos.txt | grep -E '(RENDIMENTO).*(PAPEL)' > $TMP_DIR/clear-saida-fii-proventos.txt
#extrai FII para csv formatando 'data;acao;D;quantidade;valor;0;CLEAR PROVENTO'
cat $TMP_DIR/clear-saida-fii-proventos.txt | awk -F" " '{print $1,$7,"D",$5,$8,"0;CLEAR PROVENTO"}' OFS=';' > clear-fii-proventos$DESCRICAO.csv



#------------Aluguel BTC