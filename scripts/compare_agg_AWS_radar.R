rm(list=ls())

setwd('C:/Users/a1065639/Work/2024_GoyderClimateChangeSARainfall/scripts/')
source('annual_metrics.R')
source('settings.R')

#site_list = c('023034','023090','023013')

#s = 1
#site = site_list[s]

# airport
s_radar = 1
site_aws = '023034'

# # kent town
# s_radar = 2
# site_aws = '023090'
# 
# # parafield
# s_radar = 5
# site_aws = '023013'

# # edinburgh
# s_radar = 3
# site_aws = '023083'
# 
# # noarlunga
# s_radar = 6
# site_aws = '023885'
# 
# # west terrace
# s_radar = 7
# site_aws = '023000'
# 
# # mount lofty
# s_radar = 8
# site_aws = '023842'

#aggPeriod = '5 mins'
aggPeriod = '30 mins'
#aggPeriod = '3 hours'

# date.plot = as.Date('2021/09/29')
# nDays = 2
# ymax_aws = ymax_buckpk = 2.5
# ymax_sellicks = 4
# ymax_buckpk_spatMax = 20
# ymax_sellicks_spatMax = 60

date.plot = as.Date('2023/11/27')
nDays = 2
ymax_aws = 10 
ymax_buckpk = 8 
ymax_sellicks = 12
ymax_buckpk_spatMax = 15
ymax_sellicks_spatMax = 40

#date.min = as.Date('2023/06/22')
#date.min = as.Date('2023/06/06')
#date.min = as.Date('2023/11/27')

load('../RData/Radar/out_merge.BuckPk.2020.2023.RData')
P_agg_BuckPk = out_merge$agg[[aggPeriod]]$P_sites_mat[,s_radar]
times_agg_BuckPk = out_merge$agg[[aggPeriod]]$times.start
P_agg_BuckPk_spatMax = out_merge$agg[[aggPeriod]]$P_max_box_vec

load('../RData/Radar/out_merge.Sellicks.2020.2023.RData')
P_agg_Sellicks = out_merge$agg[[aggPeriod]]$P_sites_mat[,s_radar]
times_agg_Sellicks = out_merge$agg[[aggPeriod]]$times.start
P_agg_Sellicks_spatMax = out_merge$agg[[aggPeriod]]$P_max_box_vec

# if (aggPeriod == '30 mins'){
#   load('../RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData')
# } else if (aggPeriod == '3 hours'){
#   load('../RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.3hours_aggDataThresh.0.8_agg.RData')
# } 

if (aggPeriod == '5 mins'){
  aggStr = '5mins'
} else if (aggPeriod == '30 mins'){
  aggStr = '30mins'
} else if (aggPeriod == '3 hours'){
  aggStr = '3hours'
}

#if (!(aggPeriod == '5 mins')){
  load(paste0('../RData.AWS.7stations/AWS_',site_aws,'_accumHandling.spread_processed_aggPeriod.',aggStr,'_aggDataThresh.0.8_agg.RData'))
  P_agg_AWS = agg_data$P
  #times_agg_AWS = agg_data$date - 60*60 ## -60*60*9.5
  #times_agg_AWS = agg_data$date -60*60*9.5
  times_agg_AWS = agg_data$date -60*60*10.5
#} else {
#  P_agg_AWS = times_agg_AWS = c()
#}

  

# i.start = which(times_agg_AWS==times_agg_BuckPk[1])
# i.end = which(times_agg_AWS==times_agg_BuckPk[length(times_agg_BuckPk)])
# 
# P_agg_AWS_sel = P_agg_AWS[i.start:i.end]
# times_agg_AWS_sel = times_agg_AWS[i.start:i.end]
# 
# print(mean(P_agg_AWS_sel,na.rm=T))
# print(mean(P_agg_BuckPk,na.rm=T))
# print(mean(P_agg_Sellicks,na.rm=T))

date.min = as.Date('2020/01/02')
date.max = as.Date('2023/12/30')

keep_AWS = which((as.Date(times_agg_AWS)>=date.min)&(as.Date(times_agg_AWS)<=date.max))
keep_BuckPk = which((as.Date(times_agg_BuckPk)>=date.min)&(as.Date(times_agg_BuckPk)<=date.max))
keep_Sellicks = which((as.Date(times_agg_Sellicks)>=date.min)&(as.Date(times_agg_Sellicks)<=date.max))


#i = which(P_agg_AWS_sel==max(P_agg_AWS_sel,na.rm=T))
#t.AWS = times_agg_AWS_sel[i]
i = which(P_agg_AWS[keep_AWS]==max(P_agg_AWS[keep_AWS],na.rm=T))
t.AWS = times_agg_AWS[keep_AWS][i]

i = which(P_agg_BuckPk[keep_BuckPk]==max(P_agg_BuckPk[keep_BuckPk],na.rm=T))
t.Buck = times_agg_BuckPk[keep_BuckPk][i]

# i = which(P_agg_BuckPk==max(P_agg_BuckPk,na.rm=T))
# t.Buck = times_agg_BuckPk[i]

#i = which(P_agg_Sellicks[keep_Sellicks]==max(P_agg_Sellicks[keep_Sellicks],na.rm=T))
#t.Sellicks = times_agg_Sellicks[keep_Sellicks][i]

i = which(P_agg_BuckPk_spatMax[keep_BuckPk]==max(P_agg_BuckPk_spatMax[keep_BuckPk],na.rm=T))
t.Buck.spatMax = times_agg_BuckPk[keep_BuckPk][i]

# i = which(P_agg_Sellicks==max(P_agg_Sellicks,na.rm=T))
# t.Sellicks = times_agg_Sellicks[i]

i = which(P_agg_Sellicks_spatMax==max(P_agg_Sellicks_spatMax,na.rm=T))
t.Sellicks.spatMax = times_agg_Sellicks[i]

########################################################

fname = paste0(Fig_dirname,paste0(site_aws,'_',aggPeriod,'_',date.plot,'_',nDays,'days.pdf'))
pdf(fname)

#date.min = as.Date(t.Buck)

#date.min = as.Date('2020/10/19')
#

#date.min = as.Date('2021/09/29')

#date.min = as.Date('2023/06/22')
#date.min = as.Date('2023/06/06')
#date.min = as.Date('2023/11/27')
#nDays = 2

par(mfrow=c(3,2),mar=c(4,4,2,1),oma=c(1,1,3,1))

# keep = which(abs(as.Date(times_agg_AWS_sel)-date.min)<3)
# plot(times_agg_AWS_sel,P_agg_AWS_sel[keep],type='l')#,ylim=c(0,1))

keep_BuckPk = which(abs(as.Date(times_agg_BuckPk)-date.plot)<nDays)
plot(times_agg_BuckPk[keep_BuckPk],P_agg_BuckPk[keep_BuckPk],type='l',ylab='P (mm)',xlab='',ylim=c(0,ymax_buckpk))
title('Buckland Park',line = 0.5)

plot(times_agg_BuckPk[keep_BuckPk],P_agg_BuckPk_spatMax[keep_BuckPk],type='l',ylab='P (mm)',xlab='',ylim=c(0,ymax_buckpk_spatMax))
title('Buckland Park spat max',line = 0.5)

keep_Sellicks = which(abs(as.Date(times_agg_Sellicks)-date.plot)<nDays)
plot(times_agg_Sellicks[keep_Sellicks],P_agg_Sellicks[keep_Sellicks],type='l',ylab='P (mm)',xlab='',ylim=c(0,ymax_sellicks))
title('Sellicks',line = 0.5)

plot(times_agg_Sellicks[keep_Sellicks],P_agg_Sellicks_spatMax[keep_Sellicks],type='l',ylab='P (mm)',xlab='',ylim=c(0,ymax_sellicks_spatMax))
title('Sellicks spat max',line = 0.5)

keep_AWS = which(abs(as.Date(times_agg_AWS)-date.plot)<nDays)
if (length(keep_AWS)>0){
  plot(times_agg_AWS[keep_AWS],P_agg_AWS[keep_AWS],type='l',ylab='P (mm)',xlab='',ylim=c(0,ymax_aws))
  title('AWS',line = 0.5)
}

plot.new()


title(paste0(Site_labels[[site_aws]],', ',aggPeriod,', ',date.plot),outer=T,line=2)

###############################################################

date.min = as.Date('2020/01/02')
date.max = as.Date('2023/12/30')

keep_AWS = which((as.Date(times_agg_AWS)>=date.min)&(as.Date(times_agg_AWS)<=date.max))
keep_BuckPk = which((as.Date(times_agg_BuckPk)>=date.min)&(as.Date(times_agg_BuckPk)<=date.max))
keep_Sellicks = which((as.Date(times_agg_Sellicks)>=date.min)&(as.Date(times_agg_Sellicks)<=date.max))

cor(P_agg_AWS[(keep_AWS)],P_agg_BuckPk[keep_BuckPk],use = 'pairwise.complete.obs')
cor(P_agg_AWS[(keep_AWS)],P_agg_Sellicks[keep_Sellicks],use = 'pairwise.complete.obs')
cor(P_agg_BuckPk[keep_BuckPk],P_agg_Sellicks[keep_Sellicks],use = 'pairwise.complete.obs')

plot(P_agg_AWS[(keep_AWS)],P_agg_BuckPk[keep_BuckPk])
plot(P_agg_AWS[(keep_AWS)],P_agg_Sellicks[keep_BuckPk])
plot(P_agg_BuckPk[keep_BuckPk],P_agg_Sellicks[keep_BuckPk])

mean(P_agg_AWS[(keep_AWS)],na.rm=T)*365*48
mean(P_agg_BuckPk[keep_BuckPk],na.rm=T)*365*48
mean(P_agg_Sellicks[keep_BuckPk],na.rm=T)*365*48

###############################################################

#metric_list = c('P99','P99.9','mean','max','EY1','EY3','EY6')
metric_list = c('mean','max','EY2','EY6')

year.min = 2020
year.max = 2023
date.min = as.Date(paste0(year.min,'/01/01'))
date.max = as.Date(paste0(year.max,'/12/31'))
keep_AWS = which((as.Date(times_agg_AWS)>=date.min)&(as.Date(times_agg_AWS)<=date.max))

agg_data = list(date=times_agg_AWS[keep_AWS],P=P_agg_AWS[keep_AWS])
annual_metrics_AWS = calc_annual_metrics_core(agg_data,metric_list)

agg_data = list(date=times_agg_BuckPk,P=P_agg_BuckPk)
annual_metrics_BuckPk = calc_annual_metrics_core(agg_data,metric_list)
  
agg_data = list(date=times_agg_Sellicks,P=P_agg_Sellicks)
annual_metrics_Sellicks = calc_annual_metrics_core(agg_data,metric_list)

# par(mfrow=c(3,1),mar=c(4,4,1,1))
# plot(annual_metrics_AWS$metrics[,'max'],annual_metrics_BuckPk$metrics[,'max'])
# abline(a=0,b=1,lty=2)
# plot(annual_metrics_AWS$metrics[,'max'],annual_metrics_Sellicks$metrics[,'max'])
# abline(a=0,b=1,lty=2)
# plot(annual_metrics_BuckPk$metrics[,'max'],annual_metrics_Sellicks$metrics[,'max'])
# abline(a=0,b=1,lty=2)

par(mfrow=c(2,2),mar=c(4,4,1,1))
for (metric in metric_list){
  if ((metric=='mean')&(aggPeriod == '30 mins')){
    fac= 365*48
  } else {
    fac = 1
  }
  year = annual_metrics_AWS$all$year
  m_AWS = fac*annual_metrics_AWS$all$metrics[,metric]
  m_BuckPk = fac*annual_metrics_BuckPk$all$metrics[,metric]
  m_Sellicks = fac*annual_metrics_Sellicks$all$metrics[,metric]
  ymin = min(m_AWS,m_BuckPk,m_Sellicks)
  ymax = max(m_AWS,m_BuckPk,m_Sellicks)
#  ymin = min(annual_metrics_AWS$all$metrics[,metric],annual_metrics_BuckPk$all$metrics[,metric])
#  ymax = max(annual_metrics_AWS$all$metrics[,metric],annual_metrics_BuckPk$all$metrics[,metric])
  #plot(year,annual_metrics_AWS$metrics[,'max']/annual_metrics_AWS$metrics[,'mean'],type='o',ylim=c(0,600),
  #     xlab='Year',ylab='')
  plot(year,m_AWS,type='o',ylim=c(ymin,ymax),
       xlab='Year',ylab=metric)
  lines(year,m_BuckPk,type='o',col='red')
 lines(year,m_Sellicks,type='o',col='blue')
  if(metric==metric_list[1]){legend('topleft',c('AWS','Buck Pk','Sellicks'),col=c('black','red','blue'),lty=1,cex=0.75,bty='n')}
}
title(paste0(Site_labels[[site_aws]],', ',aggPeriod),outer=T,line=2)

# pause
# 
# par(mfrow=c(1,1),mar=c(4,4,1,1))
# year = annual_metrics_AWS$year
# plot(year,annual_metrics_AWS$metrics[,'EY6']/annual_metrics_AWS$metrics[,'mean'],type='o',ylim=c(0,200))
# lines(year,annual_metrics_BuckPk$metrics[,'EY6']/annual_metrics_BuckPk$metrics[,'mean'],type='o',col='red')
# lines(year,annual_metrics_Sellicks$metrics[,'EY6']/annual_metrics_Sellicks$metrics[,'mean'],type='o',col='blue')

###############################################################

agg_data = list(date=times_agg_BuckPk,P=P_agg_BuckPk_spatMax)
annual_metrics_BuckPk_spatMax = calc_annual_metrics_core(agg_data,metric_list)

agg_data = list(date=times_agg_BuckPk,P=P_agg_Sellicks_spatMax)
annual_metrics_Sellicks_spatMax = calc_annual_metrics_core(agg_data,metric_list)

par(mfrow=c(1,1),mar=c(4,4,1,1))
  metric = 'max'
  year = annual_metrics_AWS$all$year
  ymin = min(annual_metrics_BuckPk_spatMax$all$metrics[,metric],annual_metrics_BuckPk$all$metrics[,metric])
  ymax = max(annual_metrics_BuckPk_spatMax$all$metrics[,metric],annual_metrics_BuckPk$all$metrics[,metric])
  #plot(year,annual_metrics_AWS$metrics[,'max']/annual_metrics_AWS$metrics[,'mean'],type='o',ylim=c(0,600),
  #     xlab='Year',ylab='')
  plot(year,annual_metrics_BuckPk_spatMax$all$metrics[,metric],type='o',ylim=c(ymin,ymax),
       xlab='Year',ylab=metric)
  lines(year,annual_metrics_BuckPk$all$metrics[,metric],type='o',col='red')

    legend('topleft',c('Spatial max','Station location'),col=c('black','red'),lty=1,cex=0.75,bty='n')
title(paste0(Site_labels[[site_aws]],', Buckland Park, ',aggPeriod),outer=T,line=2)

par(mfrow=c(1,1),mar=c(4,4,1,1))
metric = 'max'
year = annual_metrics_AWS$all$year
ymin = min(annual_metrics_Sellicks_spatMax$all$metrics[,metric],annual_metrics_Sellicks$all$metrics[,metric])
ymax = max(annual_metrics_Sellicks_spatMax$all$metrics[,metric],annual_metrics_Sellicks$all$metrics[,metric])
#plot(year,annual_metrics_AWS$metrics[,'max']/annual_metrics_AWS$metrics[,'mean'],type='o',ylim=c(0,600),
#     xlab='Year',ylab='')
plot(year,annual_metrics_Sellicks_spatMax$all$metrics[,metric],type='o',ylim=c(ymin,ymax),
     xlab='Year',ylab=metric)
lines(year,annual_metrics_Sellicks$all$metrics[,metric],type='o',col='red')

legend('topleft',c('Spatial max','Station location'),col=c('black','red'),lty=1,cex=0.75,bty='n')
title(paste0(Site_labels[[site_aws]],', Sellicks, ',aggPeriod),outer=T,line=2)

par(mfrow=c(1,1),mar=c(4,4,1,1))
year = annual_metrics_BuckPk_spatMax$all$year
plot(year,annual_metrics_BuckPk_spatMax$all$metrics[,'max'],type='o',ylim=c(0,70),col='red')
lines(year,annual_metrics_BuckPk$all$metrics[,'max'],type='o',col='red',lty=2)
# lines(year,annual_metrics_Sellicks_spatMax$metrics[,'max'],type='o',col='blue')
# lines(year,annual_metrics_Sellicks$metrics[,'max'],type='o',col='blue',lty=2)

par(mfrow=c(1,1),mar=c(4,4,1,1))
year = annual_metrics_BuckPk_spatMax$all$year
plot(year,annual_metrics_BuckPk_spatMax$all$metrics[,'EY6'],type='o',ylim=c(0,200),col='red')
#lines(year,annual_metrics_Sellicks_spatMax$metrics[,'EY6'],type='o',col='blue')

plot(ecdf(P_agg_BuckPk/mean(P_agg_BuckPk,na.rm=T)),ylim=c(0.99,1))
lines(ecdf(P_agg_Sellicks/mean(P_agg_Sellicks,na.rm=T)),col='red')

###############################################################

dev.off()
