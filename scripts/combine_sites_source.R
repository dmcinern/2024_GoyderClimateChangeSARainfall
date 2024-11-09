# # TO DO
# # better handling of missing data
# # 1: use AWS at site where possible
# # 2: use pluvio at site (adjusted by mean over consistent periods)
# # 3: use AWS at nearby site (adjusted by mean over consistent periods)
# # 4: use pluvio at nearby site (adjusted by mean over consistent periods)
# # record site, source used for each time
# 
# rm(list=ls())
# 
# setwd('C:/Users/a1065639/Work/2024_GoyderClimateChangeSARainfall/scripts/')
# source('settings.R')
# 
# 
# # # blended pluvio and AWS
# #site_list = c('023034')
# #nearbySite_list = list('023034'='023090')
# 
# site_list = c('023090')
# nearbySite_list = list('023090'='023034')
# #nearbySite_list = list('023090'='023013')
# 
# # instrument_list = c('AWS','pluvio')
# aggPeriod_list = c('12 mins','30 mins','1 hour','3 hours','1 month')
# #aggPeriod_list = c('12 mins')
# year.min = 1978
# year.max = 2023
# x.index = 'GMT'
# agg_data_thresh = 0.8
# accum_handling = 'spread'
# metric_list = c('mean','max','EY2','EY6')

# time.min = as.POSIXct(paste0(year.min,'/01/01 00:00:00'),tz='UTC')
# time.max = as.POSIXct(paste0((year.max+1),'/01/01 00:00:00'),tz='UTC')
# 
# for (site in site_list){
# for (aggPeriod in aggPeriod_list){

combine_sites_sources = function(agg_data_list,site,aggPeriod,plot.year.min,plot.year.max,rData_dirname,
                                 accum_handling,agg_data_thresh,nearbySite_list,
                                 useAWS=T,usePluvio=T){
  
  time.min = as.POSIXct(paste0(plot.year.min,'/01/01 00:00:00'),tz='UTC')
  time.max.p1 = as.POSIXct(paste0((plot.year.max+1),'/01/01 00:00:00'),tz='UTC')
  
  
  times = seq(time.min,time.max.p1,by=aggPeriod)
  times = times[1:(length(times)-1)]
  
  dt = times[2] - times[1]
  
  combo_aggData = list()
  combo_aggData$date = times
  
  combo_aggData$P = rep(NA,length(times))
  combo_aggData$source = rep('none',length(times))
  
  ####################

  if (useAWS){
    
    print('AWS.site')
    
    AWS_site_aggData=agg_data_list[[site]]$AWS[[aggPeriod]]
    
  #  AWS_site_fname = paste0(rData_dirname,'AWS_',site,'_accumHandling.',accum_handling,'_processed_aggPeriod.',gsub(" ", "", aggPeriod),'_aggDataThresh.',agg_data_thresh,'_agg.RData') 
  #  if (file.exists(AWS_site_fname)){
      
  #    load(AWS_site_fname)
  #    AWS_site_aggData = agg_data
   
    if (!is.null(AWS_site_aggData)){
       
      date_AWS_site = AWS_site_aggData$date
      keep1 = which(date_AWS_site %in% times)
      keep2 = which(times %in% date_AWS_site)
      P_AWS_site = rep(NA,length(times))
      P_AWS_site[keep2] = AWS_site_aggData$P[keep1]
      
      # replacements = which(!is.na(P_AWS_site))
      
      common = which((!is.na(combo_aggData$P))&(!is.na(P_AWS_site)))
      
      if (all(is.na(combo_aggData$P))){
        fac = 1
      } else {
        fac = mean(combo_aggData$P[common]) / mean(P_AWS_site[common]) 
      }
      print(fac)
      
      replacements = which((!is.na(P_AWS_site)&(is.na(combo_aggData$P))))
      
      combo_aggData$P[replacements] = P_AWS_site[replacements]
      combo_aggData$source[replacements] = 'AWS.site'
      
    } else {
      
      print('no data for AWS.site')
      
    }
    
  }
  
  ####################
  
  if (usePluvio){
  
    print('pluvio.site')
    
    pluvio_site_aggData=agg_data_list[[site]]$pluvio[[aggPeriod]]
    
  #  pluvio_site_fname = paste0(rData_dirname,'pluvio_',site,'_accumHandling.',accum_handling,'_processed_aggPeriod.',gsub(" ", "", aggPeriod),'_aggDataThresh.',agg_data_thresh,'_agg.RData') 
    
  #  if (file.exists(pluvio_site_fname)){
      
  #    load(pluvio_site_fname)
  #    pluvio_site_aggData = agg_data
      
    if (!is.null(pluvio_site_aggData)){
      
      date_pluvio_site = pluvio_site_aggData$date
      keep1 = which(date_pluvio_site %in% times)
      keep2 = which(times %in% date_pluvio_site)
      P_pluvio_site = rep(NA,length(times))
      P_pluvio_site[keep2] = pluvio_site_aggData$P[keep1]
      
      common = which((!is.na(combo_aggData$P))&(!is.na(P_pluvio_site)))
      
      if (all(is.na(combo_aggData$P))){
        fac = 1
      } else {
        fac = mean(combo_aggData$P[common]) / mean(P_pluvio_site[common]) 
      }
      print(fac)
      
      replacements = which((!is.na(P_pluvio_site)&(is.na(combo_aggData$P))))
      
      combo_aggData$P[replacements] = P_pluvio_site[replacements]*fac
      combo_aggData$source[replacements] = 'pluvio.site'
      
    } else {
      
      print('no data for pluvio.site')
      
    }
    
  }
  
  ####################
  
  if (useAWS){
    
    print('AWS.nearbySite')
    
    AWS_nearbySite_aggData=agg_data_list[[nearbySite_list[[site]]]]$AWS[[aggPeriod]]
    
    #AWS_nearbySite_fname = paste0(rData_dirname,'AWS_',nearbySite_list[[site]],'_accumHandling.',accum_handling,'_processed_aggPeriod.',gsub(" ", "", aggPeriod),'_aggDataThresh.',agg_data_thresh,'_agg.RData') 
    
    #if (file.exists(AWS_nearbySite_fname)){
      
      #load(AWS_nearbySite_fname)
      #AWS_nearbySite_aggData = agg_data
      
    if (!is.null(AWS_nearbySite_aggData)){
      
      date_AWS_nearbySite = AWS_nearbySite_aggData$date
      keep1 = which(date_AWS_nearbySite %in% times)
      keep2 = which(times %in% date_AWS_nearbySite)
      P_AWS_nearbySite = rep(NA,length(times))
      P_AWS_nearbySite[keep2] = AWS_nearbySite_aggData$P[keep1]
      
      common = which((!is.na(combo_aggData$P))&(!is.na(P_AWS_nearbySite)))
      
      if (all(is.na(combo_aggData$P))){
        fac = 1
      } else {
        fac = mean(combo_aggData$P[common]) / mean(P_AWS_nearbySite[common]) 
      }
      print(fac)
      
      replacements = which((!is.na(P_AWS_nearbySite)&(is.na(combo_aggData$P))))
      
      combo_aggData$P[replacements] = P_AWS_nearbySite[replacements]*fac
      combo_aggData$source[replacements] = 'AWS.nearbySite'
      
    } else {
      
      print('no data for AWS.nearbySite')
      
    }
    
  }
  
  ####################
  
  if (usePluvio){
    
    print('pluvio.nearbySite')
    
    pluvio_nearbySite_aggData=agg_data_list[[nearbySite_list[[site]]]]$pluvio[[aggPeriod]]
    
    #pluvio_nearbySite_fname = paste0(rData_dirname,'pluvio_',nearbySite_list[[site]],'_accumHandling.',accum_handling,'_processed_aggPeriod.',gsub(" ", "", aggPeriod),'_aggDataThresh.',agg_data_thresh,'_agg.RData') 
    
    #if (file.exists(pluvio_nearbySite_fname)){
      
      #load(pluvio_nearbySite_fname)
      #pluvio_nearbySite_aggData = agg_data
      
    if (!is.null(pluvio_nearbySite_aggData)){
      
      date_pluvio_nearbySite = pluvio_nearbySite_aggData$date
      keep1 = which(date_pluvio_nearbySite %in% times)
      keep2 = which(times %in% date_pluvio_nearbySite)
      P_pluvio_nearbySite = rep(NA,length(times))
      P_pluvio_nearbySite[keep2] = pluvio_nearbySite_aggData$P[keep1]
      
      common = which((!is.na(combo_aggData$P))&(!is.na(P_pluvio_nearbySite)))
      if (all(is.na(combo_aggData$P))){
        fac = 1
      } else {
        fac = mean(combo_aggData$P[common]) / mean(P_pluvio_nearbySite[common]) 
      }
      print(fac)
      
      replacements = which((!is.na(P_pluvio_nearbySite)&(is.na(combo_aggData$P))))
      
      combo_aggData$P[replacements] = P_pluvio_nearbySite[replacements]*fac
      combo_aggData$source[replacements] = 'pluvio.nearbySite'
      
    } else {
      
      print('no data for pluvio.nearbySite')
      
    }
    
  }
  
  return(combo_aggData)
}
    ############################
    
    # cat('calculating metrics\n')
    # annual_metrics_combo = calc_annual_metrics_core(agg_data=combo_aggData,
    #                                      metric_list=metric_list)
    # 
    # prop.from.site = apply(annual_metrics_combo$sources.years[,c('AWS.site','pluvio.site')],1,sum)
    # keep = which(prop.from.site>0.9)
    # 
    # years = seq(year.min,year.max)
    # 
    # par(mfrow=c(2,2))
    # for (m in 1:length(metric_list)){
    #   met = rep(NA,length(years))
    #   met[keep] = annual_metrics_combo$metrics[,m][keep]
    #   lmfit=lm(met~years)
    #   plot(years,met,type='o')
    #   title(paste0(site,' ',aggPeriod,' slope=',format(lmfit$coefficients[2],digits=2)))
    # }

    ####################
    
#   }
# }

