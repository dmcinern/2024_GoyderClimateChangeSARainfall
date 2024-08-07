rm(list=ls())

library(lubridate)
library(tidyverse)


dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/'

data_dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/tmp/pluvio/'
code_dirname = paste0(dirname,'scripts/')
RData_dirname = paste0(dirname,'RData/')


site = '23034' # Adelaide airport
#site = '023090' # Adelaide Kent Town
#site = '023083' # Edinburgh RAAF

load_RData = T

RData_fname = paste0(RData_dirname,'pluvio_',site,'.RData')

if (load_RData){

  load(RData_fname)

} else {

#  fname = paste0(data_dirname,'HD01D_Data_',site,'_9999999910567562.txt')

#  fname = paste0(data_dirname,'HD01D_Data_',site,'_9999999910567562.txt')

#  fname = paste0('outputFor',site,'_9999999910567597.txt')

#  fname = paste0('C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/tmp/pluvio/','outputFor',site,'_9999999910567597.txt')

#  fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/tmp/pluvio/outputFor23034_9999999910567597.txt'

  fname = paste0('C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/tmp/pluvio/outputFor',site,'_9999999910567597.txt')

  d = read.fwf(fname,widths=c(12,4,2,2,rep(7,240)),skip=2)

  NperDay = 24*10

  Yr = d[,2]
  Mon = d[,3]
  Day = d[,4]

  date.MUSIC = as.Date(paste0(Yr,'/',Mon,'/',Day))

  nTime.MUSIC = length(Yr)

  P.MUSIC = as.matrix(d[,5:dim(d)[2]])

  save.image(RData_fname)

}

  # first.date = date.MUSIC[1]
  # last.date = date.MUSIC[length(date.MUSIC)]
  #
  # first.time = as.POSIXct(paste0(Yr[1],'/',Mon[1],'/',Day[1],' 00:00'),tz='GMT')
  # last.time = as.POSIXct(paste0(Yr[nTime.MUSIC],'/',Mon[nTime.MUSIC],'/',Day[nTime.MUSIC],' 23:54'),tz='GMT')

  # first.time = as.POSIXct("2002/01/01 00:00",tz='GMT')
  # last.time = as.POSIXct("2002/12/31 23:59",tz='GMT')

  year.min = 1968
  year.max = 2015

  first.time = as.POSIXct(paste0(year.min,"/01/01 00:00"),tz='GMT')
  last.time = as.POSIXct(paste0(year.max,"/12/31 23:59"),tz='GMT')

  first.date = as.Date(first.time)
  last.date = as.Date(last.time)


  date.all = seq(first.date,last.date,by='days')

  keep = which((date.MUSIC>=first.date)&(date.MUSIC<=last.date))

  P.all = matrix(nrow = length(date.all),ncol=NperDay,data = 0)

  wetDayIndex = which(date.all%in%date.MUSIC)

  P.all[wetDayIndex,] = P.MUSIC[keep,]

  P.vec = as.vector(t(P.all))

  times.all = seq(first.time,last.time,by='6 min')

  N = length(times.all)

  P = P.vec
  P[P<0.] = NA

  quantile(P,probs=c(0.99,0.999),na.rm=T)

  probs = c(0.99,0.999)
  year_vec = year.min:year.max
  metrics = matrix(nrow=length(year.min:year.max),ncol=length(probs))
  year.all = as.integer(format(times.all,'%Y'))
  for(y in 1:length(year_vec)){
    print(y)
    i = which(year.all==year_vec[y])
    metrics[y,] = quantile(P[i],probs=probs,na.rm=T)
    print(metrics[y,])
  }

  # plot(year_vec,metrics[,1])
  # plot(year_vec,metrics[,2],col='red')

  plot(year_vec,metrics[,1],ylim=c(0,20),type = 'l',col='blue')
  lines(year_vec,metrics[,2],col='red')

