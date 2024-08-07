rm(list=ls())

library(ncdf4)
library(fields)
library(terra)

#radar = 'Sellicks'
radar = 'BuckPk'

#dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/BuckPk.64.20190608.prcp-c5/'
#dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/prcp-c5/'
#tar.file = 'BuckPk.64.20190608.prcp-c5.tar'

#fname = paste0(dirname,tar.file)
#untar(fname)

#dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/prcp-c5/BuckPk.64.20190608.prcp-c5/'

if (radar=='BuckPk'){
  dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/'
  prefix = paste0(dirname,'BuckPk.64.')
} else {
  dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/Sellicks/tmp/'
  prefix = paste0(dirname,'Sellick.46.')
}

#date.start = as.Date('2019/06/08')
date.start = as.Date('2019/06/09')
#date.end = as.Date('2019/06/08')
#date.end = as.Date('2019/06/13')
#date.end = as.Date('2019/06/30')
date.end = as.Date('2019/06/11')
#date.end = date.start

Pmax = Psite = P_max_GA_vec = c()

make_plots = F

if (make_plots){pdf(file=paste0(dirname,'radar.pdf'))}

#fname='C:/Users/a1065639/Downloads/STE_2021_AUST_SHP_GDA2020/STE_2021_AUST_GDA2020.shp'
# fname='C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/STE_2021_AUST_SHP_GDA2020/STE_2021_AUST_GDA2020.shp'
#
# p <- vect(fname)

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/sa_state_polygon_shp/SA_STATE_POLYGON_shp.shp'
p <- vect(fname)

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/GreaterAdelaidePlanningRegion_shp/GreaterAdelaidePlanningRegion_GDA2020.shp'
GA <- vect(fname)

GA_1 = terra::project(GA,crs(p))

col = colorRampPalette(c("white", "blue", "cyan", "green","yellow","orange","red","brown","black"))(50)

#dirname.date = paste0(dirname,'BuckPk.64.',format(date.start,'%Y%m%d'),'.prcp-c5/')
#dirname.date = paste0(dirname,'Sellick.46.',format(date.start,'%Y%m%d'),'.prcp-c5/')
dirname.date = paste0(prefix,format(date.start,'%Y%m%d'),'.prcp-c5/')
fname = paste0(dirname.date,'_file_list')
d = read.csv(fname,header=F)
filenames = paste0(dirname.date,d[,1])
fn = filenames[1]
p_raster <- rast(fn)
coords <- data.frame(lon=138.5196, lat=-34.9524)
pts <- vect(coords, crs="+proj=longlat")
lccpts <- project(pts, crs(p_raster))
x = xmin(lccpts); y = ymin(lccpts)
xx=colFromX(p_raster, x)
yy=rowFromY(p_raster, y)



date.fmt = format(seq(date.start,date.end,by='days'),'%Y%m%d')

for (date. in date.fmt){

  print(date.)

  #dirname.date = paste0(dirname,'BuckPk.64.',date.,'.prcp-c5/')
  #dirname.date = paste0(dirname,'Sellick.46.',date.,'.prcp-c5/')
  dirname.date = paste0(prefix,date.,'.prcp-c5/')

  fname = paste0(dirname.date,'_file_list')

  d = read.csv(fname,header=F)

  #BuckPk.64.20190608.prcp-c5
  #BuckPk.64.20190613.prcp-c5

  filenames = paste0(dirname.date,d[,1])

  for (i in 1:length(filenames)){
#  for (i in 1:20){
    fn = filenames[i]
    #print(i)
    #nc <- nc_open(fn)
    #data <- ncvar_get(nc,varid='precipitation')
    #Grab the values
    #P <- ncvar_get(nc,"precipitation")
    #x <- ncvar_get(nc, 'x')
    #y <- ncvar_get(nc, 'y')
    #nc_close( nc )
    #Take a look
    #image.plot(P,main=as.character(d[i,1]),ylim=c(0,4))

    p_raster <- rast(fn)
    p_raster_1 = terra::project(p_raster,crs(p))

    #oz::sa(add=T)
    #Pmax = c(Pmax,max(P,na.rm=T))

    P = values(p_raster_1)

    Pmax = c(Pmax,max(P,na.rm=T))

    Ps = terra::extract(x=p_raster,y=lccpts)$precipitation

    #Psite = c(Psite,extract(x=p_raster,y=matrix(c(xx,yy),nrow = 1)))
    Psite = c(Psite,Ps)

    P_GA = terra::extract(p_raster_1,GA_1)$precipitation

    P_max_GA = max(P_GA,na.rm=T)

    P_max_GA_vec = c(P_max_GA_vec,P_max_GA)

    #print(Ps)

    if (make_plots){

      plot(p_raster_1,range=c(0,2),col=col)
      # location of max radar rainfall
      i=which(P==max(P,na.rm=T))
      xy = xyFromCell(p_raster_1,i)
      points(xy,col='magenta',cex=5)

      # location of max GA radar rainfall
      i=which(P==P_max_GA)
      xy = xyFromCell(p_raster_1,i)
      points(xy,col='red',cex=4)

      # Adelaide airport
      points(x=coords[1],y=coords[2],col='magenta',cex=5,pch=4)

      # state boundary
      lines(p)

      # greater adelaide boundary
      lines(GA,col='red')

      title(d[i,1])

    }

  }

}

par(mfrow=c(2,1))

plot(Psite,type='l')

load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
i.start=which(out$date == date.start)
i.end=which(out$date == date.end)
keep = i.start:i.end
plot(out$date[keep],out$P[keep],type='l')

if (make_plots){dev.off()}

pause

#xy <- cbind(lon=c(10,5), lat=c(15, 88))






# cc = crds(p_raster)
# dd = crds(lccpts)
# diff1 = cc[,1] -dd[1]
# diff2 = cc[,2] -dd[2]
# diff=sqrt(diff1^2+diff2^2)
# min(diff)
# i = which(diff==min(diff))
# x = cc[i,1]
# y = cc[i,2]
#
# coords <- data.frame(x=x, y=y)
# pts <- vect(coords, crs=crs(p_raster))

colFromX(p_raster,coords$lon)
rowFromY(p_raster,coords$lat)

