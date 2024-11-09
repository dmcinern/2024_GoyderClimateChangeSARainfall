#####################################################################################

calc_EY = function(P,date,dateThreshInDays=1,EYvec){

  sort.tmp = sort(P,decreasing = T,index.return=T)
  P.sort = sort.tmp$x
  i.sort = sort.tmp$ix
  date.sort = date[i.sort]

  EY = P.sort[1]
  date.EY = date.sort[1]
#  for (i in 2:length(P.sort)){
  if (length(P.sort)>1){
    for (i in 2:length(P.sort)){
      #browser()
      timeDiffDays = as.numeric(difftime(date.sort[i],date.EY,units='days'))
      if(any(is.na(timeDiffDays))){browser()}
      if (min(abs(timeDiffDays))>dateThreshInDays){
        EY = c(EY,P.sort[i])
        date.EY = c(date.EY,date.sort[i])
      }
      if (length(EY)>=max(EYvec)) break
    }    
  }


  # out = list(EY,date.EY)

  return(EY[EYvec])

}

#####################################################################################

calc_annual_metrics = function(agg_data,
                               metric_list = c('P99','P99.9','mean','max','EY1','EY3','EY6'),
                               load_annual_metrics=F){

  if (is.null(agg_data)){
    cat('agg_data NULL \n')
    return(NULL)
  }

  annual_metrics_RData_fname = strsplit(agg_data$agg_RData_fname,'.RData',fixed=T)[[1]]
  annual_metrics_RData_fname = paste0(annual_metrics_RData_fname,
                           '.metrics.RData')

  if (!(file.exists(annual_metrics_RData_fname))){load_annual_metrics=F}

  if (load_annual_metrics){
    load(annual_metrics_RData_fname)
  }

  else {

    annual_metrics = calc_annual_metrics_core(agg_data,metric_list)
    
    if (!is.null(annual_metrics)){
      annual_metrics$annual_metrics_RData_fname = annual_metrics_RData_fname
      save(file=annual_metrics_RData_fname,annual_metrics)
    }
    
  }

  return(annual_metrics)

}

#####################################################################################

calc_annual_metrics_core = function(agg_data,metric_list,
                                    calc_seas_metrics=F){

  dtDays = as.numeric(difftime(agg_data$date[2],agg_data$date[1],units='days'))

  year.min = as.integer(format(agg_data$date[1],'%Y'))
  year.max = as.integer(format(agg_data$date[length(agg_data$date)],'%Y'))

  year_vec = year.min:year.max
  metrics = metrics.dates = matrix(nrow=length(year.min:year.max),ncol=(length(metric_list)))
  colnames(metrics)= colnames(metrics.dates)= metric_list

  i_mean = which(metric_list=='mean')
  i_max = which(metric_list=='max')
  i_P = which(startsWith(metric_list,'P'))
  v=unlist(lapply(metric_list[i_P],strsplit,'P'))
  par_P = as.numeric(v[v!=''])/100.

  i_EY = which(startsWith(metric_list,'EY'))
  v=unlist(lapply(metric_list[i_EY],strsplit,'EY'))
  par_EY = as.numeric(v[v!=''])

  sources = c('AWS.site','pluvio.site','AWS.nearbySite','pluvio.nearbySite','none')
  year.all = as.integer(format(agg_data$date,'%Y'))
  months.all = as.integer(format(agg_data$date,'%m'))
  
  if (calc_seas_metrics){
    seas_list = c('all','summer','autumn','winter','spring')
  } else {
    seas_list = c('all')
  }
  
  month_list = list(all=1:12,
                    summer=c(12,1,2),
                    autumn=c(3,4,5),
                    winter=c(6,7,8),
                    spring=c(9,10,11))
  
  out = list()
  
  for (seas in seas_list){ 
    print(seas)
    
    missing = c()
  #  sources = unique(agg_data$source)
    sources.years = matrix(data=0,nrow=length(year_vec),ncol=length(sources))
    colnames(sources.years) = sources
    for(y in 1:length(year_vec)){
#      print(paste(y,seas))
      if (seas=='all'){
        i = which(year.all==year_vec[y])
      } else {
        i = which((year.all==year_vec[y])&(months.all%in%month_list[[seas]]))
      }
      if (all(is.na(agg_data$P[i]))){
        metrics[y,] = NA
        missing[y] = 1
        if(!is.null(agg_data$source)){
          sources.years[y,'none'] = 1
        }
      } else {
  
        metrics[y,i_mean] = mean(agg_data$P[i],na.rm=T)
  
        mm = max(agg_data$P[i],na.rm=T)
        metrics[y,i_max] = mm
        ii = which(agg_data$P[i]==mm)
        metrics.dates[y,i_max] = agg_data$date[i][[ii[1]]]
  
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
        }
        missing[y] = length(which(is.na(agg_data$P[i])))/length(agg_data$P[i])
        for (source in sources){
          sources.years[y,source] = length(which(agg_data$source[i]==source))/length(agg_data$P[i])
        }
      }
  
      
    }
    
    out[[seas]] = list(year=year_vec,metrics=metrics,metrics.dates=metrics.dates,
                       missing=missing,sources.years=sources.years,
                       dtDays=dtDays)
    
  }

  return(out)

}

#####################################################################################

