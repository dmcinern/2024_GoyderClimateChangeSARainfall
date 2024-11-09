specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))

##########################

plot_annual_metrics = function(annual_metrics_list,site,
                               instrument_list,
                               metric_list,
                               aggPeriod,
                               colList = c('red','blue','green'),
                               pchGood = 16, pchBad = 1, cexList = c(2,1.5,1),
                               missing_year_thresh,
                               nonsite_year_thresh,
                               year.min=NULL,year.max=NULL,x.index='GMT',
                               plot_linear=T,
                               combine_sources_sites=F,
                               site_labels){


  yearCombo = c()
  year = list()
  for (i in 1:length(instrument_list)){
    year[[i]] = annual_metrics_list[[site]][[instrument_list[i]]][[aggPeriod]]$year
    yearCombo = c(yearCombo,year[[i]])
  }

  yearCombo = sort(unique(yearCombo))

  if (is.null(year.min)){
    year.min = -99999
  }
  if (is.null(year.max)){
    year.max = +99999
  }
  keep = which((yearCombo>=year.min)&(yearCombo<=year.max))

  yearComboTrunc = yearCombo[keep]


  # if (!is.null(year.min)){
  #   yearCombo = yearCombo[(yearCombo>=year.min)]
  # }
  # if (!is.null(year.max)){
  #   yearCombo = yearCombo[(yearCombo<=year.max)]
  # }

  year_in_yearCombo = missingMat = matrix(nrow=length(instrument_list),ncol=length(yearCombo))
  missingYears = missingSiteYears = nonsiteYears = list()
  for (i in 1:length(instrument_list)){
    year_in_yearCombo[i,] = yearCombo%in%year[[i]]
    missingMat[i,year_in_yearCombo[i,]] = annual_metrics_list[[site]][[instrument_list[i]]][[aggPeriod]]$missing
    missingYears[[i]] = missingMat[i,] > missing_year_thresh
    missingYears[[i]] = missingYears[[i]][keep]
    if (instrument_list[i]=='combo_sources_sites'){
      nonsiteYears[[i]] = 1-apply(annual_metrics_list[[site]][[instrument_list[i]]][[aggPeriod]]$sources.years[,c('AWS.site','pluvio.site')],1,sum)
      missingSiteYears[[i]] = nonsiteYears[[i]] > nonsite_year_thresh
    }
  }
  missingMat = matrix(missingMat[,keep],nrow=length(instrument_list))


  # rqfit = rqsummary = lmfit = lmsummary = list()
  # for (i in 1:length(instrument_list)){
  #   rqfit[[i]] = annual_metrics_list[[site]][[i]][[aggPeriod]]$rqfit
  #   rqsummary[[i]] = annual_metrics_list[[site]][[i]][[aggPeriod]]$rqsummary
  #   lmfit[[i]] = annual_metrics_list[[site]][[i]][[aggPeriod]]$lmfit
  #   lmsummary[[i]] = annual_metrics_list[[site]][[i]][[aggPeriod]]$lmsummary
  # }
  metricList = colnames(annual_metrics_list[[1]][[1]][[aggPeriod]]$metrics)

  slopeMat = slopeMatLow = slopeMatHigh = intMat = pValMat = matrix(nrow=length(metricList),ncol=length(instrument_list))
  metComboMeanVec = c()

  metMatMissing = list()

  if (x.index=='GMT'){
    fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/GMT.txt'
    d = read.table(fname,skip=5)
    GMT.year = d$V1
    GMT.anom = d$V2
    keepGMT = which(GMT.year%in%yearComboTrunc)
    x = GMT.anom[keepGMT]
    plot.type = 'p'
  } else if (x.index=='year'){
    x = yearComboTrunc
    plot.type = 'o'
  }

  #xlim = c(min(yearComboTrunc),max(yearComboTrunc)) # GMT here
  xlim = c(min(x),max(x))

  for (m in 1:length(metricList)){

    metMat = metMatMissing = matrix(nrow=length(instrument_list),ncol=length(yearCombo))
    if (metric_list[m]=='mean'){
      dtDays = annual_metrics_list[[1]][[1]][[aggPeriod]]$dtDays
      fac = 365/dtDays
      units = 'mm/yr'
    } else {
      fac = 1
      units = 'mm'
    }
    for (i in 1:length(instrument_list)){
      metMat[i,year_in_yearCombo[i,]] = annual_metrics_list[[site]][[instrument_list[i]]][[aggPeriod]]$metrics[,m]*fac
      # metMatMissing[[m]][i,year_in_yearCombo[i,]] = annual_metrics_list[[site]][[i]][[aggPeriod]]$metrics_excl_missing[,m]
      metMatMissing[i,] = metMat[i,]
      metMatMissing[i,missingYears[[i]]] = NA
    }
#    metMean = mean(apply(metMat,2,mean,na.rm=T),na.rm=T)
    # metMean[[m]] = mean(apply(metMatMissing[[m]],2,mean,na.rm=T),na.rm=T)

    ############

    metMatMissing = matrix(metMatMissing[,keep],nrow=length(instrument_list))
    metMat = matrix(metMat[,keep],nrow=length(instrument_list))

    ############

    if (length(instrument_list)>1){
      metCombo = apply(metMatMissing,2,mean,na.rm=T)
    } else {
      metCombo = as.matrix(metMatMissing,nrow=1)
    }
    metComboMean = mean(metCombo,na.rm=T)

    metComboMeanVec[m] = metComboMean

    # metMat = metMat / metMean[[m]]
    # metMatMissing[[m]] = metMatMissing[[m]] / metMean[[m]]
    ylim = c(min(metMat,na.rm=T),max(metMat,na.rm=T))
    plot(x=NULL,y=NULL,
         xlim=xlim,ylim=ylim,
         xlab='year',ylab=paste0(metricList[m],' (',units,')'))
    for (i in 1:length(instrument_list)){
      # pchVec = rep(pchGood,length(yearCombo)); pchVec[missingYears[[i]]]=pchBad
      # lines(yearComboTrunc,metMat[i,],col=colList[i],type='o',pch=pchVec,cex=cexList[i],lwd=0.5)

      good = metMat[i,]; good[missingYears[[i]]] = NA
#      lines(yearComboTrunc,good,col=colList[i],type='o',pch=pchGood,cex=cexList[i],lwd=0.5) # GMT here
      lines(x,good,col=colList[i],type=plot.type,pch=pchGood,cex=cexList[i],lwd=0.5) # GMT here
      bad = metMat[i,]; bad[!missingYears[[i]]] = NA
#      points(yearComboTrunc,bad,col=colList[i],pch=pchBad,cex=cexList[i]/2,lwd=0.5) # GMT here
      points(x,bad,col=colList[i],pch=pchBad,cex=cexList[i]/2,lwd=0.5) # GMT here
    }
    if (m==1){
      legend('top',horiz=T,
             c(instrument_list,'incl.','excl.'),
             col=c(colList[1:length(instrument_list)],'black','black'),
             lwd=c(0.5,0.5,NA,NA),
             pch=c(NA,NA,pchGood,pchBad))
    }
    text_title = ''
    # if (use_quantile_regression|use_regression_metrics){
    for (i in 1:length(instrument_list)){
      instrument = instrument_list[i]
    #     if (use_quantile_regression){
    #       if (m<3){
    #         coeff = rqfit[[i]]$coefficients[,m]/metMean[[m]]
    #         a = coeff[1]; b = coeff[2]
    #         pval = rqsummary[[i]][[m]]$coefficients[2,4]
    #       } else if (m==4) {
    #         coeff = lmfit[[i]]$coefficients/metMean[[m]]
    #         a = coeff[1]; b=coeff[2]
    #         pval = lmsummary[[i]]$coefficients[2,4]
    #       } else {
    #         a = b = pval = NA
    #       }
    #     } else if (use_regression_metrics){
          # mm = annual_metrics_list[[site]][[i]][[aggPeriod]]
          # a = mm$intercept[m]/metMean[[m]]
          # b = mm$slope[m]/metMean[[m]]
          # pval = mm$pval[m]
        # }
#      lmfit = lm(metMatMissing[i,]~yearComboTrunc) # GMT here
      lmfit = lm(metMatMissing[i,]~x)
      lmsummary = summary(lmfit)
      coeff = lmsummary$coefficients
      a = coeff[1,1]; b = coeff[2,1]
      pval = coeff[2,4]
      # anorm = a/metComboMean; bnorm = b/metComboMean
      slopeMat[m,i] = b; intMat[m,i] = a; pValMat[m,i] = pval

      CI = confint(lmfit,level = 0.66)
      slopeMatLow[m,i] = CI[2,1]
      slopeMatHigh[m,i] = CI[2,2]

      if (!is.na(pval)&(pval<0.05)){
        lty=1
      } else {
        lty=2
      }
#      lines(x=year[[i]],y=a+b*year[[i]],col=colList[i],lwd=1,lty=lty)
      if (plot_linear){
        lines(x=xlim,y=a+b*xlim,col=colList[i],lwd=1,lty=lty)
        if (!is.na(pval)){
          text_title = paste0(text_title,instrument,': slope=',specify_decimal(100*b/metComboMean,2),
                              '%/',x.index,' pval=',specify_decimal(pval,2),
                              ', N=',length(which(!is.na(metMatMissing[i,]))), '\n')
        }
      }

    }

    if (length(instrument_list)>1){
      for (i1 in 1:(length(instrument_list)-1)){
        for (i2 in (i1+1):length(instrument_list)){
#          cor_combo = cor(metMat[i1,],metMat[i2,],use = 'pairwise.complete.obs')
          cor_overlap = cor(metMatMissing[i1,],metMatMissing[i2,],use = 'pairwise.complete.obs')
          text_overlap = paste0('cor(',instrument_list[i1],',',instrument_list[i2],')=',specify_decimal(cor_overlap,2),'. ')
          text_title = paste0(text_title,text_overlap)
        }
      }
    }
    title(text_title,cex.main=0.85,line=0.2)
  }

  #ylim=c(min(missingMat,nonsiteYears,na.rm=T),max(missingMat,nonsiteYears,na.rm=T))
  ylim=c(0,0.2)
  plot(x=NULL,y=NULL,xlim=xlim,ylim=ylim,
       xlab='year',ylab='proportion missing')
  nPoints = c()
  for (i in 1:length(instrument_list)){
    # pchVec = rep(pchGood,length(yearCombo)); pchVec[missingMat[i,]>missing_year_thresh]=pchBad
    # lines(yearComboTrunc,missingMat[i,],col=colList[i],type='o',pch=pchVec,lwd=0.5,cex=cexList[i])

    #############
    
    good = missingMat[i,]; good[missingYears[[i]]] = NA
    # points(yearComboTrunc,good,col=colList[i],type='o',pch=pchGood,cex=cexList[i],lwd=0.5) # GMT here
    points(x,good,col=colList[i],type=plot.type,pch=pchGood,cex=cexList[i],lwd=0.5) # GMT here
    bad = missingMat[i,]; bad[!missingYears[[i]]] = NA
    #points(yearComboTrunc,bad,col=colList[i],pch=pchBad,cex=cexList[i]/2,lwd=0.5) # GMT here
    points(x,bad,col=colList[i],pch=pchBad,cex=cexList[i]/2,lwd=0.5) # GMT here
    #lines(yearComboTrunc,missingMat[i,],col=colList[i],lwd=0.5) # GMT here
    lines(x,missingMat[i,],col=colList[i],lwd=0.5,type=plot.type) # GMT here

    #############

    if (combine_sources_sites){
      good = nonsiteYears[[i]]; good[nonsiteYears[[i]]] = NA
      points(x,good,col='cyan',type=plot.type,pch=pchGood,cex=cexList[i],lwd=0.5) # GMT here
      bad = nonsiteYears[[i]]; bad[!nonsiteYears[[i]]] = NA
      points(x,bad,col='cyan',pch=pchBad,cex=cexList[i]/2,lwd=0.5) # GMT here
      lines(x,nonsiteYears[[i]],col='cyan',lwd=0.5,type=plot.type) # GMT here
    }
    
    
    #############
    
    nPoints[i] = length(which(!is.na(good)))

  }
  abline(h=missing_year_thresh,lty=2)
  if (combine_sources_sites){
    abline(h=nonsite_year_thresh,lty=2,col='cyan')
  }
  title(paste0(site_labels[site],' (',site,'), ',aggPeriod),outer=T)

  return(list(slopeMat=slopeMat,slopeMatLow=slopeMatLow,slopeMatHigh=slopeMatHigh,
              intMat=intMat,
              pValMat=pValMat,
              metComboMeanVec=metComboMeanVec,
              nPoints=nPoints))

}

##########################

plot_annual_metrics_cor = function(annual_metrics_list,xmetric='mean',ymetric,instrument_list,aggPeriod,
                                   colList = c('red','blue','green'),missing_year_thresh){

  for (i in 1:length(instrument_list)){
    m = annual_metrics_list[[site]][[instrument_list[i]]][[aggPeriod]]
    metrics = m$metrics
    missing = m$missing
    metrics[missing>missing_year_thresh]=NA
    if (i==1){
      plot(metrics[,xmetric],metrics[,ymetric],col=colList[i],xlab=xmetric,ylab=ymetric)
    } else {
      points(metrics[,xmetric],metrics[,ymetric],col=colList[i])
    }
  }

}

##########################

plot_annual_metrics_multi = function(annual_metrics_list,site_list,plot.aggPeriod_list,metric_list,plot.instrument_list,missing_year_thresh,
                                     nonsite_year_thresh,x.index,plot_linear,plot.year.min,plot.year.max,combine_sources_sites,site_labels){
  
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
                              metric_list=metric_list,
                              missing_year_thresh = missing_year_thresh,
                              nonsite_year_thresh = nonsite_year_thresh,
                              year.min=plot.year.min,year.max=plot.year.max,
                              x.index=x.index,plot_linear = plot_linear,
                              combine_sources_sites=combine_sources_sites,
                              site_labels=site_labels)
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
  return(list(slopeArray=slopeArray,pValArray=pValArray,nPoints=nPoints,slopeArrayLow=slopeArrayLow,slopeArrayHigh=slopeArrayHigh))
}

##########################

plot_trends_boxes = function(plot.year.min,plot.year.max, 
                             colData = 'lightblue',colARR = 'salmon',
                             x.index,
                             plot.instrument_list,metric_list,plot.aggPeriod_list,
                             slopeArrayLow,
                             slopeArray,
                             slopeArrayHigh,
                             site_list){
  
  nYears = plot.year.max-plot.year.min+1
  
  if (x.index=='GMT'){
    xlab = '%/degC'
    xlim = c(-20,70)
    #  xlim = c(-15,50)
  } else if (X.index=='year'){
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
        abline(v=0)
      }
      title(paste(plot.instrument,metric_list[m]),outer=T)
    }
  }
  
}

##########################


