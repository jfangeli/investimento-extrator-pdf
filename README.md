# investimento-extrator-pdf

Author: Juliano Francisco Angeli - jf.angeli@gmail.com

Licença: Apache License 2.0


Extrator de pdf para csv das corretoras de investimentos.

Permite realizar a extração de:

Corretora | Notas de Negociação | Extrato Conta
--------- | ------------------- | --------------
Clear | SIM | SIM 
XP | TO DO | SIM
Easynvest | TO DO | SIM
Rico | BACKLOG | BACKLOG
Toro | BACKLOG | BACKLOG
    

Agrupa todas os lançamentos das notas de negociações e extrato da conta em apenas um arquivo CSV para ações e FII.


Deverão ser disponibilizados os PDFs no formato:
  
         {corretora}-extrato-conta-{mes}.pdf
         {corretora}-nota-negociacao-{data}.pdf


Os resultados da extrações serão agrupados nos arquivos:
      
         acoes.csv  (negociações + proventos)
         fii.csv    (negociações + proventos)


Exemplo: 

          ./run.sh xp,easynvest,clear  (executa extração)
          ./run.sh limpar              (limpa todos arquivos)

Processamento:
```
run.sh
  -> agrupar-extrato-conta.sh
    -> extrator-pdf-{corretora}-extrato-conta.sh
      -> {corretora}-extrato-conta-{mes}.pdf

  -> agrupar-nota-negociacao.sh
    -> extrator-pdf-{corretora}-nota-negociacao.sh
      -> {corretora}-nota-negociacao-{data}.pdf
```

# Notas
NOTA 1: Deve ser configurado os tickers das ações/fii para notas de negociacoes conforme nome em acoes-ticker.cfg

NOTA 2: Pode ser configurado o formato da extração dos campos (CSV) diretamente nos arquivos extrator-pdf*.sh

# Dependências
Utilizado PDFBox para extração de texto do PDF.

Deve ser baixado o jar do projeto https://pdfbox.apache.org/ na pasta raiz

Testado com versão pdfbox-app-2.0.23
