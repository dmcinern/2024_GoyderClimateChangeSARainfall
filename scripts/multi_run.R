rm(list = ls())

replaceStrFile = function(fname,oldStr,newStr){

  x <- readLines(fname)
  x <- gsub(oldStr,newStr,x)
  cat(x, file=fname, sep="\n")
}

args = commandArgs(trailingOnly=TRUE)
templateFile = args[1]
radar = args[2]
year_start = as.integer(args[3])
year_end = as.integer(args[4])

for (year in year_start:year_end){

  for (month in 1:12){

    submitFile = paste0(templateFile,'.',radar,'.',year,'.',month,'.tmp')

    file.copy(from=templateFile,to=submitFile,overwrite=T)

    replaceStrFile(submitFile,'XXX_radar_XXX',radar)
    replaceStrFile(submitFile,'XXX_year_XXX',year)
    replaceStrFile(submitFile,'XXX_month_XXX',month)

    command = paste('sbatch ', submitFile, sep='')
    print(command)
    system(command)
    file.remove(submitFile)

  }

}
