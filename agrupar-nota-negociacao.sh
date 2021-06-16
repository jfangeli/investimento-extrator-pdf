# AGRUPAR
# Agrupa todas as notas de negociacao em apenas um arquivo acoes e fii ordenado

# Exemplo: ./agrupar-nota-negociacao.sh xp,easynvest,clear
# 
#
#   Copyright 2021 Juliano Francisco Angeli
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

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

#limpar;

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

exit 0