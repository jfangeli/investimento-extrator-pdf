# AGRUPAR
# Agrupa todas as notas de negociacao em apenas um arquivo acoes e fii ordenado

# Exemplo: ./agrupar-nota-negociacao.sh xp,easynvest,clear
# 
#
#

DIR=`pwd`;
CORRETORAS=$1;

limpar() {
  rm -f $DIR/*nota-negociacao*.csv;
  rm -f $DIR/tmp/nota-negociacao/*.csv;
  rm -f $DIR/tmp/nota-negociacao/*.txt;
}

extrair() {
  echo "- $1 Notas negociacao";
  
  ARQUIVOS=`ls $1-nota-negociacao-*.pdf`;
  if [ $? -ne 0 ]; then
    echo "$1 Arquivos pdf nao encontrados";
  else
    for PDF in $ARQUIVOS
    do
      echo "$PDF";
	  ./extrator-pdf-$i-nota-negociacao.sh "$PDF";
      if [ $? -ne 0 ]; then
        echo "$1 Erro extracao";
      else
        echo "$1 OK extracao";
	  fi
    done
  fi
}

agrupar_negociacoes_acao() {

  ARQUIVOS=`ls $1-acoes-nota-negociacao-*.csv`;
  if [ $? -ne 0 ]; then
    echo "$1 Sem notas negociacoes acoes";
  else
    for CSV in $ARQUIVOS
    do
	  echo "$1 Agrupando notas negociacoes acoes: $CSV";
	  cat $CSV >> acoes-nota-negociacao.csv;
	  cat acoes-nota-negociacao.csv | sort > acoes-nota-negociacao.csv;
    done
  fi
}

agrupar_negociacoes_fii() {
  
  ARQUIVOS=`ls $1-fii-nota-negociacao-*.csv`;
  if [ $? -ne 0 ]; then
    echo "$1 Sem notas negociacoes fii";
  else
    for CSV in $ARQUIVOS
    do
	  echo "$1 Agrupando notas negociacoes fii: $CSV";
	  cat $CSV >> fii-nota-negociacao.csv;
	  cat fii-nota-negociacao.csv | sort > fii-nota-negociacao.csv;
    done
  fi
}

limpar;

IFS=',' read -r -a ARRAY <<< "$CORRETORAS";
for i in "${ARRAY[@]}"; do
  case $i in
    'xp'|'clear'|'easynvest') 	   
	   extrair $i;
	   agrupar_negociacoes_acao $i;
	   agrupar_negociacoes_fii $i;
	   ;;
	'limpar') 	   
	   limpar;
	   ;;
    *) echo "$i nao suportada, digite xp,clear,easynvest"  
	  ;;
  esac
done