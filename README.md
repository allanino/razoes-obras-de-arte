# Razões em obras de arte

Aqui investigamos a razão entre as dimensões de telas de diversos artistas.

Conforme observado pelo professor [José Antônio Salvador](http://www.dm.ufscar.br/profs/salvador/),
as médias dessas razões para diferentes artistas, em geral, não parecem se aproximar da reverenciada
[razão áurea](http://www.wikiwand.com/en/Golden_ratio), sendo talvez melhor estimadas pelo
[número plástico](https://www.wikiwand.com/en/Plastic_number).

Utilizamos nesse estudo empírico uma [base de dados online](http://www.wga.hu/frames-e.html?/database/download/)
consistindo de um arquivo no formato `xls` que pode ser aberto em qualquer software
que trabalhe com planilhas, como LibreOffice Calc ou Excel. Optamos por utilizar
o software [R](https://www.r-project.org/) para a análise dos dados, juntamente
com o [RStudio](https://www.rstudio.com/) para simplificar o uso do R Markdown.

Seguimos o seguinte roteiro simplificado:

1. Pré-processamos os dados e excluímos obras que não possuem informação sobre suas dimensões ou que apresentam tais informações corrompidas.
2. Extraímos as duas dimensões das obras (largura e altura).
3. Calculamos a razão entre as dimensões, sempre considerando a divisão da maior dimensão pela menor.
4. Ignoramos obras com razões maiores que 4.0, uma vez que constatamos que a maioria das obras nessas condições apresentam inconsistências em seus dados, tais como espaços extras que dificultam a extração das dimensões.
5. Calculamos histogramas das razões para facilitar a visualização.

O código fonte com os scripts utilizados para o processsamento dos dados e a criação dessa página está disponível [nesse repositório](https://github.com/allanino/razoes-obras-de-arte).
