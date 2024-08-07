aggregate_data = function(processed_data,aggPeriod,load_agg_data,RData_dirname,
                          agg_data_thresh=0.8){

  if (is.null(processed_data)){
    cat('processed_data NULL \n')
    return(NULL)
  }

  agg_RData_fname = strsplit(processed_data$processed_RData_fname,'.processed.RData',fixed=T)[[1]]
  agg_RData_fname = paste0(agg_RData_fname,
                           '_aggPeriod.',gsub(" ", "", aggPeriod),
                           '_aggDataThresh.',agg_data_thresh,
                           '_agg.RData')

  if (!(file.exists(agg_RData_fname))){load_agg_RData=F}

  if (load_agg_RData){
    load(agg_RData_fname)
  }

  else {

    date = processed_data$date
    P = processed_data$P

    accPeriod = processed_data$accPeriod

#    P[accPeriod>aggPeriod] = NA

    d1 <- data.frame(timePeriod = seq(from=date[1],
                                      to=date[length(date)],
                                      by=aggPeriod))

    accRatio = length(P)/length(d1$timePeriod)

    if (accRatio==1){

      out = list(date=date,
                 P=P,
                 agg_RData_fname=agg_RData_fname)

    } else {

      P[accPeriod>accRatio] = NA

      d2 <- data.frame(date,P)

      d3 = d2 %>%
        mutate(timePeriod = floor_date(date, aggPeriod)) %>%
        group_by(timePeriod) %>%
        summarise(sum = sum_most(P,thresh=agg_data_thresh)) %>%
        right_join(d1)

      out = list(date=d3$timePeriod,
                 P=d3$sum,
                 agg_RData_fname=agg_RData_fname)

    }

    save(file=agg_RData_fname,out)

  }

  return(out)

}

#########################################

sum_most = function(x,thresh){
  N = length(x)
  N.missing = length(which(is.na(x)))
  p.missing = N.missing/N
  if (p.missing<(1-thresh)){
    y = mean(x,na.rm=T)*N
  } else {
    y = NA
  }
  return(y)
}
