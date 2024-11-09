# to plot
#
# results - both year, GMT
# 1. time series metrics 
# 2. boxplots metrics
# 3. timeseries seas
# 4. boxplots seas
#
# checks
# 1. double mass
# 2. monthly HQ
# 3. corr aws/pluvio
# 4. rainfall all metric times
# 5. check metrics that use infilled data
#
# repeat everything with no removed data, and including Lenswood, Edinburgh


rm(list=ls())

setwd('C:/Users/a1065639/Work/2024_GoyderClimateChangeSARainfall/scripts/')
source('settings.R')

Instrument_list = c('pluvio','AWS')
AggPeriod_list = c('12 mins','30 mins','1 hour','3 hours','1 month')
Agg_data_thresh = 0.8; Accum_handling = 'spread'
Metric_list = c('mean','max','EY2','EY6')
Plot.year.min = 1978; Plot.year.max = 2023
# Blend = T; Blend_type = 'AWS_pluvio'; Blend_processed_data = F
#Plot_linear = T
#X.index = 'year'
#X.index = 'GMT'
Missing_year_thresh = 0.01; Nonsite_year_thresh = 0.1

Combine_sources_sites = T
Plot.instrument_list = c('combo_sources_sites')

############################

Site_list = c('023034','023090','023013','023823','023824')
#Site_list = c('023823','023824')
NearbySite_list = list('023034'='023090',
                       '023090'='023034',
                       '023013'='023090',
                       '023823'='023824',
                       '023824'='023823')
Site_list_plot = Site_list[1:4]
Pdf_str = 'combo_sources_sites'

# AggPeriod_list = c('30 mins')
# Metric_list = c('max')
# Site_list = c('023013')
# NearbySite_list = list('023034'='023090',
#                        '023090'='023034',
#                        '023013'='023090',
#                        '023823'='023824',
#                        '023824'='023823')
# Site_list_plot = Site_list[1:4]
# Pdf_str = 'combo_sources_sites_tmp'

############################

# Site_list = c('023034','023090','023013','023083','023823','023824')
# NearbySite_list = list('023034'='023090',
#                        '023090'='023034',
#                        '023013'='023090',
#                        '023083'='023013',
#                        '023823'='023824',
#                        '023824'='023823')
# Site_list_plot = Site_list[1:5]
# Period.remove = NULL
# RData_dirname = paste0(dirname,'RData.noRemoveData/')
# Fig_dirname = paste0(dirname,'figures.noRemoveData/')
# Pdf_str = 'combo_sources_sites_Edinburgh_noRemoveData'

############################

Instrument_list = c('AWS')
# Site_list = c('023034', # 'Adelaide Airport'
#               '023090', # 'Kent Town'
#               '023083', # 'Edinburgh RAAF'
#               '023013', # 'Parafield Airport'
#               '023885', # 'Noarlunga'
#               '023000', # 'West Terrace'
#               '023842' # 'Mount Lofty'
#               )

# Site_list = c('023034', # 'Adelaide Airport'
#               '023013' # 'Parafield Airport'
#               )
# 
# AggPeriod_list = c('5 mins','10 mins')
# 
# Combine_sources_sites = F
# RData_dirname = paste0(dirname,'RData.AWS.7stations/')

############################

Load_raw_RData = T
Load_processed_RData = T
Load_agg_RData = T
Load_annual_metrics = T

############################

#Annual_metrics_list = Agg_data_list = Processed_data_list = Blend_year_change = list()
Annual_metrics_list = Agg_data_list = Processed_data_list = list()

for (Site in Site_list){
  
  cat(Site,'\n')
  
  Annual_metrics_list[[Site]] = Agg_data_list[[Site]] = Processed_data_list[[Site]] = list()
  
  for (Instrument in Instrument_list){
    
    cat(Instrument,'\n')
    
    Annual_metrics_list[[Site]][[Instrument]] = Agg_data_list[[Site]][[Instrument]] = Processed_data_list[[Site]][[Instrument]] = list()
    
    # if (!Load_processed_RData){
    cat('loading data\n')
    Raw_data = load_raw_data(site=Site,instrument=Instrument,
                             load_raw_RData=Load_raw_RData,
                             data_dirname=Data_dirname,
                             rData_dirname=RData_dirname) # matrix for pluvio, vector for aws
    # } else {
    #   Raw_data = list(raw_RData_fname = paste0(RData_dirname,Instrument,'_',Site,'.RData'))
    #   if (!file.exists(Raw_data$raw_RData_fname)){Raw_data=NULL}
    # }
    
    # if (!Load_agg_RData){
    cat('processing data\n')
    #   # select years, get data in easy format, deal with QCs
    Processed_data = process_raw_data(raw_data=Raw_data,
                                      site=Site,
                                      instrument=Instrument,
                                      load_processed_RData=Load_processed_RData,
                                      accum_handling=Accum_handling,
                                      period.remove=Period.remove)
    
    Processed_data_list[[Site]][[Instrument]] = Processed_data
    
    
    # } else {
    #   if (is.null(Raw_data)){
    #     Processed_data=NULL
    #   } else {
    # 
    #     processed_RData_fname = strsplit(Raw_data$raw_RData_fname,'.RData',fixed=T)[[1]]
    #     processed_RData_fname = paste0(processed_RData_fname,'_accumHandling.',Accum_handling)
    #     processed_RData_fname = paste0(processed_RData_fname,'_processed.RData')
    #     Processed_data = list(processed_RData_fname=processed_RData_fname)
    # 
    #   }
    #
    
    #}
    
    # Processed_data_list[[Site]][[Instrument]] = Processed_data
    
    #    if(blend){
    # if(Blend_processed_data){
    #     cat('blending processed data\n')
    # 
    #   if(Instrument==Instrument_list[length(Instrument_list)]){
    # 
    #     if (Blend_type=='AWS_pluvio'){
    # 
    #       p_pluvio = Processed_data_list[[Site]]$pluvio
    #       if (is.null(p_pluvio$date)){
    #         load(p_pluvio$processed_RData_fname)
    #         p_pluvio = processed_data
    #       }
    #       p_aws = processed_data_list[[site]]$AWS
    #       if (is.null(p_aws$date)){
    #         load(p_aws$processed_RData_fname)
    #         p_aws = processed_data
    #       }
    #       date_pluvio = p_pluvio$date
    #       date_aws = p_aws$date
    #       year_pluvio = as.integer(format(date_pluvio,'%Y'))
    #       year_aws = as.integer(format(date_aws,'%Y'))
    #       keep_pluvio = which(year_pluvio < min(year_aws))
    #       # p_blend = p_aws
    #       # p_blend$date = c(p_pluvio$date[keep_pluvio],p_blend$date)
    #       # p_blend$P = c(p_pluvio$P[keep_pluvio],p_blend$P)
    #       p_blend = list()
    #       p_blend$date = c(p_pluvio$date[keep_pluvio],p_aws$date)
    #       p_blend$P = c(p_pluvio$P[keep_pluvio],p_aws$P)
    #       p_blend$accPeriod = c(p_pluvio$accPeriod[keep_pluvio],p_aws$accPeriod)
    #       Blend_year_change[[Site]] = min(year_aws)
    #     }
    # 
    #     Processed_data_list[[Site]][[Blend_type]] = p_blend
    # 
    #     #          annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = blend_metrics(annual_metrics_list[[site]],blend_type,aggPeriod)
    #   }
    # }
    
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
      
      # if(Blend){
      #   cat('blending metrics\n')
      # 
      #   if(Instrument==Instrument_list[length(Instrument_list)]){
      # 
      #     if (Blend_type=='AWS_pluvio'){
      # 
      #       m_aws = Annual_metrics_list[[Site]]$AWS[[AggPeriod]]
      #       m_pluvio = Annual_metrics_list[[Site]]$pluvio[[AggPeriod]]
      # 
      #       a_pluvio = Agg_data_list[[Site]]$pluvio[[AggPeriod]]
      #       a_aws = Agg_data_list[[Site]]$AWS[[AggPeriod]]
      # 
      #       if (is.null(m_aws)){
      #         m_blend = m_pluvio
      #         a_blend = a_pluvio
      #       } else if (is.null(m_pluvio)){
      #         m_blend = m_aws
      #         a_blend = a_aws
      #       } else {
      #         year_aws = m_aws$year
      #         year_pluvio = m_pluvio$year
      #         keep_pluvio = which(year_pluvio < min(year_aws))
      #         # m_blend = m_aws
      #         # m_blend$year = c(m_pluvio$year[keep_pluvio],m_blend$year)
      #         # m_blend$metrics = rbind(m_pluvio$metrics[keep_pluvio,],m_blend$metrics)
      #         # m_blend$metrics.dates = rbind(m_pluvio$metrics.dates[keep_pluvio,],m_blend$metrics.dates)
      #         # m_blend$missing = c(m_pluvio$missing[keep_pluvio],m_blend$missing)
      #         m_blend = list()
      #         m_blend$year = c(m_pluvio$year[keep_pluvio],m_aws$year)
      #         m_blend$metrics = rbind(m_pluvio$metrics[keep_pluvio,],m_aws$metrics)
      #         m_blend$metrics.dates = rbind(m_pluvio$metrics.dates[keep_pluvio,],m_aws$metrics.dates)
      #         m_blend$missing = c(m_pluvio$missing[keep_pluvio],m_aws$missing)
      # 
      #         date_pluvio = a_pluvio$date
      #         date_aws = a_aws$date
      #         year_pluvio = as.integer(format(date_pluvio,'%Y'))
      #         year_aws = as.integer(format(date_aws,'%Y'))
      #         keep_pluvio = which(year_pluvio < min(year_aws))
      #         # a_blend = a_aws
      #         # a_blend$date = c(a_pluvio$date[keep_pluvio],a_blend$date)
      #         # a_blend$P = c(a_pluvio$P[keep_pluvio],a_blend$P)
      #         a_blend = list()
      #         a_blend$date = c(a_pluvio$date[keep_pluvio],a_aws$date)
      #         a_blend$P = c(a_pluvio$P[keep_pluvio],a_aws$P)
      #         Blend_year_change[[Site]] = min(year_aws)
      # 
      #       }
      # 
      # 
      #     }
      # 
      #     Annual_metrics_list[[Site]][[Blend_type]][[AggPeriod]] = m_blend
      #     Agg_data_list[[Site]][[Blend_type]][[AggPeriod]] = a_blend
      # 
      #     #annual_metrics_list[[site]][[blend_type]][[aggPeriod]] = blend_metrics(annual_metrics_list[[site]],blend_type,aggPeriod)
      #   }
      # }
      
    }
    
  }
    
}

if (Combine_sources_sites){
  cat('merging agg data multiple sources/sites\n')
  for (Site in Site_list){
    print(Site)
    for (AggPeriod in AggPeriod_list){
      print(AggPeriod)
      ##########
      
      agg_RData_fname = paste0(RData_dirname,'combo_sources_sites_',Site,
                               '_aggPeriod.',gsub(" ", "", AggPeriod),
                               '_agg.RData')
      if (Load_agg_RData){
        load(agg_RData_fname)
      } else {
        Combo_aggData = combine_sites_sources(agg_data_list=Agg_data_list,
                                            site=Site,
                                            aggPeriod=AggPeriod,
                                            plot.year.min=Plot.year.min,
                                            plot.year.max=Plot.year.max,
                                            rData_dirname=RData_dirname,
                                            accum_handling=Accum_handling,
                                            agg_data_thresh=Agg_data_thresh,
                                            nearbySite_list=NearbySite_list)
        save(file=agg_RData_fname,Combo_aggData)
      }
      Agg_data_list[[Site]][['combo_sources_sites']][[AggPeriod]]  = Combo_aggData
      
      annual_metrics_RData_fname = paste0(RData_dirname,'combo_sources_sites_',Site,
                                          '_aggPeriod.',gsub(" ", "", AggPeriod),
                                          '_annual_metrics.RData')
      if (Load_annual_metrics){
        load(annual_metrics_RData_fname)
      } else {
        Combo_metrics = calc_annual_metrics_core(agg_data=Combo_aggData,
                                                 metric_list=Metric_list,calc_seas_metrics = T)
        save(file=annual_metrics_RData_fname,Combo_metrics)
      }
      Annual_metrics_list[[Site]][['combo_sources_sites']][[AggPeriod]] = Combo_metrics

      ##########
      
      agg_RData_fname = paste0(RData_dirname,'combo_AWS_sites_',Site,
                               '_aggPeriod.',gsub(" ", "", AggPeriod),
                               '_agg.RData')
      
      if (Load_agg_RData){
        load(agg_RData_fname)
      } else {
        Combo_aggData = combine_sites_sources(agg_data_list=Agg_data_list,
                                              site=Site,
                                              aggPeriod=AggPeriod,
                                              plot.year.min=Plot.year.min,
                                              plot.year.max=Plot.year.max,
                                              rData_dirname=RData_dirname,
                                              accum_handling=Accum_handling,
                                              agg_data_thresh=Agg_data_thresh,
                                              nearbySite_list=NearbySite_list,
                                              usePluvio=F)
        save(file=agg_RData_fname,Combo_aggData)
      }
      Agg_data_list[[Site]][['combo_AWS_sites']][[AggPeriod]]  = Combo_aggData
      
      annual_metrics_RData_fname = paste0(RData_dirname,'combo_AWS_sites_',Site,
                                          '_aggPeriod.',gsub(" ", "", AggPeriod),
                                          '_annual_metrics.RData')
      if (Load_annual_metrics){
        load(annual_metrics_RData_fname)
      } else {
        Combo_metrics = calc_annual_metrics_core(agg_data=Combo_aggData,
                                                 metric_list=Metric_list)
        save(file=annual_metrics_RData_fname,Combo_metrics)
      }
      Annual_metrics_list[[Site]][['combo_AWS_sites']][[AggPeriod]] = Combo_metrics
      
      ##########
      
      agg_RData_fname = paste0(RData_dirname,'combo_pluvio_sites_',Site,
                               '_aggPeriod.',gsub(" ", "", AggPeriod),
                               '_agg.RData')
      
      if (Load_agg_RData){
        load(agg_RData_fname)
      } else {
        Combo_aggData = combine_sites_sources(agg_data_list=Agg_data_list,
                                              site=Site,
                                              aggPeriod=AggPeriod,
                                              plot.year.min=Plot.year.min,
                                              plot.year.max=Plot.year.max,
                                              rData_dirname=RData_dirname,
                                              accum_handling=Accum_handling,
                                              agg_data_thresh=Agg_data_thresh,
                                              nearbySite_list=NearbySite_list,
                                              useAWS=F)
        save(file=agg_RData_fname,Combo_aggData)
      }
      Agg_data_list[[Site]][['combo_pluvio_sites']][[AggPeriod]]  = Combo_aggData
      
      annual_metrics_RData_fname = paste0(RData_dirname,'combo_pluvio_sites_',Site,
                                          '_aggPeriod.',gsub(" ", "", AggPeriod),
                                          '_annual_metrics.RData')
      if (Load_annual_metrics){
        load(annual_metrics_RData_fname)
      } else {
        Combo_metrics = calc_annual_metrics_core(agg_data=Combo_aggData,
                                                 metric_list=Metric_list)
        save(file=annual_metrics_RData_fname,Combo_metrics)
      }
      Annual_metrics_list[[Site]][['combo_pluvio_sites']][[AggPeriod]] = Combo_metrics

      ##########
      
      
    }
  }
}

pause

#instrument_list = c(Instrument_list,Blend_type,'combo_sources_sites')
instrument_list = c(Instrument_list,'combo_sources_sites','combo_AWS_sites','combo_pluvio_sites')
#############################

cat('plotting\n')

#############################
# cat('test gaussianity of residuals\n')
# Instrument = 'combo_sources_sites'
# for (m in 1:4){
#   Metric = Metric_list[m]
# #  cat(Metric,'\n')
#   for (AggPeriod in AggPeriod_list[1:4]){
# #    cat(AggPeriod,'\n')
#     for (Site in Site_list[1:4]){
# #      cat(Site,'\n')
#       y = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]]$all$metrics[,m]
#       y = y[!is.na(y)]
#       y = (y-mean(y))/sd(y)
#       pval = ks.test(y,'pnorm')$p.value
#       #pval = shapiro.test(y)$p.value
#       if (pval<0.05){
#         cat(Metric,AggPeriod,Site,pval,'\n')
#       }
#       #print(st)
#     }
#   }
# }

#############################


Pdf_fname = paste0(Fig_dirname,'summary_',Pdf_str,'.pdf')
pdf(file=Pdf_fname)

#Pdf_fname = paste0(Fig_dirname,'summary_',Pdf_str,'_square.pdf')
#pdf(file=Pdf_fname,width = 6.5,height = 6.5)


Instrument = 'combo_sources_sites'
Plot.aggPeriod_list = AggPeriod_list[AggPeriod_list!='1 month']

###############################
#plot metrics vs year
cat('metrics vs year\n')

X.index='year'
yNorm=F

Plot.aggPeriod_list_here = AggPeriod_list[1:5]
Metric_list_here = Metric_list

par(mfcol=c(6,2),mar=c(2,4,2,1),oma=c(1,1,4,1))
o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                  site_list=Site_list_plot,
                                  plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                  metric_list=Metric_list_here,
                                  instrument=Instrument,
                                  missing_year_thresh=Missing_year_thresh,
                                  nonsite_year_thresh=Nonsite_year_thresh,
                                  x.index=X.index,
                                  yNorm=yNorm,
                                  plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                  site_labels=Site_labels,
                                  plotMissing=T)


Plot.aggPeriod_list_here = AggPeriod_list[c(1,4)]
Metric_list_here = Metric_list[2:4]

par(mfcol=c(3,2),mar=c(3,5,2,1),oma=c(1,1,4,1))
o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                  site_list=Site_list_plot,
                                  plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                  metric_list=Metric_list_here,
                                  instrument=Instrument,
                                  missing_year_thresh=Missing_year_thresh,
                                  nonsite_year_thresh=Nonsite_year_thresh,
                                  x.index=X.index,
                                  yNorm=yNorm,
                                  plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                  site_labels=Site_labels,
                                  plotMissing=F)

Plot.aggPeriod_list_here = AggPeriod_list[c(1)]
Metric_list_here = Metric_list[1]

par(mfcol=c(3,2),mar=c(3,5,2,1),oma=c(1,1,4,1))
o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                  site_list=Site_list_plot,
                                  plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                  metric_list=Metric_list_here,
                                  instrument=Instrument,
                                  missing_year_thresh=Missing_year_thresh,
                                  nonsite_year_thresh=Nonsite_year_thresh,
                                  x.index=X.index,
                                  yNorm=yNorm,
                                  plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                  site_labels=Site_labels,
                                  plotMissing=F)

#####################

Plot.aggPeriod_list_here = AggPeriod_list[1:4]
Metric_list_here = Metric_list[2:4]

par(mfrow=c(4,3),mar=c(2,4,2,1),oma=c(1,1,4,1))
o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                  site_list=Site_list_plot,
                                  plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                  metric_list=Metric_list_here,
                                  instrument=Instrument,
                                  missing_year_thresh=Missing_year_thresh,
                                  nonsite_year_thresh=Nonsite_year_thresh,
                                  x.index=X.index,
                                  yNorm=yNorm,
                                  plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                  site_labels=Site_labels,
                                  plotMissing=F)

Plot.aggPeriod_list_here = AggPeriod_list[1:4]
Metric_list_here = Metric_list[1]

par(mfrow=c(4,3),mar=c(2,4,2,1),oma=c(1,1,4,1))
o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                  site_list=Site_list_plot,
                                  plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                  metric_list=Metric_list_here,
                                  instrument=Instrument,
                                  missing_year_thresh=Missing_year_thresh,
                                  nonsite_year_thresh=Nonsite_year_thresh,
                                  x.index=X.index,
                                  yNorm=yNorm,
                                  plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                  site_labels=Site_labels,
                                  plotMissing=F)


#####################
# plot boxes GMT slope
cat('boxes GMT slope\n')

X.index='GMT'
yNorm=T
Plot.aggPeriod_list_here = AggPeriod_list[1:4]

par(mfrow=c(3,2))
o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                  site_list=Site_list_plot,
                                  plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                  metric_list=Metric_list,
                                  instrument=Instrument,
                                  missing_year_thresh=Missing_year_thresh,
                                  nonsite_year_thresh=Nonsite_year_thresh,
                                  x.index=X.index,
                                  yNorm=yNorm,
                                  plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                  site_labels=Site_labels,
                                  plotMissing=T,plotType='resids')

plot_trends_boxes_new(x.index=X.index,
                      instrument=Instrument,
                      metric_list=Metric_list,
                      plot.aggPeriod_list=Plot.aggPeriod_list_here,
                      slopeArrayLow=o$slopeArrayLow,
                      slopeArray=o$slopeArray,
                      slopeArrayHigh=o$slopeArrayHigh,
                      site_list=Site_list_plot)

plot_trends_boxes_new(x.index=X.index,
                      instrument=Instrument,
                      metric_list=Metric_list,
                      plot.aggPeriod_list=Plot.aggPeriod_list_here,
                      slopeArrayLow=o$slopeArrayLow90,
                      slopeArray=o$slopeArray,
                      slopeArrayHigh=o$slopeArrayHigh90,
                      site_list=Site_list_plot)
#####################
# plot average slope - summary plot
cat('average slope - summary plot\n')

plot_ave_slope(o$slopeArray)
title('All sites')

plot_ave_slope(o$slopeArray,cSel=1)
title(Site_labels[[Site_list[1]]])

plot_ave_slope(o$slopeArray,cSel=2)
title(Site_labels[[Site_list[2]]])

plot_ave_slope(o$slopeArray,cSel=3)
title(Site_labels[[Site_list[3]]])

plot_ave_slope(o$slopeArray,cSel=4)
title(Site_labels[[Site_list[4]]])

#####################
# plot boxes GMT slope
cat('seas boxes GMT slope\n')

X.index='GMT'
yNorm=T
Plot.aggPeriod_list_here = AggPeriod_list[1:4]

for (seas in c('summer','autumn','winter','spring')){
  par(mfrow=c(3,2))
  o = plot_annual_metrics_multi_new(annual_metrics_list=Annual_metrics_list,
                                    site_list=Site_list_plot,
                                    plot.aggPeriod_list=Plot.aggPeriod_list_here,
                                    metric_list=Metric_list,
                                    instrument=Instrument,
                                    missing_year_thresh=Missing_year_thresh,
                                    nonsite_year_thresh=Nonsite_year_thresh,
                                    x.index=X.index,
                                    yNorm=yNorm,
                                    plot.year.min=Plot.year.min,plot.year.max=Plot.year.max,
                                    site_labels=Site_labels,
                                    plotMissing=T,
                                    seas = seas)

  plot_trends_boxes_new(x.index=X.index,
                        instrument=Instrument,
                        metric_list=Metric_list,
                        plot.aggPeriod_list=Plot.aggPeriod_list_here,
                        slopeArrayLow=o$slopeArrayLow,
                        slopeArray=o$slopeArray,
                        slopeArrayHigh=o$slopeArrayHigh,
                        site_list=Site_list_plot,title_str=seas)
  

}

# #############################
# # timing of metrics
# cat('timing of metrics\n')
# 
# Metric_list_here = c('EY1','EY2','EY3','EY4','EY5','EY6')
# #winterMonths = c(5,6,7,8,9,10)
# winterMonths = c(6,7,8,9,10,11)
# 
# ##########
# 
# X.index='year'
# 
# par(mfrow=c(4,4),mar=c(3,3,2,1))
# o = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# 
# SeasSlope=o$slope;SeasSlopeLow=o$slopeLow;SeasSlopeHigh=o$slopeHigh
# 
# ##########
# 
# X.index='GMT'
# Metric_list_here = c('EY1','EY2','EY3','EY4','EY5','EY6')
# 
# par(mfrow=c(4,4),mar=c(3,3,2,1))
# o_EY1_EY6_GMT = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# title('EY1-EY6',outer=T)
# 
# SeasSlope=o_EY1_EY6_GMT$slope;SeasSlopeLow=o_EY1_EY6_GMT$slopeLow;SeasSlopeHigh=o_EY1_EY6_GMT$slopeHigh
# plot_seas_boxes(slope=SeasSlope,
#                 slopeLow=SeasSlopeLow,
#                 slopeHigh=SeasSlopeHigh,
#                 site_list=Site_list_plot,
#                 site_labels=Site_labels,
#                 aggPeriod_list=Plot.aggPeriod_list,ylim=c(-0.5,0.5))
# title('EY1-EY6',outer=T)
# 
# ##########
# 
# X.index='GMT'
# Metric_list_here = c('EY1')
# 
# par(mfrow=c(4,4),mar=c(3,3,2,1))
# o_EY1_GMT = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# title('EY1',outer=T)
# 
# SeasSlope=o_EY1_GMT$slope;SeasSlopeLow=o_EY1_GMT$slopeLow;SeasSlopeHigh=o_EY1_GMT$slopeHigh
# plot_seas_boxes(slope=SeasSlope,
#                 slopeLow=SeasSlopeLow,
#                 slopeHigh=SeasSlopeHigh,
#                 site_list=Site_list_plot,
#                 site_labels=Site_labels,
#                 aggPeriod_list=Plot.aggPeriod_list,ylim=c(-0.5,0.5))
# title('EY1',outer=T)
# 
# ##########
# 
# # X.index='GMT'
# # Metric_list_here = c('EY1','EY2')
# # 
# # par(mfrow=c(4,4),mar=c(3,3,2,1))
# # o_EY1_EY2_GMT = calc_seas(site_list=Site_list_plot,
# #               aggPeriod_list=Plot.aggPeriod_list,
# #               agg_data_list=Agg_data_list,
# #               instrument=Instrument,
# #               metric_list=Metric_list_here,
# #               winterMonths=winterMonths,
# #               missing_year_thresh=Missing_year_thresh,
# #               nonsite_year_thresh=Nonsite_year_thresh,
# #               x.index=X.index,
# #               plot.year.min=Plot.year.min,
# #               plot.year.max=Plot.year.max,
# #               ylim=c(0,1))
# # title('EY1-EY2',outer=T)
# # 
# # SeasSlope=o_EY1_EY2_GMT$slope;SeasSlopeLow=o_EY1_EY2_GMT$slopeLow;SeasSlopeHigh=o_EY1_EY2_GMT$slopeHigh
# # plot_seas_boxes(slope=SeasSlope,
# #                 slopeLow=SeasSlopeLow,
# #                 slopeHigh=SeasSlopeHigh,
# #                 site_list=Site_list_plot,
# #                 site_labels=Site_labels,
# #                 aggPeriod_list=Plot.aggPeriod_list)
# # title('EY1-EY2',outer=T)
# 
# ##########
# 
# X.index='GMT'
# Metric_list_here = c('EY1','EY2','EY3')
# 
# par(mfrow=c(4,4),mar=c(3,3,2,1))
# o_EY1_EY3_GMT = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# title('EY1-EY3',outer=T)
# 
# SeasSlope=o_EY1_EY3_GMT$slope;SeasSlopeLow=o_EY1_EY3_GMT$slopeLow;SeasSlopeHigh=o_EY1_EY3_GMT$slopeHigh
# plot_seas_boxes(slope=SeasSlope,
#                 slopeLow=SeasSlopeLow,
#                 slopeHigh=SeasSlopeHigh,
#                 site_list=Site_list_plot,
#                 site_labels=Site_labels,
#                 aggPeriod_list=Plot.aggPeriod_list,ylim=c(-0.5,0.5))
# title('EY1-EY3',outer=T)
# 
# ##########
# 
# X.index='GMT'
# Metric_list_here = c('EY4','EY5','EY6')
# 
# par(mfrow=c(4,4),mar=c(3,3,2,1))
# o_EY4_EY6_GMT = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# title('EY4-EY6',outer=T)
# 
# SeasSlope=o_EY4_EY6_GMT$slope;SeasSlopeLow=o_EY4_EY6_GMT$slopeLow;SeasSlopeHigh=o_EY4_EY6_GMT$slopeHigh
# plot_seas_boxes(slope=SeasSlope,
#                 slopeLow=SeasSlopeLow,
#                 slopeHigh=SeasSlopeHigh,
#                 site_list=Site_list_plot,
#                 site_labels=Site_labels,
#                 aggPeriod_list=Plot.aggPeriod_list,ylim=c(-0.5,0.5))
# title('EY4-EY6',outer=T)
# 
# ##########
# 
# # X.index='GMT'
# # Metric_list_here = c('EY7','EY8','EY9')
# # 
# # par(mfrow=c(4,4),mar=c(3,3,2,1))
# # o = calc_seas(site_list=Site_list_plot,
# #               aggPeriod_list=Plot.aggPeriod_list,
# #               agg_data_list=Agg_data_list,
# #               instrument=Instrument,
# #               metric_list=Metric_list_here,
# #               winterMonths=winterMonths,
# #               missing_year_thresh=Missing_year_thresh,
# #               nonsite_year_thresh=Nonsite_year_thresh,
# #               x.index=X.index,
# #               plot.year.min=Plot.year.min,
# #               plot.year.max=Plot.year.max,
# #               ylim=c(0,1))
# # title('EY7-EY9',outer=T)
# # 
# # SeasSlope=o$slope;SeasSlopeLow=o$slopeLow;SeasSlopeHigh=o$slopeHigh
# # 
# # plot_seas_boxes(slope=SeasSlope,
# #                 slopeLow=SeasSlopeLow,
# #                 slopeHigh=SeasSlopeHigh,
# #                 site_list=Site_list_plot,
# #                 site_labels=Site_labels,
# #                 aggPeriod_list=Plot.aggPeriod_list)
# # title('EY7-EY9',outer=T)
# 
# ##########
# 
# X.index='GMT'
# Metric_list_here = paste0('EY',1:15)
# 
# par(mfrow=c(4,4),mar=c(3,3,2,1))
# o_EY1_EY15_GMT = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# title('EY1-EY15',outer=T)
# 
# SeasSlope=o_EY1_EY15_GMT$slope;SeasSlopeLow=o_EY1_EY15_GMT$slopeLow;SeasSlopeHigh=o_EY1_EY15_GMT$slopeHigh
# plot_seas_boxes(slope=SeasSlope,
#                 slopeLow=SeasSlopeLow,
#                 slopeHigh=SeasSlopeHigh,
#                 site_list=Site_list_plot,
#                 site_labels=Site_labels,
#                 aggPeriod_list=Plot.aggPeriod_list,ylim=c(-0.5,0.5))
# title('EY1-EY15',outer=T)
# 
# # ##########
# # 
# # X.index='GMT'
# # Metric_list_here = c('EY1','EY2','EY3','EY4','EY5','EY6')
# # 
# # par(mfrow=c(4,4),mar=c(3,3,2,1))
# # o_EY1_EY6_GMT = calc_seas(site_list=Site_list_plot,
# #               aggPeriod_list=Plot.aggPeriod_list,
# #               agg_data_list=Agg_data_list,
# #               instrument=Instrument,
# #               metric_list=Metric_list_here,
# #               winterMonths=winterMonths,
# #               missing_year_thresh=Missing_year_thresh,
# #               nonsite_year_thresh=Nonsite_year_thresh,
# #               x.index=X.index,
# #               plot.year.min=Plot.year.min,
# #               plot.year.max=Plot.year.max,
# #               ylim=c(0,1))
# # 
# # SeasSlope=o_EY1_EY6_GMT$slope;SeasSlopeLow=o_EY1_EY6_GMT$slopeLow;SeasSlopeHigh=o_EY1_EY6_GMT$slopeHigh
# # 
# # plot_seas_boxes(slope=SeasSlope,
# #                 slopeLow=SeasSlopeLow,
# #                 slopeHigh=SeasSlopeHigh,
# #                 site_list=Site_list_plot,
# #                 site_labels=Site_labels,
# #                 aggPeriod_list=Plot.aggPeriod_list)
# # 
# ##########
# 
# X.index='year'
# 
# Metric_list_here = c('EY1','EY2','EY3','EY4','EY5','EY6')
# Plot.aggPeriod_list_here = Plot.aggPeriod_list[c(1,4)]
# par(mfrow=c(3,2),mar=c(3,5,2,1),oma=c(1,1,4,1))
# 
# o = calc_seas(site_list=Site_list_plot,
#               aggPeriod_list=Plot.aggPeriod_list_here,
#               agg_data_list=Agg_data_list,
#               instrument=Instrument,
#               metric_list=Metric_list_here,
#               winterMonths=winterMonths,
#               missing_year_thresh=Missing_year_thresh,
#               nonsite_year_thresh=Nonsite_year_thresh,
#               x.index=X.index,
#               plot.year.min=Plot.year.min,
#               plot.year.max=Plot.year.max,
#               ylim=c(0,1))
# 
# #############################################
# 
# dev.off()
# pause

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/monthly_HQ/rain.023721.monthly.txt'
d = read.table(fname,skip=1)
Date_start = as.Date('1863/01/01')
Date_end = as.Date('2023/10/01')
Date0 = seq(Date_start,Date_end,by='months')
P0 = d$V3

####################################
# check double mass 
cat('check double mass \n')

AggPeriod = '1 month'
for (Instrument in Plot.instrument_list){
  par(mfrow=c(1,1),mar=c(4,4,1,1),oma=c(1,1,1,1))
  for (Site in Site_list){
    a1 = Agg_data_list[[Site]][[Instrument]][[AggPeriod]]
    Date1 = a1$date
    P1 = a1$P
    
    Source_change = Date1[min(which(a1$source %in% c('AWS.site','AWS.nearbySite')))]
    
    plot_double_mass(p1=P0,p2=P1,date1 = Date0,date2 = Date1,
                     year.min = Plot.year.min,year.max = Plot.year.max,
                     instrumentChange=InstrumentChange[[Site]],
                     source_change=Source_change,#Blend_year_change[[Site]],
                     xlab='Happy Valley HQ site (023721)',
                     ylab=paste0(Site_labels[[Site]],' (',Site,') - ',Instrument))
  }
}

for (Site in Site_list[1:4]){
  par(mfrow=c(4,4))
  for (metric_num in c(1,2,3,4)){
    for (AggPeriod in AggPeriod_list[1:4]){
      Seas_list = c('summer','autumn','winter','spring')
      m_mat = c()
      for (Seas in Seas_list){
        m = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]][[Seas]]$metrics[,metric_num]
        m_mat = cbind(m_mat,m)
      }
      colnames(m_mat) = Seas_list
      boxplot(m_mat)   
      title(paste0(Metric_list[metric_num],', ',AggPeriod))
    }
  }
  title(Site,outer=T)
}

for (Site in Site_list[1:4]){
  par(mfrow=c(4,4))
  for (metric_num in c(1,2,3,4)){
    for (AggPeriod in AggPeriod_list[1:4]){
      Seas_list = c('summer','autumn','winter','spring')
      m_vec = c()
      for (Seas in Seas_list){
        m = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]][[Seas]]$metrics[,metric_num]
        m_vec = c(m_vec,mean(m,na.rm=T))
      }
      names(m_vec)=Seas_list
      barplot(m_vec)
      title(paste0(Metric_list[metric_num],', ',AggPeriod))
    }
  }
  title(Site,outer=T)
}



Seas_list = c('summer','autumn','winter','spring')
Seas_label_list = c('sum','aut','win','spr')
m_arr = array(dim=c(4,4))
par(mfcol=c(4,4),mar=c(3,4,2,1))
for (metric_num in c(1,2,3,4)){
  for (a in 1:4){
    AggPeriod = AggPeriod_list[a]
    m_vec = c()
    if (metric_num==1){
      dtDays = Annual_metrics_list[[1]][[1]][[AggPeriod]][[1]]$dtDays
      fac = 365/dtDays/4
      units = 'mm/seas'
    } else {
      fac = 1
      units = 'mm'
    }
    for (site_num in 1:4){
      Site = Site_list[site_num]
      for (seas_num in 1:length(Seas_list)){
        Seas = Seas_list[seas_num]
        m = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]][[Seas]]$metrics[,metric_num]
        m_arr[site_num,seas_num] = fac*mean(m,na.rm=T)
      }
      #     names(m_vec)=Seas_list
      #      barplot(m_vec)
    }
    m_vec = apply(m_arr,2,mean)
    names(m_vec)=Seas_label_list
    barplot(m_vec,ylab=paste0('Rainfall (',units,')'),col=c('red','purple','blue','orange'))
    title(paste0(Metric_list[metric_num],', ',AggPeriod))
  }
}
title('all sites',outer=T)

dev.off()
pause


#############################################
# check monthly totals
cat('check monthly totals\n')

# year_HQ = as.integer(format(Date0,'%Y'))
# keep_HQ = which((year_HQ>=Plot.year.min)&(year_HQ<=Plot.year.max))
# dates_keep = as.Date(Date0[keep_HQ])
# P_HQ_keep = P0[keep_HQ]

#xlim = c(as.Date('2012/01/01'),as.Date('2014/12/31'))
#xlim = c(as.Date('2000/01/01'),as.Date('2001/12/31'))
#xlim = c(as.Date('2003/01/01'),as.Date('2003/12/31'))
#xlim = c(as.Date('1993/01/01'),as.Date('1993/12/31'))
xlim = NULL

Time.min=as.Date(paste0(Plot.year.min,'/01/01'))
Time.max=as.Date(paste0(Plot.year.max,'/12/31'))
Time.1 = as.Date(Date0)
P.1 = P0

hiThresh = 50

Instrument_list_here = 'combo_sources_sites'

for (Site in Site_list){
  
  #Instrument_list_here = names(Agg_data_list[[Site]])
  
  for (Instrument in Instrument_list_here){
    
    #s = 4 
    #i = 'pluvio'
    #i = 'AWS'
    #i = 'combo_sources_sites'
    #i = 'combo_pluvio_sites'
    #i = 'combo_AWS_sites'
    m = Agg_data_list[[Site]][[Instrument]]$`1 month`
    
    Time.2 = as.Date(m$date)
    P.2 = m$P
    Time.inc = '1 month' 
    
    o = common_time_series(time.min=Time.min,
                           time.max=Time.max,
                           time.1=Time.1,
                           P.1=P.1,
                           time.2=Time.2,
                           P.2=P.2,
                           time.inc=Time.inc)
    
    P_HQ_keep_high = o$P.1
    P_HQ_keep_high[P_HQ_keep_high<hiThresh] = NA
    
    #P_agg_keep_high = P_agg_keep
    #P_agg_keep_high[P_agg_keep_high<hiThresh] = NA
    
    #######
    
    par(mfrow=c(2,1),mar=c(3,3,1,1),oma=c(1,1,3,1))
    
    plot(o$t,o$P.1,type='l',xlim=xlim)
    lines(o$t,o$P.2*o$fac,type='l',col='green')
    
    plot(o$t,o$P.2/P_HQ_keep_high*o$fac,type='o',xlim=xlim,ylim=c(0.0,2.5))
    abline(h=1,lty=1)
    abline(h=0.5,lty=2)
    abline(h=2,lty=2)
    abline(h=0.25,lty=3)
    abline(h=4,lty=3)
    
    title(paste0(Site,', ',Instrument),outer=T)
    
  }
  
}
#############################
# check correlations
cat('check correlations\n')

# Instrument_1 = 'pluvio' # red
# Instrument_2 = 'AWS' # blue
# Missing_year_thresh_here = 0.1
# #Missing_year_thresh_here = 0.05
# Nonsite_year_thresh_here = 1

Instrument_1 = 'combo_pluvio_sites' # red
Instrument_2 = 'combo_AWS_sites' # blue
Missing_year_thresh_here = Missing_year_thresh
Nonsite_year_thresh_here = Nonsite_year_thresh

#Site_list_here = '023090'
#Metric_list_here = 'mean'

Site_list_here = Site_list
Metric_list_here = Metric_list

par(mfrow=c(2,2))
calc_annual_metrics_cor(annual_metrics_list=Annual_metrics_list,
                        site_list=Site_list_here,
                        metric_list = Metric_list_here,
                        instrument_1=Instrument_1,
                        instrument_2=Instrument_2,
                        aggPeriod_list=Plot.aggPeriod_list,
                        missing_year_thresh=Missing_year_thresh_here,
                        nonsite_year_thresh = Nonsite_year_thresh_here)

#############################
# check when infilled data used in metric trends
cat('check when infilled data used in metric trends\n')

#Site = Site_list[1]
#Instrument = 'combo_sources_sites'
#Instrument = 'pluvio'
#AggPeriod = AggPeriod_list[1]
#metricNum = 2

for (AggPeriod in Plot.aggPeriod_list){
  
  for (metricNum in 2:4){
    
    cat('\n')
    cat(AggPeriod,'\n')
    cat(Metric_list[metricNum],'\n')
    
    sum1 = 0
    
    for (Site in Site_list_plot){
      
      md = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]]$metrics.dates
      d = Agg_data_list[[Site]][[Instrument]][[AggPeriod]]$date
      m = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]]$metrics
      
      i=which(d%in%as.POSIXct(md[,metricNum],tz='UTC'))
      S = Agg_data_list[[Site]][[Instrument]][[AggPeriod]]$source
      P = Agg_data_list[[Site]][[Instrument]][[AggPeriod]]$P
      j = which(S[i] %in% c('AWS.nearbySite','pluvio.nearbySite'))
      
      bad = Annual_metrics_list[[Site]][[Instrument]][[AggPeriod]]$sources.years[j,]
      
      if (is.matrix(bad)){
        x1 = bad[,1] + bad[,2]
        x2 = bad[,5]
        k = which(x1 > (1-Nonsite_year_thresh) & x2 < Missing_year_thresh)
      } else {
        x1 = bad[1] + bad[2]
        x2 = bad[5]
        if (x1 > (1-Nonsite_year_thresh) & x2 < Missing_year_thresh){
          k=1
        } else {
          k = character(0)
        }
      }
      
      #print(j[k])
      if (length(j[k])>0){
        cat(Site,'\n')
        print(as.POSIXct(md[,metricNum],tz='UTC')[j[k]])
      }
      #print(length(j[k]))
      sum1 = sum1 + length(j[k])
      
    }
    
    cat(sum1,'\n')
    
  }
  
}

#############################
# plot rainfall for dates when metrics occur 
cat('plot rainfall for dates when metrics occur \n')

par(mfrow=c(3,2))
plot_timeseries_metrics_dates(site_list=Site_list_plot,
                              plot.aggPeriod_list=Plot.aggPeriod_list,
                              metric_list=Metric_list,
                              instrument=Plot.instrument_list,
                              annual_metrics_list=Annual_metrics_list,
                              agg_data_list=Agg_data_list,
                              processed_data_list=Processed_data_list,
                              nearbySite_list=NearbySite_list)

#####################

dev.off()






























# 
# 
# 
# pause
# 
# aggPeriod = '12 mins'
# metric = 'mean'
# par(mfrow=c(1,1))
# colList = c('red','green','blue','cyan')
# metricsMat = c()
# for (s in 1:length(Site_list_plot)){
#   site = Site_list_plot[s]
#   m = Annual_metrics_list[[site]]$combo_sources_sites[[aggPeriod]]
#   missing = m$missing
#   sources.years = m$sources.years
#   nonsiteFrac = 1-apply(sources.years[,c('AWS.site','pluvio.site')],1,sum)
#   omit = which((missing>Missing_year_thresh)|(nonsiteFrac>Nonsite_year_thresh)) 
#   metrics = m$metrics[,metric]
#   metrics[omit] = NA
#   print(length(m$year)-length(omit))  
#   if (s==1){
#     plot(m$year,metrics,type='o',col=colList[s])
#   } else {
#     lines(m$year,metrics,type='o',col=colList[s])
#   }
#   metricsMat = cbind(metricsMat,metrics)
#   
# }  
# 
# nS = length(Site_list_plot)
# for (s1 in 1:(nS-1)){
#   for (s2 in (s1+1):nS){
#     print(paste(s1,s2,cor(metricsMat[,s1],metricsMat[,s2],use = 'pairwise.complete.obs')))
#   }
# }
# 
# 
# 
# 
# #############################
# 
# # site1 = site_list[1]
# # site2 = site_list[3]
# # instrument = 'AWS_pluvio'
# # #aggPeriod = '12 mins'
# # #aggPeriod = '30 mins'
# # #aggPeriod = '1 hour'
# # aggPeriod = '3 hours'
# # metric = 'max'
# #
# # a1 = annual_metrics_list[[site1]][[instrument]][[aggPeriod]]
# # m1 = a1$metrics[,metric]
# # y1 = a1$year
# #
# # a2 = annual_metrics_list[[site2]][[instrument]][[aggPeriod]]
# # m2 = a2$metrics[,metric]
# # y2 = a2$year
# #
# # ymin = max(min(y1),min(y2))
# # ymax = min(max(y1),max(y2))
# #
# # keep1 = which((y1>=ymin)&(y1<=ymax))
# # keep2 = which((y2>=ymin)&(y2<=ymax))
# #
# # m1.keep = m1[keep1]
# # m2.keep = m2[keep2]
# #
# # y.keep = y1[keep1]
# #
# # plot(m1.keep,m2.keep,xlab=site1,ylab=site2,main=paste0(metric,', ',aggPeriod))
# # text(x=m1.keep,y=m2.keep,labels = y.keep,cex=0.5,pos = 1)
# #
# # pause
# 
# 
# #############################
# 
# o = plot_annual_metrics_multi(annual_metrics_list=Annual_metrics_list,
#                               site_list=Site_list,
#                               plot.aggPeriod_list=Plot.aggPeriod_list,
#                               metric_list=Metric_list,
#                               plot.instrument_list=Plot.instrument_list,
#                               missing_year_thresh=Missing_year_thresh,
#                               nonsite_year_thresh=Nonsite_year_thresh,
#                               x.index=X.index,
#                               plot_linear=Plot_linear,
#                               plot.year.min=Plot.year.min,
#                               plot.year.max=Plot.year.max,
#                               combine_sources_sites=Combine_sources_sites,
#                               site_labels = Site_labels)
# 
# SlopeArray=o$slopeArray;PValArray=o$pValArray;NPoints=o$nPoints;SlopeArrayLow=o$slopeArrayLow;SlopeArrayHigh=o$slopeArrayHigh
# 
# # for (s in 1:length(site_list)){
# #   site = site_list[s]
# #   for (i in 1:length(instrument_list)){
# #     instrument = instrument_list[i]
# #     for (a in 1:length(aggPeriod_list)){
# #       aggPeriod = aggPeriod_list[a]
# #       for (m in 1:length(metricList)){
# #         metric = metricList[m]
# #         oo = annual_metrics_list[[site]][[instrument]][[aggPeriod]]
# #         metMean = o[[site]][[aggPeriod]]$metMean
# #         slopeArray[s,i,a,m] = oo$slope[m] / metMean[[m]]
# #         pValArray[s,i,a,m] = oo$pval[m]
# #       }
# #     }
# #   }
# #
# # }
# 
# par(mfrow=c(4,4))
# 
# Metric_list_plot = c('max','EY2','EY6','mean')
# 
# plot_trends_boxes(plot.year.min=Plot.year.min,
#                   plot.year.max=Plot.year.max, 
#                   x.index=X.index,
#                   plot.instrument_list=Plot.instrument_list,
#                   metric_list=Metric_list_plot,
#                   plot.aggPeriod_list=Plot.aggPeriod_list,
#                   slopeArrayLow=SlopeArrayLow,
#                   slopeArray=SlopeArray,
#                   slopeArrayHigh=SlopeArrayHigh,
#                   site_list=Site_list)
# 
# plot_trends_boxes_new(Instrument=Plot.instrument_list,
#                                  site_list=Site_list,
#                                  site_labels=Site_labels,
#                                  metric_list=Metric_list_plot,
#                                  plot.aggPeriod_list=Plot.aggPeriod_list,
#                                  x.index=X.index,
#                                  slopeArrayLow=SlopeArrayLow,
#                                  slopeArray=SlopeArray,
#                                  slopeArrayHigh=SlopeArrayHigh)
# 
# 
# #######
# 
# pause
# 
# ##############################
# 
# year_agg = as.integer(format(m$date,'%Y'))
# keep_agg = which((year_agg>=Plot.year.min)
#                  &(year_agg<=Plot.year.max)
#                  &(as.Date(m$date)<=max(dates_keep))
#                  &(as.Date(m$date)>=min(dates_keep)))
# 
# P_agg_keep = rep(NA,length(dates_keep))
# P_agg_keep[keep_agg] = m$P[keep_agg]
# 
# #xlim = c(as.Date('2012/01/01'),as.Date('2021/12/31'))
# #xlim = c(as.Date('2000/01/01'),as.Date('2004/12/31'))
# #xlim = c(as.Date('1995/01/01'),as.Date('2002/12/31'))
# xlim = NULL
# 
# par(mfrow=c(2,1),mar=c(3,3,1,1),oma=c(1,1,3,1))
# 
# plot(dates_keep,P_HQ_keep,type='l',xlim=xlim)
# lines(dates_keep,P_agg_keep,col='green')
# 
# hiThresh = 50
# 
# P_HQ_keep_high = P_HQ_keep
# P_HQ_keep_high[P_HQ_keep_high<hiThresh] = NA
# 
# #P_agg_keep_high = P_agg_keep
# #P_agg_keep_high[P_agg_keep_high<hiThresh] = NA
# 
# plot(dates_keep,P_agg_keep/P_HQ_keep_high,type='o',xlim=xlim)
# abline(h=0.5,lty=2)
# abline(h=2,lty=2)
# abline(h=1,lty=2)
# 
# title(i,outer=T)
# 
# ########
# 
# # a1 = agg_data_list[[1]]$AWS_pluvio$`1 month`
# # date1 = a1$date
# # year1 = as.integer(format(date1,'%Y'))
# # keep1 = which((year1>=year.min)&(year1<=year.max))
# # P1 = a1$P[keep1]
# #
# # ########
# #
# # a2 = agg_data_list[[2]]$AWS_pluvio$`1 month`
# # date2 = a2$date
# # year2 = as.integer(format(date2,'%Y'))
# # keep2 = which((year2>=year.min)&(year2<=year.max))
# # P2 = a2$P[keep2]
# 
# ########
# 
# 
# 
# ########
# 
# # plot_double_mass(P0,P1)
# #
# # plot_double_mass(P0,P2)
# #
# # plot_double_mass(P1,P2)
# 
# 
# # a1 = agg_data_list[[1]]$AWS_pluvio$`1 month`
# # date1 = a1$date
# # year1 = as.integer(format(date1,'%Y'))
# # keep1 = which((year1>=year.min)&(year1<=year.max))
# # P1 = a1$P[keep1]
# 
# #instrument = blend_type
# #instrument = instrument_list[1]
# 
# ####################################
# 
# #dev.off()
# 
# 
# # pause
# #
# # ###########################
# #
# # par(mfrow=c(2,1))
# #
# # xm = 4
# # ym = 1
# # for (i in 1:length(instrument_list)){
# #   m = annual_metrics_list[[site]][[i]]$metrics
# #   if (i==1){
# #     plot(m[,xm],m[,ym],col=colList[i])
# #   } else {
# #     points(m[,xm],m[,ym],col=colList[i])
# #   }
# # }
# #
# # xm = 4
# # ym = 2
# # for (i in 1:length(instrument_list)){
# #   m = annual_metrics_list[[site]][[i]]$metrics
# #   if (i==1){
# #     plot(m[,xm],m[,ym],col=colList[i])
# #   } else {
# #     points(m[,xm],m[,ym],col=colList[i])
# #   }
# # }
# # ###########################
# #
# # pause
# #
# # #probs = c(0.99,0.999)
# # probs = c(0.95,0.99)
# #
# # year.min = as.integer(format(agg_data$date[1],'%Y'))
# # year.max = as.integer(format(agg_data$date[length(agg_data$date)],'%Y'))
# #
# # year_vec = year.min:year.max
# #
# # P = agg_data$P
# # year.all = as.integer(format(agg_data$date,'%Y'))
# # rqfit = rq(P~year.all,tau=probs)
# #
# # metrics = matrix(nrow=length(year.min:year.max),ncol=length(probs))
# # missing = c()
# # for(y in 1:length(year_vec)){
# #   i = which(year.all==year_vec[y])
# #   metrics[y,1:length(probs)] = quantile(agg_data$P[i],probs=probs,na.rm=T)
# #   missing[y] = length(which(is.na(agg_data$P[i])))/length(agg_data$P[i])
# #   # if (missing[y]>0.2){metrics[y,]=NA}
# # }
# #
# # lm1 = lm(metrics[,1]~year_vec)
# # lm2 = lm(metrics[,2]~year_vec)
# #
# #
# # plot(year_vec,metrics[,1],type='l')
# # lines(year_vec,rqfit$coefficients[1,1]+rqfit$coefficients[2,1]*year_vec)
# # lines(year_vec,lm1$coefficients[1]+lm1$coefficients[2]*year_vec,col='red')
# # abline(h=quantile(agg_data$P,probs=probs[1],na.rm=T),col='blue')
# #
# # plot(year_vec,metrics[,2],type='l')
# # lines(year_vec,rqfit$coefficients[1,2]+rqfit$coefficients[2,2]*year_vec)
# # lines(year_vec,lm2$coefficients[1]+lm2$coefficients[2]*year_vec,col='red')
# # abline(h=quantile(agg_data$P,probs=probs[2],na.rm=T),col='blue')
# 
# 
# #################################
# 
# # instrument1 = 'AWS_pluvio'
# # instrument2 = 'combo_sources_sites'
# # 
# # for (site in Site_list){
# #   for (aggPeriod in AggPeriod_list){
# #     par(mfrow=c(3,2),oma=c(1,1,3,1),mar=c(5,5,1,1))
# #     for (metric in Metric_list){
# #       o1 = Annual_metrics_list[[site]][[instrument1]][[aggPeriod]]
# #       years1 = o1$year
# #       
# #       o2 = Annual_metrics_list[[site]][[instrument2]][[aggPeriod]]
# #       years2 = o2$year
# #       
# #       plot(years1,o1$metrics[,metric],type='o',col='black',
# #            xlab='year',ylab=metric,
# #            xlim=c(Plot.year.min,Plot.year.max))
# #       lines(years2,o2$metrics[,metric],type='o',col='red')
# #       
# #       title(metric)
# #     }
# #   
# #     plot(years1,o1$missing,type='o',col='black',
# #          xlab='year',ylab='missing',
# #          xlim=c(Plot.year.min,Plot.year.max))
# #     
# #     lines(years2,o2$missing,type='o',col='red')
# #     
# #     nonsite = 1-apply(o2$sources.years[,c('AWS.site','pluvio.site')],1,sum)
# # 
# #     lines(years2,nonsite,type='o',col='cyan',lty=3)
# #     
# #     title(paste(site,aggPeriod),outer=T)
# #   }
# # }
# 
# 
# #############################
# 
# # plot_timeseries_metrics_dates(site_list=Site_list,
# #                               plot.aggPeriod_list=Plot.aggPeriod_list,
# #                               metric_list=Metric_list,
# #                               instrument=Plot.instrument_list,
# #                               annual_metrics_list=Annual_metrics_list,
# #                               agg_data_list=Agg_data_list,
# #                               processed_data_list=Processed_data_list,
# #                               nearbySite_list=NearbySite_list)
# 
# 
# #############################
