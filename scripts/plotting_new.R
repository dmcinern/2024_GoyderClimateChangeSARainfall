specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))

##########################

plot_annual_metrics_new = function(annual_metrics_list,
                                   site,
                                   aggPeriod,
                                   instrument,
                                   metric_list,
                                   missing_year_thresh,
                                   nonsite_year_thresh=NULL,
                                   year.min=NULL,year.max=NULL,
                                   x.index='GMT',
                                   yNorm=T,
                                   site_labels,
                                   col.metric='blue',
                                   col.missing='magenta',
                                   col.nonsiteFrac='cyan',
                                   col.sources = c('blue','red','green','cyan','magenta'),
                                   plotMissing=T,
                                   seas='all',
                                   plotType='metrics'){
 
  
  m = annual_metrics_list[[site]][[instrument]][[aggPeriod]][[seas]] 
  years.all = m$year
  metrics.all = m$metrics
  missing.all = m$missing
  
  if (instrument=='combo_sources_sites'){
    sources.all = m$sources.years
    nonsiteFrac.all = 1-apply(sources.all[,c('AWS.site','pluvio.site')],1,sum)
  } else {
    nonsiteFrac.all = rep(0,length(years))
  }

  keep = which((years.all>=year.min)&(years.all<=year.max))
  years = years.all[keep]
  metrics = metrics.all[keep,]
  missing = missing.all[keep]
  nonsiteFrac = nonsiteFrac.all[keep]
  sources = sources.all[keep,]

  metrics[(missing>missing_year_thresh)|(nonsiteFrac>nonsite_year_thresh)] = NA

  if (x.index=='GMT'){
    GMT.keep = which((GMT.year>=year.min)&(GMT.year<=year.max))
    x = GMT.anom[GMT.keep]
    xlab = 'GMT'
    type = 'p'
  } else {
    x = years
    xlab = 'year'
    type = 'o'
  }
  
  slope = slopeLow = slopeHigh = slopeLow90 = slopeHigh90 = pval = Npoints = shapiro.pval = ks.pval = c()
  
  for (m in 1:length(metric_list)){
    
    metric = metric_list[m]
    
    if (metric=='mean'){
      dtDays = annual_metrics_list[[1]][[1]][[aggPeriod]][[1]]$dtDays
      fac = 365/dtDays
      units = 'mm/yr'
    } else {
      fac = 1
      units = 'mm'
    }
    
    y = metrics[,metric]*fac
    
    yOrig = y
    
    if (yNorm){
      y = (y/mean(y,na.rm=T)-1)*100
    }

    lmfit = lm(y~x)
    lmsummary = summary(lmfit)
    coeff = lmsummary$coefficients
    slope[m] = coeff[2]
    pval[m] = coeff[2,4]
    
    resid = lmfit$residuals
    shapiro.pval[m] = shapiro.test(resid)$p.value
    if (shapiro.pval[m]<0.05){
      cat('Shapiro',metric,aggPeriod,site,shapiro.pval[m],'\n')
    }
    
    std.resid = (resid-mean(resid))/sd(resid)
    ks.pval[m] = ks.test(std.resid,pnorm)$p.value
    if (ks.pval[m]<0.05){
      cat('KS',metric,aggPeriod,site,ks.pval[m],'\n')
    }  
    
    
    # keep = which(!is.na(y))
    # 
    # data <- data.frame(x = x[keep], y = y[keep])
    # 
    # fit <- fevd(y, data, location.fun=~x)
    # 
    # cat(site,aggPeriod,metric,'\n')
    # print(fit$results$par)
    # 
    # browser()
    
    CI = confint(lmfit,level = 0.66)
    # browser()
    # annMax = y
    # GMT = x
    # save(file=paste0(RData_dirname,site,'_',gsub(" ", "", aggPeriod),'_',metric,'.RData'),annMax)
    # save(file=paste0(RData_dirname,'GMT.RData'),GMT)
    
    slopeLow[m] = CI[2,1]
    slopeHigh[m] = CI[2,2]
    
    CI90 = confint(lmfit,level = 0.9)
    slopeLow90[m] = CI90[2,1]
    slopeHigh90[m] = CI90[2,2]
    
    Npoints[m] = length(which(!is.na(y)))
    
    if (plotType=='metrics'){
      plot(x,y,type=type,xlab=xlab,ylab=paste0(metric,' (',units,')'),col=col.metric)
      abline(a=coeff[1],b=coeff[2])
      title(paste0(site,', ',seas,', ',metric,', ',aggPeriod,' : slope=',specify_decimal(slope[m],2),
                   '%/',x.index,', pval=',specify_decimal(pval[m],2),
                   ', N=',Npoints[m]),cex.main=0.8)      
    } else if (plotType=='resids'){
      hist(y,xlab=paste0(metric,' (',units,')'))
      title(paste0(site,', ',seas,', ',metric,', ',aggPeriod,' : slope=',specify_decimal(slope[m],2),
                   '%/',x.index,', pval=',specify_decimal(pval[m],2),
                   ', N=',Npoints[m]),cex.main=0.8)   
    }

  }
  
  if (plotMissing){
  
    if (instrument=='combo_sources_sites'){
      ylim = c(0,nonsite_year_thresh*1.5)
    } else {
      ylim = c(0,missing_year_thresh*1.5)
    }
    plot(x,missing,type=type,col=col.missing,ylim=ylim,xlab=xlab,ylab='missing/nonsite')
    lines(x,nonsiteFrac,type=type,col=col.nonsiteFrac)
    abline(h=missing_year_thresh,col=col.missing,lty=2)
    abline(h=nonsite_year_thresh,col=col.nonsiteFrac,lty=2)
    legend('topright',c('missing','nonsite'),col=c(col.missing,col.nonsiteFrac),lty=1)
    title('missing/noniste data',cex.main=0.8)
  
    if (instrument=='combo_sources_sites'){
      n.sources = length(sources[1,])
      plot(x,sources[,1],ylim=c(0,1),xlim=c(min(x),max(x)),type='l',col=col.sources[1],xlab=xlab,ylab='source')
      for (s in 2:n.sources){
        lines(x,sources[,s],,col=col.sources[s])
      }
      title('data source',cex.main=0.8)
    }
    legend('right',colnames(sources),col=col.sources,lty=1,cex=0.7)
    
  }

  #title(paste0(site,', ',aggPeriod,', ',instrument),outer=T)
  
  return(list(slope = slope,
              slopeLow = slopeLow,
              slopeHigh = slopeHigh,
              slopeLow90 = slopeLow90,
              slopeHigh90 = slopeHigh90,
              pval = pval,
              shapiro.pval = shapiro.pval,
              ks.pval = ks.pval,
              Npoints = Npoints))
  
}

##########################

plot_annual_metrics_multi_new = function(annual_metrics_list,
                                     site_list,
                                     plot.aggPeriod_list,
                                     metric_list,
                                     instrument,
                                     missing_year_thresh,
                                     nonsite_year_thresh,
                                     x.index,
                                     yNorm=yNorm,
                                     plot.year.min,plot.year.max,
                                     site_labels,
                                     plotMissing,
                                     seas='all',
                                     plotType='metrics'){
  
  slopeArray = slopeArrayLow = slopeArrayHigh = 
    slopeArrayLow90 = slopeArrayHigh90 = 
    pValArray = shapiroPvalArray = ksPvalArray = 
    nPoints = array(dim=c(length(site_list),
                          length(plot.aggPeriod_list),
                          length(metric_list)))
  for (s in 1:length(site_list)){
    site = site_list[s]
    for (a in 1:length(plot.aggPeriod_list)){
      aggPeriod = plot.aggPeriod_list[a]
      #par(mfrow=c(3,2),mar=c(3,4,2.5,1),oma=c(1,1,3,1))
      o = plot_annual_metrics_new(annual_metrics_list=annual_metrics_list,
                              site=site,
                              aggPeriod=aggPeriod,
                              instrument=instrument,
                              metric_list=metric_list,
                              missing_year_thresh = missing_year_thresh,
                              nonsite_year_thresh = nonsite_year_thresh,
                              year.min=plot.year.min,year.max=plot.year.max,
                              x.index=x.index,
                              yNorm=yNorm,
                              site_labels=site_labels,
                              plotMissing=plotMissing,
                              seas=seas,
                              plotType=plotType)
 
      slopeArray[s,a,] = o$slope
      pValArray[s,a,] = o$pval
      shapiroPvalArray[s,a,] = o$shapiro.pval
      ksPvalArray[s,a,] = o$ks.pval
      nPoints[s,a,] = o$Npoints
      slopeArrayLow[s,a,] = o$slopeLow
      slopeArrayHigh[s,a,] = o$slopeHigh
      slopeArrayLow90[s,a,] = o$slopeLow90
      slopeArrayHigh90[s,a,] = o$slopeHigh90
      
    }
  }
  return(list(slopeArray=slopeArray,pValArray=pValArray,
              shapiroPvalArray=shapiroPvalArray,
              ksPvalArray=ksPvalArray,
              nPoints=nPoints,
              slopeArrayLow=slopeArrayLow,
              slopeArrayHigh=slopeArrayHigh,
              slopeArrayLow90=slopeArrayLow90,
              slopeArrayHigh90=slopeArrayHigh90))
}

###############################

plot_trends_boxes_new = function(instrument,
                                 site_list,
                                 site_labels,
                                 metric_list,
                                 plot.aggPeriod_list,
                                 x.index,
                                 slopeArrayLow,
                                 slopeArray,
                                 slopeArrayHigh,
                                 colData = 'lightblue',colARR = 'salmon',title_str=''){
  
  if (x.index=='GMT'){
    xlab = '%/degC'
    xlim = c(-30,70)
  } else if (X.index=='year'){
    xlim = c(-0.75,1.25)
    xlab = '%/year'
  }
  
  sl = c()
  for (s in 1:length(site_list)){
    site = site_list[s]
    sl[s] = Site_labels[[site]]
  }
  
  par(mfcol=c(4,4),mar=c(3,1,2,1),oma=c(1,8,2,1))
  mList = c(2,3,4,1)
  for (m in mList){
    metric = metric_list[m]
#    par(mfrow=c(4,1),mar=c(3,8,2,1),oma=c(1,1,2,1))
    for (a in 1:length(plot.aggPeriod_list)){
      aggPeriod = plot.aggPeriod_list[a]
      z = list()
#      low = slopeArrayLow[,a,m]
#      high = slopeArrayHigh[,a,m]
      z$stats = rbind(slopeArrayLow[,a,m],
                      slopeArrayLow[,a,m],
                      slopeArray[,a,m],
                      slopeArrayHigh[,a,m],
                      slopeArrayHigh[,a,m])
      z$names = sl
      
      #if ((metric!='mean')&(x.index=='GMT')){
      if (x.index=='GMT'){
        if ((metric!='mean')){
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
        } else {
          z$stats = cbind(z$stats,c(NA,NA,NA,NA,NA))
          z$names = c(z$names,'NA')
        }
      }
      if (m==2){
#        yaxt=NULL
      } else {
#        yaxt='n'
        z$names=rep('',length(z$names))
      }
      
      if (metric=='mean'){
        main = metric
      } else {
        main = paste0(metric,', ',plot.aggPeriod_list[a])
      }
      
      if ((aggPeriod==AggPeriod_list[1])|(metric!='mean')){
        bxp(z,horizontal = T,las=2,xlab='',ylim=xlim,
            main=main,
            boxfill=c(rep(colData,length(site_list)),colARR),cex.axis=0.75)
        mtext(side=1,text = xlab,cex=0.75,line=2)
        abline(v=0)
      } else {
        plot.new()
      }
    }
#    title(paste0(metric_list[m],' (',instrument,')'),outer=T)
    #title(instrument,outer=T)
    title(title_str,outer=T)
  }
}

###########################################################

plot_ave_slope = function(slopeArray,cSel=NULL){
  
 if (is.null(cSel)){cSel=1:dim(slopeArray)[1]}
  
  nAtt = dim(o$slopeArray)[2]
  nMet = dim(o$slopeArray)[3]
  
  aveSlope = matrix(nrow=nAtt,ncol=nMet)
  for (m in 1:nMet){
    for (a in 1:nAtt){
      aveSlope[a,m] = mean(slopeArray[cSel,a,m])
    }
  }
  
  ### assumes these agg periods have been used 
  x = c(12,30,60,180)
  par(mfrow=c(1,1),mar=c(4,4,1,1),oma=c(1,1,1,1))
  plot(x,aveSlope[,2],type='o',ylim=c(-20,30),log='x',col='red',xaxt='n',
       xlab='Duration',ylab='Change in metric (%/degC)')
  axis(side = 1, at = x,labels = c('12 mins','30 mins','1 hr','3 hrs'))
  lines(x,aveSlope[,3],type='o',col='magenta')
  lines(x,aveSlope[,4],type='o',col='cyan')
  abline(h=aveSlope[1,1],col='blue')
  abline(h=0,lty=2)
  legend('topright',c('Annual max','EY2','EY6','Mean'),col=c('red','magenta','cyan','blue'),lty=1)
  
}


