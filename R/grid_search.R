
library(jsonlite)

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

for (row in 1:nrow(param_grid)) {
  
  conv1filters <- param_grid[row, "conv1filters"]
  conv2filters <- param_grid[row, "conv2filters"]
  denseunits <- param_grid[row, "denseunits"]
  
  cmd <- sprintf(cmd_temp, conv1filters, conv2filters, denseunits)
  
  job <- job_temp
  job$properties$customToolkitSettings$commandLine <- cmd
  write_json(job, path = paste0('jobs/job', row, '.json'), pretty = TRUE, auto_unbox = TRUE)
  
}

job_files <- list.files('jobs')

job_files <- job_files[1]

job_file <- job_files[1]

# create experiment

system("az batchai experiment create -g batchair -w batchairws -n experiment1")

# set off all jobs

run_job <- function(job_file) {
  system2(
    sprintf("az batchai job create -c batchaircluster -n %s -g batchair -w batchairws -e experiment1 -f %s --storage-account-name batchairsa",
            strsplit(job_file, ".", fixed = TRUE)[[1]][1],
            file.path('jobs',job_file)),
    wait = FALSE
  )
}

lapply(job_files, run_job)

# check job statuses every 10 seconds
get_status <- function() {
  status <- fromJSON(
    system2(
      "az batchai job list -o json -g batchair -w batchairws -e experiment1"
    )
  )
}

check_all_finished <- function(status) {
  ifelse(nrow(status[status$State %in% c("succeeded", "failed")] > 0), FALSE, TRUE)
}

finished <- FALSE
while (!finished) {
  status <- get_status()
  finished <- check_all_finished(status)
  Sys.sleep(10)
}

# collect results



