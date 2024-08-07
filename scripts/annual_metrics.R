calc_EY = function(P,date,dateThreshInDays=1,EYvec){

  sort.tmp = sort(P,decreasing = T,index.return=T)
  P.sort = sort.tmp$x
  i.sort = sort.tmp$ix
  date.sort = date[i.sort]

  EY = P.sort[1]
  date.EY = date.sort[1]
  for (i in 2:length(P.sort)){
    timeDiffDays = as.numeric(difftime(date.sort[i],date.EY,units='days'))
    if (min(abs(timeDiffDays))>dateThreshInDays){
      EY = c(EY,P.sort[i])
      date.EY = c(date.EY,date.sort[i])
    }
    if (length(EY)>=max(EYvec)) break
  }

  # out = list(EY,date.EY)

  return(EY[EYvec])

}

calc_annual_metrics = function(agg_data,
                               metric_list = c('P99','P99.9','mean','max','EY1','EY3','EY6'),
                               load_annual_metrics=F){

  if (is.null(agg_data)){
    cat('agg_data NULL \n')
    return(NULL)
  }

  annual_metrics_RData_fname = strsplit(agg_data$agg_RData_fname,'.agg.RData',fixed=T)[[1]]
  annual_metrics_RData_fname = paste0(annual_metrics_RData_fname,
                           '.metrics.RData')

  if (!(file.exists(annual_metrics_RData_fname))){load_annual_metrics=F}

  if (load_annual_metrics){
    load(annual_metrics_RData_fname)
  }

  else {

    dtDays = as.numeric(difftime(agg_data$date[2],agg_data$date[1],units='days'))

    year.min = as.integer(format(agg_data$date[1],'%Y'))
    year.max = as.integer(format(agg_data$date[length(agg_data$date)],'%Y'))

    year_vec = year.min:year.max
    # metrics = matrix(nrow=length(year.min:year.max),ncol=(length(probs)+2+length(EYvec)))
    # colnames(metrics)= c(paste0('P',probs*100),'max','mean',paste0('EY',EYvec))
    metrics = metrics.dates = matrix(nrow=length(year.min:year.max),ncol=(length(metric_list)))
    colnames(metrics)= colnames(metrics.dates)= metric_list
    #metrics.dates = as.data.frame(metrics,class='Date')

    i_mean = which(metric_list=='mean')
    i_max = which(metric_list=='max')
    i_P = which(startsWith(metric_list,'P'))
    v=unlist(lapply(metric_list[i_P],strsplit,'P'))
    par_P = as.numeric(v[v!=''])/100.

    i_EY = which(startsWith(metric_list,'EY'))
    v=unlist(lapply(metric_list[i_EY],strsplit,'EY'))
    par_EY = as.numeric(v[v!=''])

    #metrics.dates = list()
    #metrics.dates = data.frame

    #metrics.dates$max = c()
    #metrics.dates$max = list()

    missing = c()
    year.all = as.integer(format(agg_data$date,'%Y'))
    for(y in 1:length(year_vec)){
      # print(y)

      # if (y==48){browser()}

      i = which(year.all==year_vec[y])

      if (all(is.na(agg_data$P[i]))){
        metrics[y,] = NA
        missing[y] = 1
      } else {

        # metrics[y,1:length(probs)] = quantile(agg_data$P[i],probs=probs,na.rm=T)
        # metrics[y,(length(probs)+1)] = max(agg_data$P[i],na.rm=T)
        # metrics[y,(length(probs)+2)] = mean(agg_data$P[i],na.rm=T)
        # metrics[y,(length(probs)+3):(length(probs)+5)] = calc_EY(P=agg_data$P[i],date=agg_data$date[i],EYvec=EYvec)

        metrics[y,i_mean] = mean(agg_data$P[i],na.rm=T)

        mm = max(agg_data$P[i],na.rm=T)
        metrics[y,i_max] = mm
        ii = which(agg_data$P[i]==mm)
        metrics.dates[y,i_max] = agg_data$date[i][[ii[1]]]
        #metrics.dates$max[[y]] = agg_data$date[i][[ii[1]]]

        metrics[y,i_P] = quantile(agg_data$P[i],probs=par_P,na.rm=T)

        mm = calc_EY(P=agg_data$P[i],date=agg_data$date[i],EYvec=par_EY)
        metrics[y,i_EY] = mm
        for (j in 1:length(i_EY)){
          ii = which(agg_data$P[i]==mm[j])
          if (length(ii)==0){
            metrics.dates[y,i_EY[j]] = NA
          } else {
            metrics.dates[y,i_EY[j]] = agg_data$date[i][[ii[1]]]
          }

          #metrics.dates[[metric_list[i_EY[j]]]][[y]] = agg_data$date[i][[ii[1]]] # use first value for ii (in case more than 1)
        }

        # print(metrics[y,])
        missing[y] = length(which(is.na(agg_data$P[i])))/length(agg_data$P[i])
      }

    }

    # exclude = which(missing>missing_year_thresh)
    # metrics_excl_missing = metrics
    # metrics_excl_missing[exclude,] = NA
    # missing_years = year_vec[missing>missing_year_thresh]

    # if (do_quantile_regression){
    #   P = agg_data$P
    #   if (!is.null(missing_year_thresh)){
    #     P[year.all %in% missing_years] = NA
    #   }
    #   rqfit = rq(P ~ year.all,tau = probs)
    #   rqsummary = summary(rqfit)
    #   lmfit = lm(P ~ year.all)
    #   lmsummary = summary(lmfit)
    # } else {
    #   rqfit = rqsummary = lmfit = lmsummary = NULL
    # }
    #
    # intercept = slope = pval = c()
    # if (do_regression_metrics){
    #   for (m in 1:dim(metrics)[2]){
    #     lmfit_summary = summary(lm(metrics_excl_missing[,m]~year_vec))
    #     coeff = lmfit_summary$coefficients
    #     intercept[m] = coeff[1,1]
    #     slope[m] = coeff[2,1]
    #     pval[m] = coeff[2,4]
    #   }
    # }

    # out = list(year=year_vec,metrics=metrics,missing=missing,
    #            rqfit=rqfit,rqsummary=rqsummary,
    #            lmfit=lmfit,lmsummary=lmsummary,
    #            missing_years=missing_years,
    #            missing_year_thresh=missing_year_thresh,
    #            metrics_excl_missing=metrics_excl_missing,
    #            intercept=intercept,
    #            slope=slope,
    #            pval=pval)

    out = list(year=year_vec,metrics=metrics,metrics.dates=metrics.dates,missing=missing,dtDays=dtDays)

    save(file=annual_metrics_RData_fname,out)

  }

  return(out)

}
