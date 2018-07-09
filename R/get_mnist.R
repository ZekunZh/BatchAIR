
# add mlserver libraries to libPaths (for rstudio on dsvm)
.libPaths(c(.libPaths(), "/data/mlserver/9.2.1/libraries/RServer/"))

library(keras)

mnist <- dataset_mnist()

saveRDS(mnist, file = file.path('mnist', 'mnist.rds'))
