# XP
# No site da xp, filtrar extrato por periodo exportar pdf com nome xp-extrato-conta.pdf

# Exemplo: ./extrator-pdf-xp-extrato-conta.sh xp-extrato-conta.pdf
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
DESCRICAO=`echo $1 | sed s/'xp\-extrato\-conta'//g | sed s/'\.pdf'//g`;

#extrai para texto
java -jar pdfbox-app-2.0.23.jar ExtractText $1 $TMP_DIR/xp-saida.txt
if [ $? -ne 0 ]; then
  echo "$1 Erro extracao";
  exit 1
fi

#extrai apenas os lancamentos localizando registros com data 'DD/MM/YYYY DD/MM/YYYY xxxxxxx R$xxxx'
cat $TMP_DIR/xp-saida.txt | grep -E '^([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9] ([0-9][0-9]|0[0-9])\/([0-9][0-9]|0[0-9])\/(20)[0-9][0-9].*R\$[0-9].*' | sort > $TMP_DIR/xp-saida-lancamentos.txt



#------------ACOES

#extrai ACOES JCP
cat $TMP_DIR/xp-saida-lancamentos.txt | grep -E '(JUROS S\/ CAPITAL DE CLIENTE)' > $TMP_DIR/xp-saida-acoes-jcp.txt
#extrai ACOES JCP para csv formatando 'data;acao;D;quantidade;valor;0;JCP;XP'
cat $TMP_DIR/xp-saida-acoes-jcp.txt | sed s/'\* PROV \* '// | sed s/'R\$'// | awk -F" " '{print $1,$8,"D",$10,$11,"0;;JCP;XP"}' OFS=';' > $TMP_DIR/xp-saida-acoes-jcp.csv

#extrai ACOES DIVIDENDOS
cat $TMP_DIR/xp-saida-lancamentos.txt | grep -E '(DIVIDENDOS DE CLIENTE)' > $TMP_DIR/xp-saida-acoes-dividendo.txt
#Tratamento para Rendimentos, nao trata UNIT
cat $TMP_DIR/xp-saida-lancamentos.txt | grep -E '(RENDIMENTOS DE CLIENTE).*([A-Z]{4}(3|4|6))' >> $TMP_DIR/xp-saida-acoes-dividendo.txt
#extrai ACOES DIVIDENDOS para csv formatando 'data;acao;D;quantidade;valor;0;DIVIDENDO;XP'
cat $TMP_DIR/xp-saida-acoes-dividendo.txt | sed s/'\* PROV \* '// | sed s/'R\$'// | awk -F" " '{print $1,$6,"D",$8,$9,"0;;DIVIDENDO;XP"}' OFS=';' > $TMP_DIR/xp-saida-acoes-dividendo.csv

#agrupa proventos ACOE JCP + DIVIDENDOS ordenado
cat $TMP_DIR/xp-saida-acoes-jcp.csv $TMP_DIR/xp-saida-acoes-dividendo.csv |sort > xp-acoes-proventos$DESCRICAO.csv





#------------FII

#extrai FII RENDIMENTOS
cat $TMP_DIR/xp-saida-lancamentos.txt | grep -E '(RENDIMENTOS DE CLIENTE).*([A-Z]{4}(11|12|13|14))' > $TMP_DIR/xp-saida-fii-proventos.txt
#extrai FII para csv formatando 'data;acao;D;quantidade;valor;0;XP PROVENTO'
cat $TMP_DIR/xp-saida-fii-proventos.txt | sed s/'\* PROV \* '// | sed s/'R\$'// | awk -F" " '{print $1,$6,"D",$8,$9,"0;XP PROVENTO"}' OFS=';' > xp-fii-proventos$DESCRICAO.csv



#TODO ------------Subscricao

#TODO ------------Aluguel BTC


exit 0