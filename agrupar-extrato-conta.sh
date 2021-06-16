# AGRUPAR
# Agrupa todas as extracoes do extrato da conta em apenas um arquivo ordenado

# Exemplo: ./agrupar-extrato-conta.sh xp,clear,easynvest
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
  rm -f $DIR/*fii-proventos*.csv;
  rm -f $DIR/*acoes-proventos*.csv;
  rm -f $DIR/tmp/extrato-conta/*.csv;
  rm -f $DIR/tmp/extrato-conta/*.txt;
}

extrair() {
  echo "- $1 Extrato conta";
  
  ARQUIVOS=`ls $1-extrato-conta-*.pdf`;
  if [ $? -ne 0 ]; then
    echo "$1 Arquivos pdf nao encontrados";
  else
    for PDF in $ARQUIVOS
    do
      echo "$PDF";
	  ./extrator-pdf-$i-extrato-conta.sh "$PDF";
      if [ $? -ne 0 ]; then
        echo "$1 Erro extracao";
      else
        echo "$1 OK extracao";
	  fi
    done
  fi
}

agrupar_proventos_acao() {

  ARQUIVOS=`ls $1-acoes-proventos-*.csv`;
  if [ $? -ne 0 ]; then
    echo "$1 Sem proventos acoes";
  else
    for CSV in $ARQUIVOS
    do
	  echo "$1 Agrupando proventos acoes: $CSV";
	  cat $CSV >> acoes-proventos.csv;
	  cat acoes-proventos.csv | sort > acoes-proventos.csv;
    done
  fi
}

agrupar_proventos_fii() {
  
  ARQUIVOS=`ls $1-fii-proventos-*.csv`;
  if [ $? -ne 0 ]; then
    echo "$1 Sem proventos fii";
  else
    for CSV in $ARQUIVOS
    do
	  echo "$1 Agrupando proventos fii: $CSV";
	  cat $CSV >> fii-proventos.csv;
	  cat fii-proventos.csv | sort > fii-proventos.csv;
    done
  fi
}

#limpar;

IFS=',' read -r -a ARRAY <<< "$CORRETORAS";
for i in "${ARRAY[@]}"; do
  case $i in
    'xp'|'clear'|'easynvest') 	   
	   extrair $i;
	   agrupar_proventos_acao $i;
	   agrupar_proventos_fii $i;
	   ;;
	'limpar') 	   
	   limpar;
	   ;;
    *) echo "$i nao suportada, digite xp,clear,easynvest"  
	  ;;
  esac
done

exit 0