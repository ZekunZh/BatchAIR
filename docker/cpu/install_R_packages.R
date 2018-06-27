# Install R packages in docker image

install.packages('reticulate')
reticulate::use_python('/opt/conda/bin/python')

install.packages('devtools')
devtools::install_github('rstudio/keras')

library(keras)
Sys.setenv(TENSORFLOW_PYTHON='/opt/conda/bin/python')

install.packages('argparse')