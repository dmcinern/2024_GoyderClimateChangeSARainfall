year.min.manual = year.max.manual = list()
year.min.manual[['023090']]=list(AWS=2003) # unrealistically large 30 min rainfall on 14/1/2002
year.max.manual[['023885']]=list(AWS=2022) # unrealistically large 30 min rainfall on 3/7/2023

period.remove = list()
period.remove[['023034']] = list()
# remove single date where unrealistic large accumulation has occurred
period.remove[['023034']]$AWS = list(start = as.POSIXct('2009-07-21 12:32:00',tz = 'GMT'),
                                     end = as.POSIXct('2009-07-21 12:32:00',tz = 'GMT'))



################################################

process_raw_data = function(raw_data,site,instrument,load_processed_RData=F,RData_dirname=NULL,
                            accum_handling = 'spread',
                            AWS_QC_keep='Y'){

  if (is.null(raw_data)){
    cat('raw_data NULL \n')
    return(NULL)
  }

  processed_RData_fname = strsplit(raw_data$raw_RData_fname,'.RData',fixed=T)[[1]]
  processed_RData_fname = paste0(processed_RData_fname,'_accumHandling.',accum_handling)
  processed_RData_fname = paste0(processed_RData_fname,'_processed.RData')

  if (!(file.exists(processed_RData_fname))){load_processed_RData=F}

  if (load_processed_RData){
    load(processed_RData_fname)
  }

  else {

    if (!is.null(year.min.manual[[site]][[instrument]])){
      year.min = year.min.manual[[site]][[instrument]]
    } else {
      year.min = as.integer(format(raw_data$date[1],'%Y'))+1
    }

    if (!is.null(year.max.manual[[site]][[instrument]])){
      year.max = year.max.manual[[site]][[instrument]]
    } else {
      year.max = as.integer(format(raw_data$date[length(raw_data$date)],'%Y'))-1
    }

    first.time = as.POSIXct(paste0(year.min,"/01/01 00:00"),tz='GMT')
    last.time = as.POSIXct(paste0(year.max,"/12/31 23:59"),tz='GMT')

    keep = which((as.POSIXct(raw_data$date,tz='GMT')>=first.time)&(as.POSIXct(raw_data$date,tz='GMT')<=last.time))
    date = raw_data$date[keep]

    first.day = as.Date(first.time)
    last.day = as.Date(last.time)

    date.days.1 = seq(first.time,last.time,by='days')

    date.days = seq(first.day,last.day,by='days')

    if (instrument=='AWS'){

      Precipitation.since.last.AWS.observation.in.mm = raw_data$Precipitation.since.last.AWS.observation.in.mm[keep]
      Quality.of.precipitation.since.last.AWS.observation.value = raw_data$Quality.of.precipitation.since.last.AWS.observation.value[keep]
      Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes = raw_data$Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes[keep]

      P = Precipitation.since.last.AWS.observation.in.mm
      period = Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes

        #P[Quality.of.precipitation.since.last.AWS.observation.value!='Y'] = NA
        P[!(Quality.of.precipitation.since.last.AWS.observation.value%in%AWS_QC_keep)] = NA
        # remove any data collected over more than 1 time step
        #P[Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes>1] = NA
      #}

      if (!is.null(period.remove[[site]]$AWS)){
        i.start = which(date==period.remove[[site]]$AWS$start)
        i.end = which(date==period.remove[[site]]$AWS$end)
        P[i.start:i.end] = NA
        period[i.start:i.end] = NA
      }

      if (accum_handling=='spread'){
        accumulation_indices = which(!is.na(period)&(period>1))
        Pnew = P
        accPeriod = rep(1,length(Pnew))
        for (j in 1:length(accumulation_indices)){
          i = accumulation_indices[j]
          accumulation_length = period[i]
          Pnew[(i-accumulation_length+1):i] = P[i]/accumulation_length
          accPeriod[(i-accumulation_length+1):i] = accumulation_length
        }
        P = Pnew
      } else if (accum_handling=='remove'){
        P[Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes>1] = NA
        accPeriod = rep(1,length(Pnew))
      } else {
        browser()
      }


      #####################

    } else if (instrument=='pluvio'){

      NperDay = 24*10

      P.mat = matrix(nrow = length(date.days),ncol=NperDay,data = 0)

      wetDayIndex = which(date.days%in%raw_data$date)

      P.mat[wetDayIndex,] = raw_data$P.MUSIC[keep,]/10.

      P = as.vector(t(P.mat))

      date = seq(first.time,last.time,by='6 min')

      ###################

      if (accum_handling=='spread'){
        Pnew = P
        N = length(P)

        # some periods of -888.8 (accumulations) have a single -999.9, corresponding to last interval of a day. replace these -999.9 with -888.8.
        dodgy = which((Pnew[1:(N-2)]==-888.8)&(Pnew[2:(N-1)]==-999.9)&(Pnew[3:N]==-888.8))
        if (length(dodgy)>0){
          Pnew[(dodgy+1)]=-888.8
        }

        start=which((Pnew[1:(N-1)]!=-888.8)&(Pnew[2:N]==-888.8))+1
        if(!is.na(Pnew[1])&(Pnew[1]==-888.8)){start=c(1,start)}
        end=which((Pnew[1:(N-1)]==-888.8)&(Pnew[2:N]!=-888.8))+1
        accPeriod = rep(1,N)
        if (length(start)>1){
          for (i in 1:length(start)){
            if (start[i]>=end[i]){browser()}
            if (Pnew[end[i]]==-888.8){browser()}
            accInterval = start[i]:end[i]
            if (Pnew[end[i]]==-999.9){
              Pnew[accInterval] = NA
              accPeriod[accInterval] = 1
            } else {
              Pnew[accInterval] = -Pnew[end[i]]/length(accInterval)
              accPeriod[accInterval] = length(accInterval)
              if (any(accPeriod[accInterval]!=accPeriod[accInterval[1]])){browser()}
            }
          }
        }
        P = Pnew
      } else if (accum_handling=='remove'){
        P[P<0] = NA
        accPeriod = rep(1,length(Pnew))
      } else {
        browser()
      }

      P[P==-999.9] = NA

      ###################

    } else if (instrument=='daily'){

      Rainfall.amount.millimetres = raw_data$Rainfall.amount.millimetres[keep]
      Period.over.which.rainfall.was.measured.days = raw_data$Period.over.which.rainfall.was.measured.days[keep]
      Quality=raw_data$Quality[keep]

      P = Rainfall.amount.millimetres

      #if (QCtype==1){
        # remove any data that does not pass quality check
        P[Quality!='Y'] = NA
        # remove any data collected over more than 1 time step
        P[Period.over.which.rainfall.was.measured.days>1] = NA
      #}

      accPeriod = NULL

      ###################

    }

    out = list(date=date,P=P,accPeriod=accPeriod,processed_RData_fname=processed_RData_fname)

    save(file=processed_RData_fname,out)

  }

  return(out)

}
