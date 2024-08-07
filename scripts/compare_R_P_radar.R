library(ncdf4)
library(fields)
library(terra)

col = colorRampPalette(c("white", "blue", "cyan", "green","yellow","orange","red","brown","black"))(50)

#fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/reflectivity/64_20190609.gndrefl/64_20190609_033000.gndrefl.nc'
fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/reflectivity/64_20190609.gndrefl/64_20190609_043000.gndrefl.nc'

nc1 = ncdf4::nc_open(fname)
R = ncdf4::ncvar_get(nc1,'reflectivity')
image(R)

r_raster <- rast(fname)
plot(r_raster,range=c(0,1),col=col)

#fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/BuckPk.64.20190609.prcp-c5/64_20190609_033000.prcp-c5.nc'
fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/BuckPk.64.20190609.prcp-c5/64_20190609_043000.prcp-c5.nc'
nc2 = nc_open(fname)
P = ncdf4::ncvar_get(nc2,'precipitation')
image(P)

p_raster <- rast(fname)


plot(p_raster,range=c(0,1),col=col)

###################################################

#i = 300; j = 300
#i = 250; j = 300
i = 266; j = 331

dirname.R = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/reflectivity/64_20190609.gndrefl/'
flist.R = list.files(dirname.R)
flist.R = paste0(dirname.R,flist.R)

# i = 300; j = 300
t.R = R.site = c()
for (f in 1:length(flist.R)){
  nc.R = ncdf4::nc_open(flist.R[f])
  t.R[f] = ncdf4::ncvar_get(nc.R,'valid_time')
  R = ncdf4::ncvar_get(nc.R,'reflectivity')
  R.site[f] = R[i,j]
}

t.R.start. = as.POSIXct(t.R[1],origin = as.POSIXct('1970-01-01 00:00:00'),tz='GMT')
t.R.end = as.POSIXct(t.R[length(t.R)],origin = as.POSIXct('1970-01-01 00:00:00'),tz='GMT')

#dirname.P = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/BuckPk.64.20190609.prcp-c5/'
dirname.P = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/BuckPk.64.20190610.prcp-c5/'
flist.P = list.files(dirname.P,pattern = '*.nc')
flist.P = paste0(dirname.P,flist.P)

t.P = P.site = c()
for (f in 1:length(flist.P)){
  nc.P = ncdf4::nc_open(flist.P[f])
  t.P[f] = ncdf4::ncvar_get(nc.P,'valid_time')
  P = ncdf4::ncvar_get(nc.P,'precipitation')
  P.site[f] = P[i,j]
}

###

t.R.start = as.POSIXct(t.R[1],origin = as.POSIXct('1970-01-01 00:00:00',tz='GMT')) - 60
t.R.end = as.POSIXct(t.R[length(t.R)],origin = as.POSIXct('1970-01-01 00:00:00',tz='GMT')) - 60

t.R.vec = seq(t.R.start,t.R.end,by='6 mins')

d1 <- data.frame(timePeriod = seq(from=t.R.start,
                                  to=t.R.end,
                                  by='30 mins'))


A = 100
B = 2
R.site.tranz = A*(R.site+32)^B

d2 <- data.frame(t.R.vec,R.site.tranz)

d3 = d2 %>%
  mutate(timePeriod = floor_date(t.R.vec, '30 mins')) %>%
  group_by(timePeriod) %>%
  summarise(sum=sum(R.site.tranz)) %>%
  right_join(d1)

R.site.tranz.agg = d3$sum

###

t.P.start = as.POSIXct(t.P[1],origin = as.POSIXct('1970-01-01 00:00:00'),tz='GMT')
t.P.end = as.POSIXct(t.P[length(t.P)],origin = as.POSIXct('1970-01-01 00:00:00'),tz='GMT')

t.P.vec = seq(t.P.start,t.P.end,by='5 mins')

timePeriod = seq(from=t.P.start,
                 to=t.P.end,
                 by='30 mins')

d1 <- data.frame(timePeriod = timePeriod)


d2 <- data.frame(t.P.vec,P.site)

d3 = d2 %>%
  mutate(timePeriod = floor_date(t.P.vec, '30 mins')) %>%
  group_by(timePeriod) %>%
  summarise(sum=sum(P.site)) %>%
  right_join(d1)

P.site.agg = d3$sum

plot(R.site.tranz.agg,P.site.agg)

###

load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")

i=which(out$date == t.P.start)

par(mfrow=c(2,1))
plot(d3$timePeriod,P.site.agg)
#plot(out$date[i:(i+47)], out$P[i:(i+47)])
plot(out$date[(i-48):(i+96)], out$P[(i-48):(i+96)])
###


