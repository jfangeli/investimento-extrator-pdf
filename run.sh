# RUN
#Author: Juliano Francisco Angeli 
#Contato: jf.angeli@gmail.com
#Licença: Apache License 2.0
#
#Extrator de pdf para csv das corretoras de investimentos.
#Permite realizar a extração de:
#
#                    Clear  XP  Easynvest  Rico  Toro
#Notas de Negociação  SIM   NAO   NAO       NAO   NAO
#Extrato Conta        SIM   SIM   SIM       NAO   NAO
#    
#    
#Agrupa todas os lançamentos das notas de negociações e extrato da conta em apenas um arquivo CSV para ações e FII.
#
#
#Deverão ser disponibilizados os PDFs no formato:
#  {corretora}-extrato-conta-{mes}.pdf
#  {corretora}-nota-negociacao-{data}.pdf
#
#
#Os resultados da extrações serão agrupados nos arquivos:
#  acoes.csv  (negociações + proventos)
#  fii.csv    (negociações + proventos)
#
#
#Exemplo: ./run.sh xp,easynvest,clear  (executa extração)
#         ./run.sh limpar              (limpa todos arquivos)
#
#Processamento:
#run.sh
#  -> agrupar-extrato-conta.sh   
#    -> extrator-pdf-{corretora}-extrato-conta.sh
#      -> {corretora}-extrato-conta-{mes}.pdf
#
#  -> agrupar-nota-negociacao.sh
#    -> extrator-pdf-{corretora}-nota-negociacao.sh
#      -> {corretora}-nota-negociacao-{data}.pdf
#
#
## Notas
#NOTA 1: Deve ser configurado os tickers das ações/fii para notas de negociacoes conforme nome em acoes-ticker.cfg
#NOTA 2: Pode ser configurado o formato da extração dos campos (CSV) diretamente nos arquivos extrator-pdf*.sh
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
  rm -f $DIR/acoes.csv;
  rm -f $DIR/fii.csv;
  
  ./agrupar-nota-negociacao.sh $1;
  ./agrupar-extrato-conta.sh $1;
}

limpar_todos() {
  rm -f $DIR/*.pdf;
  limpar $1;
}

extrair() {
   echo ">>> $1 Iniciado";
  
  ./agrupar-nota-negociacao.sh $1;
  
  ./agrupar-extrato-conta.sh $1;
}

agrupar_acao() {

   if [ -e 'acoes-nota-negociacao.csv' ]; then
     cat acoes-nota-negociacao.csv >> acoes.csv;
   fi
   
   if [ -e 'acoes-proventos.csv' ]; then
     cat acoes-proventos.csv >> acoes.csv;
   fi
   
   if [ -e 'acoes.csv' ]; then
     cat acoes.csv | sort > acoes.csv;
   fi
}

agrupar_fii() {
  
  if [ -e 'fii-nota-negociacao.csv' ]; then
     cat fii-nota-negociacao.csv >> fii.csv;
  fi
   
  if [ -e 'fii-proventos.csv' ]; then
     cat fii-proventos.csv >> fii.csv;
  fi
   
  if [ -e 'fii.csv' ]; then
     cat fii.csv | sort > fii.csv;
  fi
}

limpar 'limpar';

IFS=',' read -r -a ARRAY <<< "$CORRETORAS";
for i in "${ARRAY[@]}"; do
  case $i in
    'xp'|'clear'|'easynvest') 	   
	   extrair $i;  
	   ;;
	'limpar') 
       limpar_todos $i;	
	   echo 'Arquivos limpos';
	   exit 0
	   ;;
    *) echo "$i nao suportada, digite xp,clear,easynvest";
	   exit 1
	  ;;
  esac
done

agrupar_acao;
agrupar_fii;

exit 0