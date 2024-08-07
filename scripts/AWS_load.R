rm(list=ls())

# library(lubridate)
# library(tidyverse)
#
#
# dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/'
#
# data_dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/tmp/aws/'
# code_dirname = paste0(dirname,'scripts/')
# RData_dirname = paste0(dirname,'RData/')
#

site = '023034' # Adelaide airport
#site = '023090' # Adelaide Kent Town
#site = '023083' # Edinburgh RAAF

load_RData = T

RData_fname = paste0(RData_dirname,'AWS_',site,'.RData')

if (load_RData){

  load(RData_fname)

} else {

  fname = paste0(data_dirname,'HD01D_Data_',site,'_9999999910567562.txt')

  d = as.matrix(data.table::fread(fname,nrows = 1))

  Yr = as.matrix(data.table::fread(fname,select=3)[,1])
  Mon = as.matrix(data.table::fread(fname,select=4)[,1])
  Day = as.matrix(data.table::fread(fname,select=5)[,1])
  Hr = as.matrix(data.table::fread(fname,select=6)[,1])
  Min = as.matrix(data.table::fread(fname,select=7)[,1])

  date = as.POSIXct(paste0(Yr,'/',Mon,'/',Day,' ',Hr,':',Min),format ='%Y/%m/%d %H:%M',tz='GMT')

  Precipitation.since.last.AWS.observation.in.mm = as.matrix(data.table::fread(fname,select=13)[,1])

  Quality.of.precipitation.since.last.AWS.observation.value = as.matrix(data.table::fread(fname,select=14)[,1])

  Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes = as.matrix(data.table::fread(fname,select=15)[,1])

  save.image(RData_fname)

}

#################

# P = Precipitation.since.last.AWS.observation.in.mm
# P.real = P[!is.na(P)]
# period = Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes
# P.after.missing = P[(period>0)&(!is.na(period))]
#
# P.after.missing[P.after.missing>1]
#
# # j=which(Precipitation.since.last.AWS.observation.in.mm==max(Precipitation.since.last.AWS.observation.in.mm,na.rm=T))
# # Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes[j]
#
#
# Precipitation.since.last.AWS.observation.in.mm[!is.na(Precipitation.since.last.AWS.observation.in.mm)]
#
# N = length(Precipitation.since.last.AWS.observation.in.mm)
#
# missing = which(Quality.of.precipitation.since.last.AWS.observation.value!='Y')
#
# plot(ecdf(missing))

#######################

P = Precipitation.since.last.AWS.observation.in.mm

# remove any data that does not pass quality check
P[Quality.of.precipitation.since.last.AWS.observation.value!='Y'] = NA

# remove any data collected over more than 1 time step
P[Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes>1] = NA

#######################


year.min = 2002
year.max = 2023

#keep = which( (Yr>=year.min) &  (Yr<=year.max))

# date.min = as.POSIXct("2002/01/01 00:00")
# date.max = as.POSIXct("2002/12/31 23:59")

date.min = as.POSIXct(paste0(year.min,"/01/01 00:00"),tz='GMT')
date.max = as.POSIXct(paste0(year.max,"/12/31 23:59"),tz='GMT')

#aggPeriod = 6
aggPeriod = 30

keep = which((date>=date.min)&(date<=date.max))

# date = as.POSIXct(paste0(Yr[keep],'/',Mon[keep],'/',Day[keep],' ',Hr[keep],':',Min[keep]),format ='%Y/%m/%d %H:%M')

date1 = date[keep]
P1 = P[keep]

d1 <- data.frame(date1,P1)

#timePeriod = seq(from=as.POSIXct(paste0(year.min,"/01/01 00:00")),
#    to=as.POSIXct(paste0(year.max,"/01/01 01:59")),
#    by="3 min")

# timePeriod = seq(from=date.min,
#                  to=date.max,
#                  by="30 min")

timePeriod = seq(from=date.min,
                 to=date.max,
                 by=paste0(aggPeriod,' min',sep=''))

# dp = timePeriod[2:length(timePeriod)] - timePeriod[1:(length(timePeriod)-1)]
#
# min(dp)
# max(dp)

##########

# fd = floor_date(date[keep], paste0(aggPeriod,'minutes'))
#
# dfd = fd[2:length(fd)] - fd[1:(length(fd)-1)]
#
# min(dfd)
# max(dfd)
#
# date.min = as.POSIXct("2002/03/31 00:00",tz='GMT')
# date.max = as.POSIXct("2002/03/31 03:00",tz='GMT')
#
# date = seq(date.min,date.max,by='1 min')
#
# floor_date(date, '6 minutes')

##########


# make complete time sequence
d2 <- data.frame(timePeriod = timePeriod)

# d3 = d1 %>%
#  mutate(timePeriod = floor_date(date[keep], "30minutes")) %>%
#  group_by(timePeriod) %>%
#  summarise(sum = sum(P1)) %>%
#  right_join(d2)

d3 = d1 %>%
  mutate(timePeriod = floor_date(date1, paste0(aggPeriod,'minutes'))) %>%
  group_by(timePeriod) %>%
  summarise(sum = sum(P1)) %>%
  right_join(d2)

sum_most = function(x,thresh=0.8){
  N = length(x)
  N.missing = length(which(is.na(x)))
  p.missing = N.missing/N
  if (p.missing<(1-thresh)){
    y = mean(x,na.rm=T)*N
  } else {
    y = NA
  }
  return(y)
}
d4 = d1 %>%
  mutate(timePeriod = floor_date(date1, paste0(aggPeriod,'minutes'))) %>%
  group_by(timePeriod) %>%
  summarise(sum = sum_most(P1)) %>%
  right_join(d2)

quantile(d4$sum,probs=c(0.99,0.999),na.rm=T)

probs = c(0.99,0.999)
year_vec = year.min:year.max
metrics = matrix(nrow=length(year.min:year.max),ncol=length(probs))
year.all = as.integer(format(d4$timePeriod,'%Y'))
for(y in 1:length(year_vec)){
  print(y)
  i = which(year.all==year_vec[y])
  metrics[y,] = quantile(d4$sum[i],probs=probs,na.rm=T)
  print(metrics[y,])
}

plot(year_vec,metrics[,1],ylim=c(0,5),type = 'l',col='blue')
lines(year_vec,metrics[,2],col='red')

# i = which(format(d4$timePeriod,'%Y')=='2004')
#
# t = d4$timePeriod
#
# dt = t[2:length(t)]-t[1:(length(t)-1)]

