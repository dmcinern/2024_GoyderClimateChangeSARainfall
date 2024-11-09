rm(list=ls())

#setwd("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/scripts/")
setwd('C:/Users/a1065639/Work/2024_GoyderClimateChangeSARainfall/scripts/')
source('settings.R')

# #pluvio and AWS all years and plot both
# # site_list = c('023034','023090','023083','023013')
# # pdf_str = 'both'
# instrument_list = c('pluvio','AWS')
# plot.instrument_list = instrument_list
# plot.year.min = plot.year.max = NULL
# blend = F
# plot_linear = F
# x.index = 'year'
# # x.index = 'GMT'
# # 
# # site_list = c('026021','016001')
# # pdf_str = 'both_regional'
# 
# combine_sources_sites = F
# 
# site_list = c('24024')
# pdf_str = 'both_loxton'

# # blended pluvio and AWS
# site_list = c('023034','023090','023013')
# nearbySite_list = list('023034'='023090','023090'='023034','023013'='023090')
#site_list = c('023034')
#nearbySite_list = list('023034'='023090')
Instrument_list = c('pluvio','AWS')
#instrument_list = c('AWS')
Plot.year.min = 1978
Plot.year.max = 2023
Blend = T
Combine_sources_sites = F
Plot_linear = T
X.index = 'year'
#X.index = 'GMT'
# 
# plot.instrument_list = c('AWS_pluvio')
# # pdf_str = 'AWS_pluvio'
# 
#plot.instrument_list = c('combo_sources_sites')
# # pdf_str = 'combo_sources_sites'
# 
# 
# #plot.year.max = 2019
# #pdf_str = 'AWS_pluvio_2019'
# 

#site_list = c('023034','023090','023013','023823','023824')
Site_list = c('023034','023090','023013','023823')
#site_list = c('023034')
NearbySite_list = list('023034'='023090',
                       '023090'='023034',
                       '023013'='023090',
                       '023823'='023824',
                       '023824'='023823')

#site_list = c('023824')
#site_list = c('023823')
# pdf_str = 'AWS_pluvio_Hindmarsh'

# site_list = c('023034','023090','023083','023013')
# pdf_str = 'AWS_pluvio_Edinburgh'

# site_list = c('026021')
# pdf_str = 'AWS_pluvio_MtGamb'

Combine_sources_sites = T
Plot.instrument_list = c('combo_sources_sites')
Pdf_str = 'combo_sources_sites_hindmarsh'

# site_list = c('023034')
# pdf_str = 'combo_sources_sites_tmp'


# site_list = c('24024')
# pdf_str = 'AWS_pluvio_loxton'



# # AWS
# #site_list = c('023034','023090','023083','023013','023885')
# site_list = c('023034','023090','023013')
# instrument_list = c('AWS')
# plot.instrument_list = c('AWS')
# plot.year.min = 2002
# plot.year.max = 2023
# blend = F
# plot_linear = T
# #x.index = 'year'
# x.index = 'GMT'
# pdf_str = 'AWS'

# pluvio
# site_list = c('023034','023090','023083','023013',
#               '023343','024515','023801','023823')#,'023763')
# pdf_str = 'pluvio'
# instrument_list = c('pluvio')
# plot.instrument_list = c('pluvio')
# plot.year.min = 1973
# plot.year.max = 2017
# blend = F
# plot_linear = T
# x.index = 'year'
# #x.index = 'GMT'
# # 
# # site_list = c('026021','018012','018116','021060','024515','026049','026082','016001','016032')
# # pdf_str = 'pluvio_regional'
# 
# 
# #site_list = c('023343','025006','023763','023801','023823','023824','026091')
# #pdf_str = 'pluvio_another_set'
# 
# 
# site_list = c('23843')
# pdf_str = 'pluvio_heathfield'
# 
# combine_sources_sites = F


#plot.instrument_list = instrument_list
# plot.instrument_list = 'pluvio'
# plot.year.min = plot.year.max = NULL


#site_list = c('023034','023090','023083','023013','023885')#,'023842') # AWS

#site_list = c('023878') # 'Mount Crawford (AWS)'
#site_list = c('023763') # 'Mount Crawford (Forest Head)'


#site_list = c('023034','023090')
#site_list = c('023034')
#site_list = c('023090')
#site_list = c('023083')
#site_list = c('023013')
#site_list = c('023885')
#site_list = c('023034')
#site_list = c('023842')

#site_list = c('023034')

#site_list = c('023000','023034','023343','023763','023801','024515','023823')

#site_list = c('023000','023763','023801','024515','023823') # pluvio

#site_list = c('023763')

#site_list = c('023034','023090','023083')

#site_list = c('023090')
#instrument_list = c('pluvio')
#instrument_list = c('AWS')

# instrument_list = c('AWS','pluvio','daily')

#site_list = c('023013','023885','023842')

#site_list = c('023000')
#instrument_list = c('daily')

#aggPeriod = '30 mins'
#aggPeriod = '12 mins'
#aggPeriod = '1 hour'
#aggPeriod = '2 hours'
#aggPeriod = '3 hours'
#aggPeriod = '1 day'

#aggPeriod_list = c('1 hour')
#aggPeriod_list = c('6 mins')
AggPeriod_list = c('12 mins','30 mins','1 hour','3 hours','1 month')
#aggPeriod_list = c('30 mins')
#aggPeriod_list = c('3 hours')
#aggPeriod_list = c('1 hour','3 hours')
# aggPeriod_list = c('30 mins','1 month')
#aggPeriod_list = c('1 month')

#site = '023034' # Adelaide airport
#site = '023090' # Adelaide Kent Town
#site = '023083' # Edinburgh RAAF
#site = '023013' # Parafield airport
#site = '023885' # Noarlunga
#site = '023842' # Mount Lofty
#site = '023343' # Rosedale
#site = '' # Mount Crawford
#site = '023000' # West Terrace

#instrument = 'AWS'
#instrument = 'pluvio'

Load_raw_RData = T
Load_processed_RData = T
Load_agg_RData = T
Load_annual_metrics = T

Agg_data_thresh = 0.8
Accum_handling = 'spread'
Missing_year_thresh = 0.1
#metric_list = c('mean','max','P99','P99.9','EY1','EY3','EY6')
#metric_list = c('mean','max','P99','P99.9','EY3','EY6')
Metric_list = c('mean','max','EY2','EY6')
#metric_list = c('mean','max')

Blend_type = 'AWS_pluvio'

Blend_processed_data = F

# plot.instrument_list = c('pluvio')
# plot.year.min = 1972
# plot.year.max = 2017
#
# plot.instrument_list = c('AWS')
# plot.year.min = 2001
# plot.year.max = 2024

# plot.instrument_list = c('AWS_pluvio')
# plot.year.min = 1978
# plot.year.max = 2024

Missing_year_thresh = 0.01
Nonsite_year_thresh = 0.1

Annual_metrics_list = Agg_data_list = Processed_data_list = Blend_year_change = list()

for (Site in Site_list){

  cat(Site,'\n')

  Annual_metrics_list[[Site]] = Agg_data_list[[Site]] = Processed_data_list[[Site]] = list()

  for (Instrument in Instrument_list){

    cat(Instrument,'\n')

    Annual_metrics_list[[Site]][[Instrument]] = Agg_data_list[[Site]][[Instrument]] = Processed_data_list[[Site]][[Instrument]] = list()

    if (!Load_processed_RData){
      cat('loading data\n')
      Raw_data = load_raw_data(site=Site,instrument=Instrument,
                               load_raw_RData=Load_raw_RData,
                               data_dirname=Data_dirname,
                               rData_dirname=RData_dirname) # matrix for pluvio, vector for aws
    } else {
      Raw_data = list(raw_RData_fname = paste0(RData_dirname,Instrument,'_',Site,'.RData'))
      if (!file.exists(Raw_data$raw_RData_fname)){Raw_data=NULL}
    }

    if (!Load_agg_RData){
      cat('processing data\n')
      # select years, get data in easy format, deal with QCs
      Processed_data = process_raw_data(raw_data=Raw_data,
                                        site=Site,
                                        instrument=Instrument,
                                        load_processed_RData=Load_processed_RData,
                                        accum_handling=Accum_handling,
                                        rData_dirname=RData_dirname)

    } else {
      if (is.null(Raw_data)){
        Processed_data=NULL
      } else {

        processed_RData_fname = strsplit(Raw_data$raw_RData_fname,'.RData',fixed=T)[[1]]
        processed_RData_fname = paste0(processed_RData_fname,'_accumHandling.',Accum_handling)
        processed_RData_fname = paste0(processed_RData_fname,'_processed.RData')
        Processed_data = list(processed_RData_fname=processed_RData_fname)

      }

    }
    Processed_data_list[[Site]][[Instrument]] = Processed_data

#    if(blend){
    if(Blend_processed_data){
        cat('blending processed data\n')

      if(Instrument==Instrument_list[length(Instrument_list)]){

        if (Blend_type=='AWS_pluvio'){

          p_pluvio = Processed_data_list[[Site]]$pluvio
          if (is.null(p_pluvio$date)){
            load(p_pluvio$processed_RData_fname)
            p_pluvio = out
          }
          p_aws = processed_data_list[[site]]$AWS
          if (is.null(p_aws$date)){
            load(p_aws$processed_RData_fname)
            p_aws = out
          }
          date_pluvio = p_pluvio$date
          date_aws = p_aws$date
          year_pluvio = as.integer(format(date_pluvio,'%Y'))
          year_aws = as.integer(format(date_aws,'%Y'))
          keep_pluvio = which(year_pluvio < min(year_aws))
          # p_blend = p_aws
          # p_blend$date = c(p_pluvio$date[keep_pluvio],p_blend$date)
          # p_blend$P = c(p_pluvio$P[keep_pluvio],p_blend$P)
          p_blend = list()
          p_blend$date = c(p_pluvio$date[keep_pluvio],p_aws$date)
          p_blend$P = c(p_pluvio$P[keep_pluvio],p_aws$P)
          p_blend$accPeriod = c(p_pluvio$accPeriod[keep_pluvio],p_aws$accPeriod)
          Blend_year_change[[Site]] = min(year_aws)
        }

        Processed_data_list[[Site]][[Blend_type]] = p_blend

        #          annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = blend_metrics(annual_metrics_list[[site]],blend_type,aggPeriod)
      }
    }

    for (AggPeriod in AggPeriod_list){

      cat(AggPeriod,'\n')

      cat('aggregating data\n')
      Agg_data = aggregate_data(processed_data=Processed_data,
                                aggPeriod=AggPeriod,
                                load_agg_RData=Load_agg_RData,
                                agg_data_thresh=Agg_data_thresh)

      Agg_data_list[[Site]][[Instrument]][[AggPeriod]] = Agg_data

      cat('calculating metrics\n')
      Annual_metrics = calc_annual_metrics(agg_data=Agg_data,
                                           metric_list=Metric_list,
                                           load_annual_metrics=Load_annual_metrics)

      Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]] = Annual_metrics

      if(Blend){
        cat('blending metrics\n')

        if(Instrument==Instrument_list[length(Instrument_list)]){

          if (Blend_type=='AWS_pluvio'){

            m_aws = Annual_metrics_list[[Site]]$AWS[[AggPeriod]]
            m_pluvio = Annual_metrics_list[[Site]]$pluvio[[AggPeriod]]

            a_pluvio = Agg_data_list[[Site]]$pluvio[[AggPeriod]]
            a_aws = Agg_data_list[[Site]]$AWS[[AggPeriod]]

            if (is.null(m_aws)){
              m_blend = m_pluvio
              a_blend = a_pluvio
            } else if (is.null(m_pluvio)){
              m_blend = m_aws
              a_blend = a_aws
            } else {
              year_aws = m_aws$year
              year_pluvio = m_pluvio$year
              keep_pluvio = which(year_pluvio < min(year_aws))
              # m_blend = m_aws
              # m_blend$year = c(m_pluvio$year[keep_pluvio],m_blend$year)
              # m_blend$metrics = rbind(m_pluvio$metrics[keep_pluvio,],m_blend$metrics)
              # m_blend$metrics.dates = rbind(m_pluvio$metrics.dates[keep_pluvio,],m_blend$metrics.dates)
              # m_blend$missing = c(m_pluvio$missing[keep_pluvio],m_blend$missing)
              m_blend = list()
              m_blend$year = c(m_pluvio$year[keep_pluvio],m_aws$year)
              m_blend$metrics = rbind(m_pluvio$metrics[keep_pluvio,],m_aws$metrics)
              m_blend$metrics.dates = rbind(m_pluvio$metrics.dates[keep_pluvio,],m_aws$metrics.dates)
              m_blend$missing = c(m_pluvio$missing[keep_pluvio],m_aws$missing)

              date_pluvio = a_pluvio$date
              date_aws = a_aws$date
              year_pluvio = as.integer(format(date_pluvio,'%Y'))
              year_aws = as.integer(format(date_aws,'%Y'))
              keep_pluvio = which(year_pluvio < min(year_aws))
              # a_blend = a_aws
              # a_blend$date = c(a_pluvio$date[keep_pluvio],a_blend$date)
              # a_blend$P = c(a_pluvio$P[keep_pluvio],a_blend$P)
              a_blend = list()
              a_blend$date = c(a_pluvio$date[keep_pluvio],a_aws$date)
              a_blend$P = c(a_pluvio$P[keep_pluvio],a_aws$P)
              Blend_year_change[[Site]] = min(year_aws)

            }


          }

          Annual_metrics_list[[Site]][[Blend_type]][[AggPeriod]] = m_blend
          Agg_data_list[[Site]][[Blend_type]][[AggPeriod]] = a_blend

          #annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = blend_metrics(annual_metrics_list[[site]],blend_type,aggPeriod)
        }
      }
      
      if (Combine_sources_sites){
        cat('merging agg data multiple sources/sites\n')
        # source('combine_sites_source.R')
        # agg_data_list[[site]][['combo_sources_sites']][[aggPeriod]] = combo_aggData
        Combo_aggData = combine_sites_sources(site=Site,
                                              aggPeriod=AggPeriod,
                                              plot.year.min=Plot.year.min,
                                              plot.year.max=Plot.year.max,
                                              rData_dirname=RData_dirname,
                                              accum_handling=Accum_handling,
                                              agg_data_thresh=Agg_data_thresh,
                                              nearbySite_list=NearbySite_list)
        
        
        Agg_data_list[[Site]][['combo_sources_sites']][[AggPeriod]]  = Combo_aggData
          
        annual_metrics = calc_annual_metrics_core(agg_data=Combo_aggData,
                                                  metric_list=Metric_list)
        
        Annual_metrics_list[[Site]][['combo_sources_sites']][[AggPeriod]] = annual_metrics
      }


    }



  }
}

instrument_list = c(Instrument_list,Blend_type,'combo_sources_sites')

#############################

cat('plotting\n')

Plot.aggPeriod_list = AggPeriod_list[AggPeriod_list!='1 month']

#############################

# site1 = site_list[1]
# site2 = site_list[3]
# instrument = 'AWS_pluvio'
# #aggPeriod = '12 mins'
# #aggPeriod = '30 mins'
# #aggPeriod = '1 hour'
# aggPeriod = '3 hours'
# metric = 'max'
#
# a1 = annual_metrics_list[[site1]][[instrument]][[aggPeriod]]
# m1 = a1$metrics[,metric]
# y1 = a1$year
#
# a2 = annual_metrics_list[[site2]][[instrument]][[aggPeriod]]
# m2 = a2$metrics[,metric]
# y2 = a2$year
#
# ymin = max(min(y1),min(y2))
# ymax = min(max(y1),max(y2))
#
# keep1 = which((y1>=ymin)&(y1<=ymax))
# keep2 = which((y2>=ymin)&(y2<=ymax))
#
# m1.keep = m1[keep1]
# m2.keep = m2[keep2]
#
# y.keep = y1[keep1]
#
# plot(m1.keep,m2.keep,xlab=site1,ylab=site2,main=paste0(metric,', ',aggPeriod))
# text(x=m1.keep,y=m2.keep,labels = y.keep,cex=0.5,pos = 1)
#
# pause


#############################

Pdf_fname = paste0(Fig_dirname,'summary_',Pdf_str,'_',X.index,'.pdf')

pdf(file=Pdf_fname)


# #aggPeriod = '30 mins'
# #aggPeriod = '12 mins'
# # aggPeriod = '3 hours'
# instrument = 'AWS_pluvio'
# #metric = 'max'
# # metric = 'EY2'
#
# for (s in 1:length(site_list)){
#   site = site_list[s]
#
#   for (aggPeriod in plot.aggPeriod_list){
#
#     for (metric in metric_list){
#
#       dates_plot = annual_metrics_list[[site]][[instrument]][[aggPeriod]]$metrics.dates[,metric]
#
#       for (y in 1:length(dates_plot)){
#
#         if (!is.na(dates_plot[y])){
#
#           date_plot = as.POSIXct(dates_plot[y],origin= "1970-01-01",tz = 'UTC')
#
#           a = agg_data_list[[site]][[instrument]][[aggPeriod]]
#           date_agg = a$date
#           i_agg = which(date_agg==date_plot)
#           dt_agg = date_agg[(i_agg+1)] - date_agg[i_agg]
#
#           p = processed_data_list[[site]][[instrument]]
#           date_processed = p$date
#           i_processed = which(date_processed==date_plot)
#
#           date_min = date_processed[i_processed] - 2*dt_agg
#           date_max = date_processed[i_processed] + 2*dt_agg
#
#           i_min = which(date_processed==date_min)
#           i_max = which(date_processed==date_max)
#
#           dt_proc = date_processed[(i_min+1)] - date_processed[i_min]
#
#           P_period = p$P[i_min:i_max]
#
#           col = rep('black',length(i_min:i_max))
#
#           col[p$accPeriod[i_min:i_max]>1] = 'red'
#
#           plot(date_processed[i_min:i_max],P_period,type='p',xlab='time',ylab='rain (mm)',col=col)
#           lines(date_processed[i_min:i_max],P_period,type='l')
#           # barplot(P_period,)
#           #axis(side=1,at=c(i_min,i_processed,i_max),labels = c(date_min,date_plot,date_max))
#
#           # if (any(col=='red')){browser()}
#
#           abline(v=(date_agg[i_agg]-dt_proc/2),lty=2)
#           abline(v=(date_agg[(i_agg+1)]-dt_proc/2),lty=2)
#
#           title(paste0(site,', ',date_plot,', ',aggPeriod,', ',metric))
#
#         }
#       }
#     }
#
#   }
#
# }
#
# #pause

#############################


o = plot_annual_metrics_multi(annual_metrics_list=Annual_metrics_list,
                              site_list=Site_list,
                              plot.aggPeriod_list=Plot.aggPeriod_list,
                              metric_list=Metric_list,
                              plot.instrument_list=Plot.instrument_list,
                              missing_year_thresh=Missing_year_thresh,
                              nonsite_year_thresh=Nonsite_year_thresh,
                              x.index=X.index,
                              plot_linear=Plot_linear,
                              plot.year.min=Plot.year.min,
                              plot.year.max=Plot.year.max,
                              combine_sources_sites=Combine_sources_sites,
                              site_labels = Site_labels)

SlopeArray=o$slopeArray;PValArray=o$pValArray;NPoints=o$nPoints;SlopeArrayLow=o$slopeArrayLow;SlopeArrayHigh=o$slopeArrayHigh

# for (s in 1:length(site_list)){
#   site = site_list[s]
#   for (i in 1:length(instrument_list)){
#     instrument = instrument_list[i]
#     for (a in 1:length(aggPeriod_list)){
#       aggPeriod = aggPeriod_list[a]
#       for (m in 1:length(metricList)){
#         metric = metricList[m]
#         oo = annual_metrics_list[[site]][[instrument]][[aggPeriod]]
#         metMean = o[[site]][[aggPeriod]]$metMean
#         slopeArray[s,i,a,m] = oo$slope[m] / metMean[[m]]
#         pValArray[s,i,a,m] = oo$pval[m]
#       }
#     }
#   }
#
# }


plot_trends_boxes(plot.year.min=Plot.year.min,
                  plot.year.max=Plot.year.max, 
                  x.index=X.index,
                  plot.instrument_list=Plot.instrument_list,
                  metric_list=Metric_list,
                  plot.aggPeriod_list=Plot.aggPeriod_list,
                  slopeArrayLow=SlopeArrayLow,
                  slopeArray=SlopeArray,
                  slopeArrayHigh=SlopeArrayHigh,
                  site_list=Site_list)

#############################################

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/monthly_HQ/rain.023721.monthly.txt'
d = read.table(fname,skip=1)
Date_start = as.Date('1863/01/01')
Date_end = as.Date('2023/10/01')
Date0 = seq(Date_start,Date_end,by='months')
P0 = d$V3

# date0 = dates
# year0 = as.integer(format(date0,'%Y'))
# keep0 = which((year0>=year.min)&(year0<=year.max))
# P0 = P[keep0]

########

# a1 = agg_data_list[[1]]$AWS_pluvio$`1 month`
# date1 = a1$date
# year1 = as.integer(format(date1,'%Y'))
# keep1 = which((year1>=year.min)&(year1<=year.max))
# P1 = a1$P[keep1]
#
# ########
#
# a2 = agg_data_list[[2]]$AWS_pluvio$`1 month`
# date2 = a2$date
# year2 = as.integer(format(date2,'%Y'))
# keep2 = which((year2>=year.min)&(year2<=year.max))
# P2 = a2$P[keep2]

########



########

# plot_double_mass(P0,P1)
#
# plot_double_mass(P0,P2)
#
# plot_double_mass(P1,P2)


# a1 = agg_data_list[[1]]$AWS_pluvio$`1 month`
# date1 = a1$date
# year1 = as.integer(format(date1,'%Y'))
# keep1 = which((year1>=year.min)&(year1<=year.max))
# P1 = a1$P[keep1]

#instrument = blend_type
#instrument = instrument_list[1]

####################################

AggPeriod = '1 month'
for (Instrument in Plot.instrument_list){
  par(mfrow=c(1,1),mar=c(4,4,1,1))
  for (Site in Site_list){
    a1 = Agg_data_list[[Site]][[Instrument]][[AggPeriod]]
    Date1 = a1$date
    P1 = a1$P
    plot_double_mass(p1=P0,p2=P1,date1 = Date0,date2 = Date1,
                     year.min = Plot.year.min,year.max = Plot.year.max,
                     instrumentChange=InstrumentChange[[Site]],
                     blend_year_change=Blend_year_change[[Site]],
                     xlab='Happy Valley HQ site (023721)',
                     ylab=paste0(Site_labels[[Site]],' (',Site,') - ',Instrument))
  }
}

####################################

dev.off()


# pause
#
# ###########################
#
# par(mfrow=c(2,1))
#
# xm = 4
# ym = 1
# for (i in 1:length(instrument_list)){
#   m = annual_metrics_list[[site]][[i]]$metrics
#   if (i==1){
#     plot(m[,xm],m[,ym],col=colList[i])
#   } else {
#     points(m[,xm],m[,ym],col=colList[i])
#   }
# }
#
# xm = 4
# ym = 2
# for (i in 1:length(instrument_list)){
#   m = annual_metrics_list[[site]][[i]]$metrics
#   if (i==1){
#     plot(m[,xm],m[,ym],col=colList[i])
#   } else {
#     points(m[,xm],m[,ym],col=colList[i])
#   }
# }
# ###########################
#
# pause
#
# #probs = c(0.99,0.999)
# probs = c(0.95,0.99)
#
# year.min = as.integer(format(agg_data$date[1],'%Y'))
# year.max = as.integer(format(agg_data$date[length(agg_data$date)],'%Y'))
#
# year_vec = year.min:year.max
#
# P = agg_data$P
# year.all = as.integer(format(agg_data$date,'%Y'))
# rqfit = rq(P~year.all,tau=probs)
#
# metrics = matrix(nrow=length(year.min:year.max),ncol=length(probs))
# missing = c()
# for(y in 1:length(year_vec)){
#   i = which(year.all==year_vec[y])
#   metrics[y,1:length(probs)] = quantile(agg_data$P[i],probs=probs,na.rm=T)
#   missing[y] = length(which(is.na(agg_data$P[i])))/length(agg_data$P[i])
#   # if (missing[y]>0.2){metrics[y,]=NA}
# }
#
# lm1 = lm(metrics[,1]~year_vec)
# lm2 = lm(metrics[,2]~year_vec)
#
#
# plot(year_vec,metrics[,1],type='l')
# lines(year_vec,rqfit$coefficients[1,1]+rqfit$coefficients[2,1]*year_vec)
# lines(year_vec,lm1$coefficients[1]+lm1$coefficients[2]*year_vec,col='red')
# abline(h=quantile(agg_data$P,probs=probs[1],na.rm=T),col='blue')
#
# plot(year_vec,metrics[,2],type='l')
# lines(year_vec,rqfit$coefficients[1,2]+rqfit$coefficients[2,2]*year_vec)
# lines(year_vec,lm2$coefficients[1]+lm2$coefficients[2]*year_vec,col='red')
# abline(h=quantile(agg_data$P,probs=probs[2],na.rm=T),col='blue')


#################################

instrument1 = 'AWS_pluvio'
instrument2 = 'combo_sources_sites'

for (site in Site_list){
  for (aggPeriod in AggPeriod_list){
    par(mfrow=c(3,2),oma=c(1,1,3,1),mar=c(5,5,1,1))
    for (metric in Metric_list){
      o1 = Annual_metrics_list[[site]][[instrument1]][[aggPeriod]]
      years1 = o1$year
      
      o2 = Annual_metrics_list[[site]][[instrument2]][[aggPeriod]]
      years2 = o2$year
      
      plot(years1,o1$metrics[,metric],type='o',col='black',
           xlab='year',ylab=metric,
           xlim=c(Plot.year.min,Plot.year.max))
      lines(years2,o2$metrics[,metric],type='o',col='red')
      
      title(metric)
    }
  
    plot(years1,o1$missing,type='o',col='black',
         xlab='year',ylab='missing',
         xlim=c(Plot.year.min,Plot.year.max))
    
    lines(years2,o2$missing,type='o',col='red')
    
    nonsite = 1-apply(o2$sources.years[,c('AWS.site','pluvio.site')],1,sum)

    lines(years2,nonsite,type='o',col='cyan',lty=3)
    
    title(paste(site,aggPeriod),outer=T)
  }
}



