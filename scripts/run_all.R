 # TO DO
# - phoenix
# - update github
# - manually check missing data periods - parafield airport pluvio

rm(list=ls())

setwd("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/scripts/")

source('settings.R')

# pluvio and AWS all years and plot both
# site_list = c('023034','023090','023083','023013')
# instrument_list = c('pluvio','AWS')
# plot.instrument_list = instrument_list
# plot.year.min = plot.year.max = NULL
# blend = F
# plot_linear = F
# x.index = 'year'
# # x.index = 'GMT'
# pdf_str = 'both'


# # blended pluvio and AWS
site_list = c('023034','023090','023013')
#site_list = c('023034')
instrument_list = c('pluvio','AWS')
plot.instrument_list = c('AWS_pluvio')
plot.year.min = 1978
plot.year.max = 2023
blend = T
plot_linear = T
#x.index = 'year'
x.index = 'GMT'
#pdf_str = 'AWS_pluvio'

#plot.year.max = 2019
#pdf_str = 'AWS_pluvio_2019'

# site_list = c('023034','023090','023013','023823')
# #site_list = c('023823')
# pdf_str = 'AWS_pluvio_Hindmarsh'

site_list = c('023034','023090','023083','023013')
pdf_str = 'AWS_pluvio_Edinburgh'


# # AWS
# site_list = c('023034','023090','023083','023013','023885')
# instrument_list = c('AWS')
# plot.instrument_list = c('AWS')
# plot.year.min = 2002
# plot.year.max = 2023
# blend = F
# plot_linear = T
# #x.index = 'year'
# x.index = 'GMT'
# pdf_str = 'AWS'

# # pluvio
# site_list = c('023034','023090','023083','023013',
#               '023343','024515','023801','023823')#,'023763')
# instrument_list = c('pluvio')
# plot.instrument_list = c('pluvio')
# plot.year.min = 1973
# plot.year.max = 2017
# blend = F
# plot_linear = T
# #x.index = 'year'
# x.index = 'GMT'
# pdf_str = 'pluvio'


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
aggPeriod_list = c('12 mins','30 mins','1 hour','3 hours','1 month')
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

load_raw_RData = T
load_processed_RData = T
load_agg_RData = T
load_annual_metrics = T

agg_data_thresh = 0.8
accum_handling = 'spread'
missing_year_thresh = 0.1
#metric_list = c('mean','max','P99','P99.9','EY1','EY3','EY6')
#metric_list = c('mean','max','P99','P99.9','EY3','EY6')
metric_list = c('mean','max','EY2','EY6')
#metric_list = c('mean','max')

blend_type = 'AWS_pluvio'

blend_processed_data = F

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

annual_metrics_list = agg_data_list = processed_data_list = blend_year_change = list()

for (site in site_list){

  cat(site,'\n')

  annual_metrics_list[[site]] = agg_data_list[[site]] = processed_data_list[[site]] = list()

  for (instrument in instrument_list){

    cat(instrument,'\n')

    annual_metrics_list[[site]][[instrument]] = agg_data_list[[site]][[instrument]] = processed_data_list[[site]][[instrument]] = list()

    if (!load_processed_RData){
      cat('loading data\n')
      raw_data = load_raw_data(site=site,instrument=instrument,
                               load_raw_RData=load_raw_RData,
                               data_dirname=data_dirname,
                               RData_dirname=RData_dirname) # matrix for pluvio, vector for aws
    } else {
      raw_data = list(raw_RData_fname = paste0(RData_dirname,instrument,'_',site,'.RData'))
      if (!file.exists(raw_data$raw_RData_fname)){raw_data=NULL}
    }

    if (!load_agg_RData){
      cat('processing data\n')
      # select years, get data in easy format, deal with QCs
      processed_data = process_raw_data(raw_data=raw_data,
                                        site=site,
                                        instrument=instrument,
                                        load_processed_RData=load_processed_RData,
                                        accum_handling=accum_handling,
                                        RData_dirname=RData_dirname)

    } else {
      if (is.null(raw_data)){
        processed_data=NULL
      } else {

        processed_RData_fname = strsplit(raw_data$raw_RData_fname,'.RData',fixed=T)[[1]]
        processed_RData_fname = paste0(processed_RData_fname,'_accumHandling.',accum_handling)
        processed_RData_fname = paste0(processed_RData_fname,'_processed.RData')
        processed_data = list(processed_RData_fname=processed_RData_fname)

      }

    }
    processed_data_list[[site]][[instrument]] = processed_data

#    if(blend){
    if(blend_processed_data){
        cat('blending processed data\n')

      if(instrument==instrument_list[length(instrument_list)]){

        if (blend_type=='AWS_pluvio'){

          p_pluvio = processed_data_list[[site]]$pluvio
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
          blend_year_change[[site]] = min(year_aws)
        }

        processed_data_list[[site]][[blend_type]] = p_blend

        #          annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = blend_metrics(annual_metrics_list[[site]],blend_type,aggPeriod)
      }
    }

    for (aggPeriod in aggPeriod_list){

      cat(aggPeriod,'\n')

      cat('aggregating data\n')
      agg_data = aggregate_data(processed_data=processed_data,
                                aggPeriod=aggPeriod,
                                load_agg_data=load_agg_data,
                                RData_dirname=RData_dirname,
                                agg_data_thresh=agg_data_thresh)

      agg_data_list[[site]][[instrument]][[aggPeriod]] = agg_data

      cat('calculating metrics\n')
      annual_metrics = calc_annual_metrics(agg_data=agg_data,
                                           metric_list=metric_list,
                                           load_annual_metrics=load_annual_metrics)

      annual_metrics_list[[site]][[instrument]][[aggPeriod]] = annual_metrics

      if(blend){
        cat('blending metrics\n')

        if(instrument==instrument_list[length(instrument_list)]){

          if (blend_type=='AWS_pluvio'){

            m_aws = annual_metrics_list[[site]]$AWS[[aggPeriod]]
            m_pluvio = annual_metrics_list[[site]]$pluvio[[aggPeriod]]

            a_pluvio = agg_data_list[[site]]$pluvio[[aggPeriod]]
            a_aws = agg_data_list[[site]]$AWS[[aggPeriod]]

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
              blend_year_change[[site]] = min(year_aws)

            }


          }

          annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = m_blend
          agg_data_list[[site]][[blend_type]][[aggPeriod]] = a_blend

          #annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = blend_metrics(annual_metrics_list[[site]],blend_type,aggPeriod)
        }
      }

    }



  }
}

instrument_list = c(instrument_list,blend_type)

#############################

cat('plotting\n')

plot.aggPeriod_list = aggPeriod_list[aggPeriod_list!='1 month']

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

pdf_fname = paste0(fig_dirname,'summary_',pdf_str,'_',x.index,'.pdf')

pdf(file=pdf_fname)


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
#           date_plot = as.POSIXct(dates_plot[y],origin= "1970-01-01",tz = 'GMT')
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





slopeArray = slopeArrayLow = slopeArrayHigh = pValArray = nPoints = array(dim=c(length(site_list),
                                     length(plot.aggPeriod_list),
                                     length(metric_list),
                                     length(plot.instrument_list)))
for (s in 1:length(site_list)){
  site = site_list[s]
  #  o[[site]] = list()
  #  pdf_fname = paste0(fig_dirname,'summary_',site,'.pdf')
  #  pdf(pdf_fname)
  for (a in 1:length(plot.aggPeriod_list)){
    aggPeriod = plot.aggPeriod_list[a]
    par(mfrow=c(4,2),mar=c(3,4,2.5,1),oma=c(1,1,3,1))
    o = plot_annual_metrics(annual_metrics_list=annual_metrics_list,
                            site=site,
                            aggPeriod=aggPeriod,
                            instrument_list=plot.instrument_list,
                            missing_year_thresh = missing_year_thresh,
                            year.min=plot.year.min,year.max=plot.year.max,
                            x.index=x.index,plot_linear = plot_linear)
    slopeArray[s,a,,] = o$slopeMat/o$metComboMeanVec
    pValArray[s,a,,] = o$pValMat
    nPoints[s,a,,] = o$nPoints
    slopeArrayLow[s,a,,] = o$slopeMatLow/o$metComboMeanVec
    slopeArrayHigh[s,a,,] = o$slopeMatHigh/o$metComboMeanVec

    # par(mfrow=c(2,3),mar=c(4,4,3,1))
    # xmetric = 'mean'
    # allMetrics = colnames(annual_metrics_list[[1]][[1]][[1]]$metrics)
    # yMetricList = allMetrics[!(allMetrics==xmetric)]
    # for (ymetric in yMetricList){
    #   plot_annual_metrics_cor(annual_metrics_list=annual_metrics_list,
    #                           xmetric=xmetric,
    #                           ymetric=ymetric,
    #                           instrument_list=instrument_list,
    #                           aggPeriod=aggPeriod,
    #                           missing_year_thresh=missing_year_thresh)
    # }
  }
  #  dev.off()
}



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


nYears = plot.year.max-plot.year.min+1

colData = 'lightblue'
colARR = 'salmon'

if (x.index=='GMT'){
  xlab = '%/degC'
  xlim = c(-20,70)
  #  xlim = c(-15,50)
} else if (x.index=='year'){
  xlim = c(-0.3,0.7)
  xlab = '%/year'
}

#  for (plot.instrument in plot.instrument_list){
#    i = which(plot.instrument == instrument_list)
for (i in 1:length(plot.instrument_list)){
  plot.instrument = plot.instrument_list[i]
  for (m in 1:length(metric_list)){
    metric = metric_list[m]
    #      par(mfrow=c(2,2),mar=c(5,4,2,1))
    par(mfrow=c(4,1),mar=c(3,5,2,1),oma=c(1,1,2,1))
    for (a in 1:length(plot.aggPeriod_list)){
      aggPeriod = plot.aggPeriod_list[a]
      #dat = slopeArray[,a,m,i]*100
      #cols = rep('grey',length(site_list))
      # cols[pValArray[,a,m,i]<0.25] = 'lightblue'
      # cols[pValArray[,a,m,i]<0.05] = 'blue'
      #labs = site_list
      # i1 = which ((nPoints[,a,m,i] / nYears ) < 0.8 )
      # labs[i1]=paste0(labs[i1],'*')
      # i2 = which ((nPoints[,a,m,i] / nYears ) < 0.9 )
      # labs[i2]=paste0(labs[i2],'*')

      # barplot(dat,main=plot.aggPeriod_list[a],
      #         col=cols,horiz = T,names.arg = labs,las=2,xlab=xlab,xlim=xlim)

      #browser()

      z = list()
      z$stats = 100*rbind(slopeArrayLow[,a,m,i],
                          slopeArrayLow[,a,m,i],
                          slopeArray[,a,m,i],
                          slopeArrayHigh[,a,m,i],
                          slopeArrayHigh[,a,m,i])
      z$names = site_list

      if (metric!='mean'){
        if (aggPeriod%in%c("12 mins","30 mins","1 hour")){
          low = 7
          med = 15
          high = 28
        } else if (aggPeriod=='3 hours'){
          med = approx(x=c(1,24),y = c(15,8),xout = 3)$y
          low = approx(x=c(1,24),y = c(7,2),xout = 3)$y
          high = approx(x=c(1,24),y = c(28,15),xout = 3)$y
        }
        z$stats = cbind(z$stats,c(low,low,med,high,high))
        z$names = c(z$names,'ARR')
      }
      bxp(z,horizontal = T,las=2,xlab='',ylim=xlim,main=plot.aggPeriod_list[a],
          boxfill=c(rep(colData,length(site_list)),colARR),cex.axis=0.75)
      mtext(side=1,text = xlab,cex=0.75,line=2)
    }
    title(paste(plot.instrument,metric_list[m]),outer=T)
  }
}

#############################################

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/monthly_HQ/rain.023721.monthly.txt'
d = read.table(fname,skip=1)

date_start = as.Date('1863/01/01')
date_end = as.Date('2023/10/01')
date0 = seq(date_start,date_end,by='months')

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

plot_double_mass = function(P1,date1,P2,date2,
                            year.min=NULL,year.max=NULL,
                            xlab,ylab,instrumentChange=NULL,blend_year_change=NULL){

  if (is.null(year.min)){year.min=-99999}
  if (is.null(year.max)){year.max=99999}

  year1 = as.integer(format(date1,'%Y'))
  year2 = as.integer(format(date2,'%Y'))

  year.min = max(year.min,min(year1),min(year2))
  year.max = min(year.max,max(year1),max(year2))

  print(year.min)
  print(year.max)

  keep1 = which((year1>=year.min)&(year1<=year.max))
  P1 = P1[keep1]
  date_keep = date1[keep1]

  keep2 = which((year2>=year.min)&(year2<=year.max))
  P2 = P2[keep2]

  Jan1 = which((format(date_keep,'%d/%m')=='01/01')&((as.integer(format(date_keep,'%Y'))%%5)==0))
  Lab = as.integer(format(date_keep,'%Y'))[Jan1]

  i_instrumentChange = which(format(date_keep,'%Y/%m')%in%format(instrumentChange$dates,'%Y/%m'))

  i_blend_year_change = c()
  if(!is.null(blend_year_change)){
    print(blend_year_change)
    if (!is.na(blend_year_change)){
      i_blend_year_change = min(which(as.integer(format(date_keep,'%Y'))==blend_year_change))
    }
  }


  # P1[is.na(P1)] = P2[is.na(P1)]
  # P2[is.na(P2)] = P1[is.na(P2)]
  #
  # P1[is.na(P1)] = P2[is.na(P2)] = 0.

  P2[is.na(P1)] = NA
  P1[is.na(P2)] = NA
  p_missing = length(which(is.na(P1)))/length(P1)

  P1[is.na(P1)] = P2[is.na(P2)] = 0

  cum1 = cumsum(P1)
  cum2 = cumsum(P2)

  plot(x=c(0,max(cum1)),y=c(0,max(cum2)),col='red',type='l',xlab=xlab,ylab=ylab)
  #lmfit = lm(cum2~cum1)
  #a = lmfit$coefficients[1]; b=lmfit$coefficients[2]
  #x = c(0,max(cum1))
  #y = a + b*x
  #plot(x=x,y=y,col='red',type='l',xlab=xlab,ylab=ylab)
  lines(cum1,cum2,type='l')
  if (length(Jan1)>0){
    points(cum1[Jan1],cum2[Jan1],col='black',cex=0.6)
    text(x=cum1[Jan1],y=cum2[Jan1],labels=Lab,cex=0.6,pos=4)
    points(x=cum1[i_instrumentChange],y=cum2[i_instrumentChange],col='blue',pch=15)
    if(!is.null(blend_year_change)){
      if (!is.na(blend_year_change)){
        points(x=cum1[i_blend_year_change],y=cum2[i_blend_year_change],col='green',pch=19)
      }
    }
  }
  legend('bottomright',c('observed','linear','change instrument','change source (pluvio->AWS'),
         col=c('black','red','blue','green'),
         pch=c(NA,NA,15,19),
         lty=c(1,1,NA,NA))

  title(paste0('Cummulative flow. ',year.min,'-',year.max, '. ', format(p_missing*100,digits=2),'% missing'))

}

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

instrumentChange = list()

####################################

instrumentChange[['023083']] = list(dates=c(as.Date('1979/10/11'),
                                            as.Date('1985/09/06'),
                                            as.Date('1993/05/04'),
                                            as.Date('1996/10/15'),
                                            as.Date('2000/05/16'),
                                            as.Date('2004/02/09')))

# 023083
#19930504   19961015 Rimco 7499 TBRG
#19961015   20000516 HS TB3A-0.2
#20000516   20040209 Rimco 8020 TBRG
#20040209   20240630 Rimco 7499 TBRG

# 11/OCT/1979 INSTALL Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 06/SEP/1985 REPLACE Pluviograph (Now Dines syphoning S/N - Unknown) Rainfall Intensity
# 04/MAY/1993 INSTALL Raingauge (Type Rimco 7499 TBRG S/N - 95-125) Surface Observations
# 15/OCT/1996 REMOVE Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 15/OCT/1996 REPLACE Raingauge (Now HS TB3A-0.2 S/N - 95-125) Rainfall Intensity
# 15/OCT/1996 REPLACE Raingauge (Now HS TB3A-0.2 S/N - 95-125) Surface Observations
# 15/OCT/1996 SHARE Raingauge (Type HS TB3A-0.2 S/N - 95-125) Rainfall Intensity
# 15/OCT/1996 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 95-125) Rainfall Intensity
# 15/OCT/1996 SHARE Raingauge (Type Rimco 8020 TBRG S/N - 78064) Rainfall Intensity
# 16/MAY/2000 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 78064) Rainfall Intensity
# 09/FEB/2004 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 68942) Rainfall Intensity
# 21/JAN/2019 UNSHARE Raingauge (Type Rimco 7499 TBRG S/N - 68942) Rainfall Intensity

# 01/JAN/1957 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - Unknown) Surface Observations
# 22/DEC/1999 REMOVE Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 19/MAR/1993 REPLACE Raingauge (Now 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 09/FEB/2004 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 68942) Surface Observations
# 16/MAY/2000 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 78064) Surface Observations

####################################

instrumentChange[['023090']] = list(dates=c(as.Date('1977/02/01'),
                                            as.Date('1992/10/26'),
                                            as.Date('1998/03/04'),
                                            as.Date('2000/05/02'),
                                            as.Date('2003/03/31'),
                                            as.Date('2006/03/02'),
                                            as.Date('2009/06/01'),
                                            as.Date('2010/03/15'),
                                            as.Date('2013/10/18')))
# 19921026   19980304 Unknown
# 19980304   20000502 Rimco 7499 TBRG
# 20000502   20030331 Rimco 8020 TBRG
# 20030331   20060302 Rimco 7499 TBRG
# 20060302   20090601 Rimco 7499 TBRG
# 20090601   20100315 Rimco 7499 TBRG
# 20100315   20200911 Rimco 7499 TBRG
# 20131018   20141203 HS-TB3/0.2/P

# 01/FEB/1977 INSTALL Pluviograph (Type Dines syphoning S/N - NONE) Rainfall Intensity
# 04/MAR/1998 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - CBM274) Rainfall Intensity
# 02/MAY/2000 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 78056) Rainfall Intensity
# 31/MAR/2003 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81169) Rainfall Intensity
# 02/MAR/2006 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81150) Rainfall Intensity
# 01/JUN/2009 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 497) Rainfall Intensity
# 26/JUN/2009 REMOVE Pluviograph (Type Dines syphoning S/N - NONE) Rainfall Intensity
# 15/MAR/2010 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 0509) Rainfall Intensity
# 18/OCT/2013 INSTALL Raingauge (Type HS-TB3/0.2/P S/N - 00015) Rainfall Intensity
# 03/DEC/2014 REMOVE Raingauge (Type HS-TB3/0.2/P S/N - 00015) Rainfall Intensity
# 11/DEC/2018 REMOVE Raingauge (Type Rimco 7499 TBRG S/N - 0509) Rainfall Intensity

# 17/FEB/1977 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 26/OCT/1992 INSTALL Raingauge (Type Unknown S/N - Unknown) Surface Observations
# 18/JUN/2015 REMOVE Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations

# 11/SEP/2020 REMOVE Raingauge (Type Rimco 7499 TBRG S/N - 0509) Surface Observations
# 15/MAR/2010 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 0509) Surface Observations
# 01/JUN/2009 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 497) Surface Observations
# 02/MAR/2006 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81150) Surface Observations
# 31/MAR/2003 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81169) Surface Observations
# 04/MAR/1998 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - CBM274) Surface Observations
# 26/MAR/1996 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 0509) Rainfall Intensity
# 26/MAR/1996 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 497) Rainfall Intensity
# 26/MAR/1996 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 81150) Rainfall Intensity
# 26/MAR/1996 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 81169) Rainfall Intensity
# 26/MAR/1996 SHARE Raingauge (Type Rimco 7499 TBRG S/N - CBM274) Rainfall Intensity
# 26/MAR/1996 SHARE Raingauge (Type Rimco 8020 TBRG S/N - 78056) Rainfall Intensity
# 26/MAR/1996 SHARE Raingauge (Type Unknown S/N - Unknown) Rainfall Intensity

####################################

instrumentChange[['023013']] = list(dates=c(as.Date('1972/08/16'),
                                            as.Date('1992/07/22'),
                                            as.Date('1999/10/18'),
                                            as.Date('2002/08/20'),
                                            as.Date('2003/01/30'),
                                            as.Date('2006/06/29')))

# 19920722   19991018 Rimco 7499 TBRG
# 19991018   20020820 Rimco TBRG (type unspecified)
# 20020820   20030130 Rimco 7499 TBRG
# 20030130   20060629 Rimco 7499 TBRG
# 20060629   20240630 Rimco 7499 TBRG

# 16/AUG/1972 INSTALL Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 21/JUL/1992 REMOVE Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 18/OCT/1999 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 68616) Rainfall Intensity
# 20/AUG/2002 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81169) Rainfall Intensity
# 30/JAN/2003 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81139) Rainfall Intensity
# 29/JUN/2006 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 80599) Rainfall Intensity

# 18/OCT/1999 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 313190) Rainfall Intensity
# 18/OCT/1999 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 81139) Rainfall Intensity
# 18/OCT/1999 SHARE Raingauge (Type Rimco 7499 TBRG S/N - 81169) Rainfall Intensity
# 18/OCT/1999 SHARE Raingauge (Type Rimco TBRG (type unspecified) S/N - 68616) Rainfall Intensity
# 22/AUG/2018 UNSHARE Raingauge (Type Rimco 7499 TBRG S/N - 80599) Rainfall Intensity

# 22/JUL/1992 INSTALL Raingauge (Type Rimco 7499 TBRG S/N - 313190) Surface Observations
# 29/JUN/2006 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 80599) Surface Observations
# 30/JAN/2003 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81139) Surface Observations
# 20/AUG/2002 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81169) Surface Observations
# 18/OCT/1999 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 68616) Surface Observations

####################################

instrumentChange[['023034']] = list(dates=c(as.Date('1967/01/01'),
                                            as.Date('1995/02/01'),
                                            as.Date('1998/10/06'),
                                            as.Date('2000/11/14'),
                                            as.Date('2002/12/17'),
                                            as.Date('2006/01/13')))
# 19950201   19981006 HS TB3A-0.2
# 19981006   19981209 Rimco 8020 TBRG
# 19981209   20001114 HS TB3A-0.2
# 20001114   20021216 Rimco 8020 TBRG
# 20021217   20060113 Rimco 7499 TBRG
# 20060113   20240630 Rimco 7499 TBRG

# 01/JAN/1967 INSTALL Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 30/APR/1998 REMOVE Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 06/OCT/1998 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 75521) Rainfall Intensity
# 09/DEC/1998 REPLACE Raingauge (Now HS TB3A-0.2 S/N - 96 -181) Rainfall Intensity
# 14/NOV/2000 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 78111) Rainfall Intensity
# 17/DEC/2002 INSTALL Raingauge (Type Rimco 7499 TBRG S/N - 82488) Rainfall Intensity
# 16/DEC/2002 REMOVE Raingauge (Type Rimco 8020 TBRG S/N - 78111) Rainfall Intensity
# 13/JAN/2006 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 87561) Rainfall Intensity

# 17/APR/1997 SHARE Raingauge (Type HS TB3A-0.2 S/N - 94-285) Rainfall Intensity
# 17/APR/1997 SHARE Raingauge (Type HS TB3A-0.2 S/N - 96 -181) Rainfall Intensity
# 17/APR/1997 SHARE Raingauge (Type Rimco 8020 TBRG S/N - 75521) Rainfall Intensity
# 17/APR/1997 SHARE Raingauge (Type Rimco 8020 TBRG S/N - 78111) Rainfall Intensity
# 30/AUG/2018 UNSHARE Raingauge (Type Rimco 7499 TBRG S/N - 87561) Rainfall Intensity

# 16/FEB/1955 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 17/DEC/2002 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 01/FEB/1995 INSTALL Raingauge (Type HS TB3A-0.2 S/N - 94-285) Surface Observations
# 18/DEC/2013 INSTALL Raingauge (Type HS-TB3/0.2/P S/N - 13-404) External Clients
# 19/MAR/2007 INSTALL Raingauge (Type Not Listed S/N - Unknown) External Clients
# 18/JUN/2007 INSTALL Raingauge (Type Not Listed S/N - Unknown) External Clients
# 22/MAR/1993 INSTALL Raingauge (Type Rimco 7499 TBRG S/N - 096) Flood Warning
# 17/DEC/2002 INSTALL Raingauge (Type Rimco 7499 TBRG S/N - 82488) Surface Observations
# 16/DEC/2002 REMOVE Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 31/DEC/2010 REMOVE Raingauge (Type Not Listed S/N - Unknown) External Clients
# 01/DEC/2011 REMOVE Raingauge (Type Not Listed S/N - Unknown) External Clients
# 10/AUG/2001 REMOVE Raingauge (Type Rimco 7499 TBRG S/N - 096) Flood Warning
# 06/MAR/2000 REMOVE Raingauge (Type Rimco 8020 TBRG S/N - 78111) Surface Observations
# 16/DEC/2002 REMOVE Raingauge (Type Rimco 8020 TBRG S/N - 78111) Surface Observations
# 09/DEC/1998 REPLACE Raingauge (Now HS TB3A-0.2 S/N - 96 -181) Surface Observations
# 13/JAN/2006 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 87561) Surface Observations
# 06/OCT/1998 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 75521) Surface Observations
# 14/NOV/2000 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 78111) Surface Observations
# 15/MAR/2000 SHARE Raingauge (Type HS TB3A-0.2 S/N - 94-285) Surface Observations
# 15/MAR/2000 SHARE Raingauge (Type HS TB3A-0.2 S/N - 96 -181) Surface Observations
# 15/MAR/2000 SHARE Raingauge (Type Rimco 8020 TBRG S/N - 75521) Surface Observations
# 15/MAR/2000 SHARE Raingauge (Type Rimco 8020 TBRG S/N - 78111) Surface Observations

####################################

instrumentChange[['023343']] = list(dates=c(as.Date('1958/04/10'),
                                            as.Date('1967/04/01'),
                                            as.Date('1997/02/25'),
                                            as.Date('2000/12/14'),
                                            as.Date('2001/11/13'),
                                            as.Date('2004/12/22'),
                                            as.Date('2012/11/20')))

# 19970225   20001214 HS TB3A-0.2
# 20001214   20011113 Rimco TBRG (type unspecified)
# 20011113   20041222 Rimco TBRG (type unspecified)
# 20041222   20121120 Rimco 7499 TBRG
# 20121120   20201008 Rimco 7499 TBRG

# 01/APR/1958 INSTALL Pluviograph (Type Unknown S/N - Unknown) Rainfall Intensity
# 01/APR/1967 REPLACE Pluviograph (Now Dines syphoning S/N - Unknown) Rainfall Intensity
# 25/FEB/1997 REMOVE Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 25/FEB/1997 INSTALL Raingauge (Type HS TB3A-0.2 S/N - 95-178) Rainfall Intensity
# 14/DEC/2000 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 314190) Rainfall Intensity
# 13/NOV/2001 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 70882) Rainfall Intensity
# 22/DEC/2004 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81129) Rainfall Intensity
# 20/NOV/2012 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 83287) Rainfall Intensity
# 08/OCT/2020 REMOVE Raingauge (Type Rimco 7499 TBRG S/N - 83287) Rainfall Intensity

# 01/MAR/1887 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - Unknown) Surface Observations
# 07/FEB/2020 REMOVE Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 25/SEP/1996 REPLACE Raingauge (Now 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations

####################################

instrumentChange[['024515']] = list(dates=c(as.Date('1973/01/01'),
                                            as.Date('1996/07/15'),
                                            as.Date('2000/10/04'),
                                            as.Date('2002/05/21'),
                                            as.Date('2005/04/11')))

# 19960715   20001004 HS TB3A-0.2
# 20001004   20020521 Rimco TBRG (type unspecified)
# 20020521   20050411 Rimco 7499 TBRG
# 20050411   20240630 Rimco 7499 TBRG

# 01/JAN/1973 INSTALL Pluviograph (Type Unknown S/N - Unknown) Rainfall Intensity
# 15/JUL/1996 INSTALL Raingauge (Type HS TB3A-0.2 S/N - 95-131) Rainfall Intensity
# 31/JUL/1996 REMOVE Pluviograph (Type Unknown S/N - Unknown) Rainfall Intensity
# 04/OCT/2000 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 72802) Rainfall Intensity
# 21/MAY/2002 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 82511) Rainfall Intensity
# 11/APR/2005 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 84598) Rainfall Intensity

# 01/AUG/1889 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations

####################################

instrumentChange[['023801']] = list(dates=c(as.Date('1972/10/04'),
                                            as.Date('1996/11/25'),
                                            as.Date('2001/01/08'),
                                            as.Date('2002/01/07'),
                                            as.Date('2002/04/12'),
                                            as.Date('2005/04/19'),
                                            as.Date('2018/03/21')))

# 19961125   20010108 HS TB3A-0.2
# 20010108   20020107 Rimco TBRG (type unspecified)
# 20020107   20020412 Rimco TBRG (type unspecified)
# 20020412   20050419 Rimco 7499 TBRG
# 20050419   20180321 Rimco 8020 TBRG

# 04/OCT/1972 INSTALL Pluviograph (Type Dines syphoning S/N - CMO 21) Rainfall Intensity
# 01/JAN/1973 INSTALL Pluviograph (Type Casella 8" pluviometer S/N - Unknown) Rainfall Intensity
# 25/NOV/1996 REMOVE Pluviograph (Type Casella 8" pluviometer S/N - Unknown) Rainfall Intensity
# 25/NOV/1996 REMOVE Pluviograph (Type Dines syphoning S/N - CMO 21) Rainfall Intensity
# 25/NOV/1996 INSTALL Raingauge (Type HS TB3A-0.2 S/N - 96/163) Rainfall Intensity
# 08/JAN/2001 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 580) Rainfall Intensity
# 12/APR/2002 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81145) Rainfall Intensity
# 07/JAN/2002 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - 444) Rainfall Intensity
# 19/APR/2005 REPLACE Raingauge (Now Rimco 8020 TBRG S/N - 75520) Rainfall Intensity
# 21/MAR/2018 REMOVE Raingauge (Type Rimco 8020 TBRG S/N - 75520) Rainfall Intensity

# 21/MAR/2018 REMOVE Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 01/OCT/1967 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 21/MAR/2018 INSTALL Raingauge (Type Rimco 7499 TBRG S/N - 88737) Flood Warning


####################################

instrumentChange[['023823']] = list(dates=c(as.Date('1973/03/28'),
                                            as.Date('1996/11/29'),
                                            as.Date('1999/08/06'),
                                            as.Date('2002/01/03'),
                                            as.Date('2005/09/06')))

# 19961129   19990806 HS TB3A-0.2
# 19990806   20020103 Rimco TBRG (type unspecified)
# 20020103   20050906 Rimco 7499 TBRG
# 20050906   20240630 Rimco 7499 TBRG

# 28/MAR/1973 INSTALL Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 29/NOV/1996 INSTALL Raingauge (Type HS TB3A-0.2 S/N - 96/186) Rainfall Intensity
# 30/NOV/1996 REMOVE Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 03/JAN/2002 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81144) Rainfall Intensity
# 06/SEP/2005 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 84658) Rainfall Intensity

# 01/JAN/1936 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - Unknown) Surface Observations
# 30/JUL/1991 REPLACE Raingauge (Now 203 mm (8in) - 200mm capacity S/N - NONE) Surface Observations
# 01/MAR/1973 REPLACE Raingauge (Now 203 mm (8in) - 200mm capacity S/N - Unknown) Surface Observations

####################################

instrumentChange[['023763']] = list(dates=c(as.Date('1970/10/19'),
                                            as.Date('1978/06/14'),
                                            as.Date('1983/01/04'),
                                            as.Date('1996/06/02'),
                                            as.Date('1998/11/20'),
                                            as.Date('2000/05/17'),
                                            as.Date('2003/09/24'),
                                            as.Date('2013/01/08'),
                                            as.Date('2021/08/11')))

# 19960602   19981120 HS TB3A-0.2
# 19981120   20000517 HS TB3A-0.2
# 20000517   20030924 Rimco TBRG (type unspecified)
# 20030924   20130108 Rimco 7499 TBRG
# 20130108   20210811 Rimco 7499 TBRG

# 19/OCT/1970 INSTALL Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 14/JUN/1978 REPLACE Pluviograph (Now Dines syphoning S/N - 215) Rainfall Intensity
# 04/JAN/1983 REPLACE Pluviograph (Now Dines syphoning S/N - Unknown) Rainfall Intensity
# 02/JUN/1996 REMOVE Pluviograph (Type Dines syphoning S/N - Unknown) Rainfall Intensity
# 02/JUN/1996 INSTALL Raingauge (Type HS TB3A-0.2 S/N - 96-180) Rainfall Intensity
# 20/NOV/1998 REPLACE Raingauge (Now HS TB3A-0.2 S/N - 96-303) Rainfall Intensity
# 17/MAY/2000 REPLACE Raingauge (Now Rimco TBRG (type unspecified) S/N - NONE) Rainfall Intensity
# 24/SEP/2003 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 82409) Rainfall Intensity
# 08/JAN/2013 REPLACE Raingauge (Now Rimco 7499 TBRG S/N - 81129) Rainfall Intensity
# 11/AUG/2021 REMOVE Raingauge (Type Rimco 7499 TBRG S/N - 81129) Rainfall Intensity

# 01/SEP/1954 INSTALL Raingauge (Type 203 mm (8in) - 200mm capacity S/N - Unknown) Surface Observations
# 02/JUN/1996 REMOVE Raingauge (Type 203 mm (8in) - 200mm capacity S/N - Unknown) Surface Observations

####################################

aggPeriod = '1 month'
for (instrument in plot.instrument_list){
  par(mfrow=c(1,1),mar=c(4,4,1,1))
  for (site in site_list){
  #  for (site in '023083'){
      a1 = agg_data_list[[site]][[instrument]][[aggPeriod]]
    date1 = a1$date
    P1 = a1$P
    plot_double_mass(P1=P0,P2=P1,date1 = date0,date2 = date1,
                     year.min = plot.year.min,year.max = plot.year.max,
                     instrumentChange=instrumentChange[[site]],
                     blend_year_change=blend_year_change[[site]],
                     xlab='Happy Valley HQ site (023721)',
                     ylab=paste0(site_labels[[site]],' (',site,') - ',instrument))
  }
}


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
