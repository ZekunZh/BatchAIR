
# add mlserver libraries to libPaths (for rstudio on dsvm)
#.libPaths(c(.libPaths(), "/data/mlserver/9.2.1/libraries/RServer/"))
#.libPaths()

library(keras)
library(argparse)

# Data Preparation -----------------------------------------------------

batch_size <- 128
num_classes <- 10
epochs <- 1


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

# Input image dimensions
img_rows <- 28
img_cols <- 28

# The data, shuffled and split between train and test sets
#mnist <- dataset_mnist()
mnist <- readRDS(file.path(args$datadir, "mnist.rds"))
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

# Redefine  dimension of train/test inputs
x_train <- array_reshape(x_train, c(nrow(x_train), img_rows, img_cols, 1))
x_test <- array_reshape(x_test, c(nrow(x_test), img_rows, img_cols, 1))
input_shape <- c(img_rows, img_cols, 1)

# Transform RGB values into [0,1] range
x_train <- x_train / 255
x_test <- x_test / 255

cat('x_train_shape:', dim(x_train), '\n')
cat(nrow(x_train), 'train samples\n')
cat(nrow(x_test), 'test samples\n')

# Convert class vectors to binary class matrices
y_train <- to_categorical(y_train, num_classes)
y_test <- to_categorical(y_test, num_classes)

# Define Model -----------------------------------------------------------

# Define model
model <- keras_model_sequential() %>%
  layer_conv_2d(filters = args$conv1filters, kernel_size = c(3,3), activation = 'relu',
                input_shape = input_shape) %>% 
  layer_conv_2d(filters = args$conv2filters, kernel_size = c(3,3), activation = 'relu') %>% 
  layer_max_pooling_2d(pool_size = c(2, 2)) %>% 
  layer_dropout(rate = 0.25) %>% 
  layer_flatten() %>% 
  layer_dense(units = args$denseunits, activation = 'relu') %>% 
  layer_dropout(rate = 0.5) %>% 
  layer_dense(units = num_classes, activation = 'softmax')

# Compile model
model %>% compile(
  loss = loss_categorical_crossentropy,
  optimizer = optimizer_adadelta(),
  metrics = c('accuracy')
)

# Train model
model %>% fit(
  x_train, y_train,
  batch_size = batch_size,
  epochs = epochs,
  validation_split = 0.2
)




scores <- model %>% evaluate(
  x_test, y_test, verbose = 0
)

# Output metrics
cat('Test loss:', scores[[1]], '\n')
cat('Test accuracy:', scores[[2]], '\n')

fileConn<-file(file.path(args$outputdir, "results.txt"))
writeLines(c(
  paste("conv1filters:", args$conv1filters),
  paste("conv2filters:", args$conv2filters),
  paste("denseunits:", args$denseunits),
  "============",
  "   ",
  paste("Test accuracy:", scores[[2]])
), fileConn)
close(fileConn)