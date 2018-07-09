# Install R packages in docker image

install.packages('reticulate')
reticulate::use_python('/opt/conda/bin/python')

install.packages('devtools')
devtools::install_github('rstudio/keras', ref = "4ef5e65b5774388509b770ba3b7cd9179cb3286d")

Sys.setenv(TENSORFLOW_PYTHON='/opt/conda/bin/python')

install.packages('argparse')