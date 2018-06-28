

job_files <- list.files('jobs')

job_files <- job_files[1]

job_file <- job_files[1]

# create experiment
system("az batchai experiment create -g batchair -w batchairws -n experiment1")

run_job <- function(job_file) {
  system(
    sprintf("az batchai job create -c batchaircluster -n %s -g batchair -w batchairws -e experiment1 -f %s --storage-account-name batchairsa",
            strsplit(job_file, ".", fixed = TRUE)[[1]][1],
            file.path('jobs',job_file)),
    wait = FALSE
  )
}

lapply(job_files, run_job)
