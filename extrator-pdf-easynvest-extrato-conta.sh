# EASYNVEST
# No site da easynvest, filtrar extrato por periodo exportar pdf com nome xp-extrato-conta.pdf

# Exemplo chamada: ./extrator-pdf-easynvest.sh easynvest-extrato-conta.pdf
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
TMP_DIR="$DIR/tmp/extrato-conta";
DESCRICAO=`echo $1 | sed s/'easynvest\-extrato\-conta'//g | sed s/'\.pdf'//g`;

#extrai para texto
java -jar pdfbox-app-2.0.23.jar ExtractText $1 $TMP_DIR/easynvest-saida.txt
if [ $? -ne 0 ]; then
  echo "$1 Erro extracao";
  exit 1
fi

#extrai apenas os lancamentos localizando registros com data 'DD/MM/YYYY DD/MM/YYYY xxxxxxx R$xxxx'
cat $TMP_DIR/easynvest-saida.txt | grep -E '^([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9] ([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9].*R\$.*[0-9].*' | sort > $TMP_DIR/easynvest-saida-lancamentos.txt



#------------ACOES

#extrai ACOES JCP e ajusta nomes das acoes
cat $TMP_DIR/easynvest-saida-lancamentos.txt | grep -E '(JUROS S\/ CAPITAL)' | sed s/'BRBRSRACNPB4'/'BRSR6'/ | sed s/'BRBBASACNOR3'/'BBAS3'/ | sed s/'BRITSAACNPR7'/'ITSA4'/ | sed s/'BRTIETCDAM15'/'AESB3'/ | sed s/'BRTAEECDAM10'/'TAEE11'/ > $TMP_DIR/easynvest-saida-acoes-jcp.txt
#extrai ACOES JCP para csv formatando 'data;acao;D;quantidade;valor;0;JCP;EASYNVEST'
cat $TMP_DIR/easynvest-saida-acoes-jcp.txt | awk -F" " '{print $1,$8,"D",$7,$10,"0;;JCP;EASYNVEST"}' OFS=';' > $TMP_DIR/easynvest-saida-acoes-jcp.csv



#extrai ACOES DIVIDENDOS
cat $TMP_DIR/easynvest-saida-lancamentos.txt | grep -E '(DIVIDENDOS)' > $TMP_DIR/easynvest-saida-acoes-dividendo.txt
#extrai ACOES DIVIDENDOS para csv formatando 'data;acao;D;quantidade;valor;0;DIVIDENDO;EASYNVEST'
cat $TMP_DIR/easynvest-saida-acoes-dividendo.txt | awk -F" " '{print $1,$7,"D",$5,$9,"0;;DIVIDENDO;EASYNVEST"}' OFS=';' > $TMP_DIR/easynvest-saida-acoes-dividendo.csv

#agrupa proventos ACOE JCP + DIVIDENDOS ordenado
cat $TMP_DIR/easynvest-saida-acoes-jcp.csv $TMP_DIR/easynvest-saida-acoes-dividendo.csv |sort > easynvest-acoes-proventos$DESCRICAO.csv



#------------FII

#extrai FII
cat $TMP_DIR/easynvest-saida-lancamentos.txt | grep -E '(RENDIMENTO S\/).*(ACOES)' > $TMP_DIR/easynvest-saida-fii-proventos.txt
#extrai FII para csv formatando 'data;acao;D;quantidade;valor;0;EASYNVEST PROVENTO'
cat $TMP_DIR/easynvest-saida-fii-proventos.txt | awk -F" " '{print $1,$7,"D",$5,$11,"0;EASYNVEST PROVENTO"}' OFS=';' > easynvest-fii-proventos$DESCRICAO.csv



#TODO ------------Subscricao

#TODO ------------Aluguel BTC


exit 0