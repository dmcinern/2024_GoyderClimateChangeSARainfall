rm(list=ls())

setwd("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/scripts/")

source('settings.R')

#site_list = c('023034','023090')
site_list = c('023034','023090','023083','023013','023885','023842','023878',
              '023000','023343','023763','024515','023801','023823')

#site_list = c('023763')


instrument_list = c('pluvio','AWS')
#instrument_list = c('AWS')

load_raw_RData = T
load_processed_RData = T

aggPeriod = '1 hour'

year_list = propData = list()

for (site in site_list){

  cat(site,'\n')

  year_list[[site]] = propData[[site]] = list()

  for (instrument in instrument_list){

    cat(instrument,'\n')

    cat('loading data\n')
    raw_data = load_raw_data(site=site,instrument=instrument,
                             load_raw_RData=load_raw_RData,
                             data_dirname=data_dirname,
                             RData_dirname=RData_dirname) # matrix for pluvio, vector for aws

    if (!is.null(raw_data)){

      cat('processing data\n')
      # select years, get data in easy format, deal with QCs
      processed_data = process_raw_data(raw_data=raw_data,
                                        instrument=instrument,
                                        load_processed_RData=load_processed_RData,
                                        RData_dirname=RData_dirname)

      cat('calculating available data lengths\n')
      year_all = as.integer(format(processed_data$date,'%Y'))
      year_list[[site]][[instrument]] = unique(year_all)
      col = c()
      P = processed_data$P
      accPeriod = processed_data$accPeriod
      date = processed_data$date

      d1 <- data.frame(timePeriod = seq(from=date[1],
                                        to=date[length(date)],
                                        by=aggPeriod))
      accRatio = length(P)/length(d1$timePeriod)
      P[accPeriod>accRatio] = NA

      propData[[site]][[instrument]] = c()
      for (y in 1:length(year_list[[site]][[instrument]])){
        year = year_list[[site]][[instrument]][y]
        keep = which(year_all==year)
        propData[[site]][[instrument]][y] = length(which(!is.na(P[keep])))/length(keep)
      }
    } else {
      propData[[site]][[instrument]] = year_list[[site]][[instrument]] = NULL
    }

  }


}

xlim = c(1950,2025)
col_list = list(pluvio='blue',AWS='red')

dy1 = 0.2
dy2 = 0.5

ylim = c(-dy2*length(site_list)-dy1*length(instrument_list)*length(site_list)+dy2+dy1,0)

y_plot = 0
par(mfrow=c(1,1),mar=c(3,9,1,1))
y_mid = site_lab = c()
for (s in 1:length(site_list)){
  site = site_list[s]
  site_lab[s] = site_labels[[site]]
  for (instrument in instrument_list){
    if (!is.null(propData[[site]][[instrument]])){
      rbPal <- colorRampPalette(c('white',col_list[instrument]))
      # col <- rbPal(100)[as.numeric(cut(propData[[site]][[instrument]],breaks = 100))]
      pct = 100*propData[[site]][[instrument]]
      pct[pct==0] = 1
      col <- rbPal(100)[pct]
      if(y_plot==0){
        plot(x=year_list[[site]][[instrument]],y=rep(y_plot,length(col)),col=col,pch=15,xlim=xlim,ylim=ylim,xlab='Year',ylab='',yaxt='n')
      } else {
        points(x=year_list[[site]][[instrument]],y=rep(y_plot,length(col)),col=col,pch=15,type='p')
      }

    }
    y_plot = y_plot-dy1
  }
  y_mid[s] = y_plot+dy2/2
  y_plot = y_plot-dy2
}

axis(side=2,at = y_mid,labels = site_lab,las=2,cex.axis=0.9)
legend('bottomleft',instrument_list,col=unlist(col_list),pch=15)
prop_sel_years = c()
#sel_years_min = 1974
#sel_years_max = 2023
sel_years_min = 1972
sel_years_max = 2017
year_combo = list()
for (s in 1:length(site_list)){
  site = site_list[s]
  year_combo[[site]] = c()
  for (instrument in instrument_list){
    i = which(propData[[site]][[instrument]]>0.9)
    year_combo[[site]] = c(year_combo[[site]],year_list[[site]][[instrument]][i])
    year_combo[[site]] = unique(year_combo[[site]])
    prop_sel_years[s] = length(which((year_combo[[site]]>=sel_years_min)&(year_combo[[site]]<=sel_years_max))) /(sel_years_max-sel_years_min+1)
  }
}
