library(jsonlite)

job <- fromJSON(txt = 'job_template.json')

cmd <- job$properties$customToolkitSettings$commandLine

conv1layers <- 32
conv2layers <- 64
denselayers <- 128

cmd

job$properties$customToolkitSettings$commandLine <- sprintf(cmd, conv1layers, conv2layers, denselayers)

job$properties$customToolkitSettings$commandLine

write_json(job, path = 'job_template_tmp.json', pretty = TRUE, auto_unbox = TRUE)
