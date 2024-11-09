#############################

calc_seas = function(site_list,aggPeriod_list,agg_data_list,instrument,metric_list,
                     winterMonths,missing_year_thresh,nonsite_year_thresh,x.index,
                     plot.year.min,plot.year.max,ylim=NULL){
  
  slope = slopeLow = slopeHigh = meanWSF = matrix(nrow=length(site_list),ncol=length(aggPeriod_list))
  for (s in 1:length(site_list)){
    
    site = site_list[s]
    
    for (a in 1:length(aggPeriod_list)){
      
      aggPeriod = aggPeriod_list[a]
      
      annual_metrics = calc_annual_metrics_core(agg_data=agg_data_list[[site]][[instrument]][[aggPeriod]],
                                                metric_list = metric_list,
                                                calc_seas_metrics=F)[['all']]
      
      datesHighRain = as.POSIXct(annual_metrics$metrics.dates,tz='UTC')
      
      monthsHighRain = as.integer(format(datesHighRain,'%m'))
      yearsHighRain = as.integer(format(datesHighRain,'%Y'))
      
      y=apply(matrix(as.integer(monthsHighRain %in% winterMonths),ncol=length(metric_list)),1,mean)
      
      missing = annual_metrics$missing
      sources = annual_metrics$sources.years
      nonsiteFrac = 1-apply(sources[,c('AWS.site','pluvio.site')],1,sum)
      exclude = which((missing>missing_year_thresh)|(nonsiteFrac>nonsite_year_thresh))
      
      y[exclude] = NA
      
      # GMT
      if (x.index=='GMT'){
        GMT.keep = which((GMT.year>=plot.year.min)&(GMT.year<=plot.year.max))
        x = GMT.anom[GMT.keep]
      } else if (x.index=='year'){
        x = annual_metrics$year
      }
      
      plot(x,y,type='o',main=paste0(site,', ',aggPeriod),col='blue',
           ylab='WinFrac',ylim=ylim)    
      
      Lmfit = lm(y~x)
      coeff = Lmfit$coefficients
      
      abline(a=coeff[1],b=coeff[2])
      
      slope[s,a] = coeff[2]
      CI = confint(Lmfit,level = 0.66)
      slopeLow[s,a] = CI[2,1]
      slopeHigh[s,a] = CI[2,2]
      
      meanWSF[s,a] = mean(y,na.rm=T)
      
    }
    
  }
  
  return(list(slope=slope,slopeLow=slopeLow,slopeHigh=slopeHigh,meanWSF=meanWSF))
  
}

########################

plot_seas_boxes = function(slope,slopeLow,slopeHigh,
                           site_list,site_labels,
                           aggPeriod_list,ylim=NULL){
  
  sl = c()
  for (s in 1:length(site_list)){
    site = site_list[s]
    sl[s] = site_labels[[site]]
  }
  par(mfrow=c(4,4),mar=c(3,1,2,1),oma=c(1,8,2,1))
  for (a in 1:length(aggPeriod_list)){
    aggPeriod = aggPeriod_list[a]
    z = list()
    z$stats = rbind(slopeLow[,a],
                    slopeLow[,a],
                    slope[,a],
                    slopeHigh[,a],
                    slopeHigh[,a])
    if (a==1){
      z$names = sl
    } else {
      z$names=rep('',length(site_list))
    }
    # bxp(z,horizontal = T,las=2,xlab='',ylim=xlim,
    #     main=main,
    #     boxfill=c(rep(colData,length(site_list)),colARR),cex.axis=0.75)
    bxp(z,horizontal = T,las=2,xlab='',cex.axis=0.75,
        main=aggPeriod,boxfill='lightblue',ylim=ylim)
    mtext(side=1,text = '/degC',cex=0.75,line=2)
    abline(v=0)
  }
  
}



