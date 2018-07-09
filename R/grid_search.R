
# Execute from BatchAIR directory

# Set resource names (if running interactively)
workspace <- "batchairws"
cluster <- "batchaircluster"
experiment <- ""
resourcegroup <- "batchair"
storageaccount <- "batchairsa"
gpu <- TRUE

# add libraries path for running in R studio on Microsoft Data Science Virtual Machine
.libPaths(c(.libPaths(), "/data/mlserver/9.2.1/libraries/RServer/"))

library(jsonlite)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("--w", type="character",
                    help='Batch AI workspace name')
parser$add_argument("--c", type="character",
                    help='Batch AI cluster name')
parser$add_argument("--e", type="character",
                    help='Batch AI experiment name')
parser$add_argument("--g", type="character",
                    help='resource group name')
parser$add_argument("--s", type="character",
                    help="storage account name")
parser$add_argument("--gpu", type="logical", default=TRUE,
                    help="use gpu image or not")

args <- parser$parse_args()

if (!interactive()) {
  workspace <- args$w
  cluster <- args$c
  experiment <- args$e
  resourcegroup <- args$g
  storageaccount <- args$s
  gpu <- args$gpu
}

# read job template file
job_temp <- fromJSON(txt = 'job_template.json')

# define parameter grid
conv1filters_choice <- c(32, 64, 128)
conv2filters_choice <- c(32, 64, 128)
denseunits_choice <- c(128)

param_grid <- expand.grid(conv1filters_choice,
                          conv2filters_choice,
                          denseunits_choice)
colnames(param_grid) <- c("conv1filters", "conv2filters", "denseunits")

# get training script execution command from template
cmd_temp <- job_temp$properties$customToolkitSettings$commandLine

# get docker image from template
img_temp <- job_temp$properties$containerSettings$imageSourceRegistry$image

# create job configuration files (one per hyperparameter set)
for (row in 1:nrow(param_grid)) {
  
  conv1filters <- param_grid[row, "conv1filters"]
  conv2filters <- param_grid[row, "conv2filters"]
  denseunits <- param_grid[row, "denseunits"]
  
  cmd <- sprintf(cmd_temp, conv1filters, conv2filters, denseunits)
  docker_img <- ifelse(gpu, "angusrtaylor/kerasr-gpu", "angusrtaylor/kerasr")
  
  job <- job_temp
  job$properties$customToolkitSettings$commandLine <- cmd
  job$properties$containerSettings$imageSourceRegistry$image <- docker_img
  write_json(job, path = file.path('jobs', paste0('job', row, '.json')), pretty = TRUE, auto_unbox = TRUE)
  
}


# create experiment

system(
  sprintf("az batchai experiment create -g %s -w %s -n %s", 
          resourcegroup,
          workspace,
          experiment)
)

# upload model training script
print('uploading training script to file share')
system(
  sprintf("az storage file upload -s resources --source R/mnist_cnn.R --path R --account-name %s",
          storageaccount)
)

# set off all jobs

run_job <- function(job_file) {
  system(
    sprintf("az batchai job create -c %s -n %s -g %s -w %s -e %s -f %s --storage-account-name %s",
            cluster,
            strsplit(job_file, ".", fixed = TRUE)[[1]][1],
            resourcegroup,
            workspace,
            experiment,
            file.path('jobs', job_file),
            storageaccount),
    wait = FALSE,
    ignore.stdout = TRUE
  )
}

job_files <- list.files('jobs')
lapply(job_files, run_job)

# check job statuses every 10 seconds
get_status <- function() {
  status <- fromJSON(
    system(
      sprintf(
        "az batchai job list -o json -g %s -w %s -e %s",
        resourcegroup,
        workspace,
        experiment
      ),
      intern = TRUE
    )
  )
  status <- data.frame(
    name = status$name,
    executionState = status$executionState
  )
  status <- status[order(status$name), ]
  status
}

check_all_finished <- function(status) {
  ifelse(nrow(status[!(status$executionState %in% c("failed", "succeeded")), ]), FALSE, TRUE)
}

# wait a few seconds while jobs are triggered
Sys.sleep(10)

# check status of jobs every 10 seconds
finished <- FALSE
while (!finished) {
  status <- get_status()
  print(status)
  cat("\n\n")
  finished <- check_all_finished(status)
  Sys.sleep(10)
}

print(status)
cat("\n\n")
print("All jobs finished")

# collect results

get_result <- function(job_file) {
  job <- strsplit(job_file, ".", fixed = TRUE)[[1]][1]
  result <- fromJSON(
    system(
      sprintf("az batchai job file stream -e %s -j %s -g %s -w %s -d ALL --file-name output.json",
              experiment,
              job,
              resourcegroup,
              workspace
      ),
      intern = TRUE
    )
  )
  result$job <- job
  result
}

results <- lapply(job_files, get_result)
results <- do.call("rbind", results)

print(results)
