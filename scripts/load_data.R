load_raw_data = function(site,instrument,load_raw_RData,data_dirname,RData_dirname){

  raw_RData_fname = paste0(RData_dirname,instrument,'_',site,'.RData')

  if (!(file.exists(raw_RData_fname))){load_raw_RData=F}

  if (load_raw_RData){
    load(raw_RData_fname)
  }

  else {

    if (instrument=='AWS'){

      fname = paste0(data_dirname,'AWS/HD01D_Data_',site,'_9999999910567562.txt')

      if (!file.exists(fname)){
        cat('file ',fname,' does not exist \n')
        return(NULL)
      }

      d = as.matrix(data.table::fread(fname,nrows = 1,select=c(3,4,5,6,7)))

      Yr1 = d[1]
      Mon1 = d[2]
      Day1 = d[3]
      Hr1 = d[4]
      Min1 = d[5]
      date1 = as.POSIXct(paste0(Yr1,'/',Mon1,'/',Day1,' ',Hr1,':',Min1),format ='%Y/%m/%d %H:%M',tz='GMT')

      Precipitation.since.last.AWS.observation.in.mm = as.matrix(data.table::fread(fname,select=13)[,1])

      N = length(Precipitation.since.last.AWS.observation.in.mm)

      date=date1+seq(0,(N-1)*60,60)

      # Yr = as.matrix(data.table::fread(fname,select=3)[,1])
      # Mon = as.matrix(data.table::fread(fname,select=4)[,1])
      # Day = as.matrix(data.table::fread(fname,select=5)[,1])
      # Hr = as.matrix(data.table::fread(fname,select=6)[,1])
      # Min = as.matrix(data.table::fread(fname,select=7)[,1])
      #
      # date = as.POSIXct(paste0(Yr,'/',Mon,'/',Day,' ',Hr,':',Min),format ='%Y/%m/%d %H:%M',tz='GMT')

      Quality.of.precipitation.since.last.AWS.observation.value = as.matrix(data.table::fread(fname,select=14)[,1])

      Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes = as.matrix(data.table::fread(fname,select=15)[,1])

      raw_data = list(date=date,
                       Precipitation.since.last.AWS.observation.in.mm=Precipitation.since.last.AWS.observation.in.mm,
                       Quality.of.precipitation.since.last.AWS.observation.value=Quality.of.precipitation.since.last.AWS.observation.value,
                       Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes=Period.over.which.precipitation.since.last.AWS.observation.is.measured.in.minutes)

    } else if (instrument=='pluvio'){

      #fname = paste0('C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/tmp/pluvio/outputFor',site,'_9999999910567597.txt')
      fname = paste0(data_dirname,'pluvio/outputFor',as.integer(site),'_9999999910567597.txt')

      if (!file.exists(fname)){
        cat('file ',fname,' does not exist')
        return(NULL)
      }

      d = read.fwf(fname,widths=c(12,4,2,2,rep(7,240)),skip=2)

      Yr = d[,2]
      Mon = d[,3]
      Day = d[,4]

      date.MUSIC = as.Date(paste0(Yr,'/',Mon,'/',Day))

      P.MUSIC = as.matrix(d[,5:dim(d)[2]])

      raw_data = list(date=date.MUSIC,
                       P.MUSIC=P.MUSIC)

    } else if (instrument=='daily'){

      fname = paste0(data_dirname,'daily/IDCJAC0009_',site,'_1800_Data.csv')

      d = read.csv(fname,header=T)

      Yr = d$Year
      Mon = d$Month
      Day = d$Day

      date.day = as.Date(paste0(Yr,'/',Mon,'/',Day))

      Rainfall.amount.millimetres = d$Rainfall.amount..millimetres.
      Period.over.which.rainfall.was.measured.days = d$Period.over.which.rainfall.was.measured..days.
      Quality=d$Quality

      raw_data = list(date=date.day,
                      Rainfall.amount.millimetres=Rainfall.amount.millimetres,
                      Period.over.which.rainfall.was.measured.days=Period.over.which.rainfall.was.measured.days,
                      Quality=Quality)

    }

    save(file=raw_RData_fname,raw_data)

  }

  raw_data$raw_RData_fname=raw_RData_fname

  return(raw_data)


}
