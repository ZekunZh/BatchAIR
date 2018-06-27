
# add mlserver libraries to libPaths (for rstudio on dsvm)
.libPaths(c(.libPaths(), "/data/mlserver/9.2.1/libraries/RServer/"))
.libPaths()

library(keras)
library(argparse)

# Data Preparation -----------------------------------------------------

batch_size <- 128
num_classes <- 10
epochs <- 1

# get filter size param from script arguments
#args = commandArgs(trailingOnly = TRUE)
#filter_size = as.numeric(args[1])
#print(paste('filter_size', filter_size))

parser <- ArgumentParser()
parser$add_argument("--datadir", type="character")
parser$add_argument("--outputdir", type="character")
parser$add_argument("--conv1filters", type="integer", default=32,
                    help="Number of filters in first convolutional layer")
parser$add_argument("--conv2filters", type="integer", default=64,
                    help="Number of filters in second convolutional layer")
parser$add_argument("--denseunits", type="integer", default=128,
                    help="Number of units in dense layer")
args <- parser$parse_args()

print(paste("datadir:", args$datadir))
print(paste("outputdir:", args$outputdir))
print(paste("conv1filters:", args$conv1filters))
print(paste("conv2filters:", args$conv2filters))
print(paste("denseunits:", args$denseunits))

fileConn<-file(file.path(args$outputdir, "results.txt"))
writeLines(c(
  paste("conv1filters:", args$conv1filters),
  paste("conv2filters:", args$conv2filters),
  paste("denseunits:", args$denseunits)
  ), fileConn)
close(fileConn)