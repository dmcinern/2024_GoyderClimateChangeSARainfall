rm(list=ls())

library(ncdf4)
library(fields)
library(terra)

data.dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/'
shape.dirname = data.dirname

xlim=c(137,140);ylim=c(-36.5,-33.25)

date.start = as.Date('2019/06/09')
date.end = date.start

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/sa_state_polygon_shp/SA_STATE_POLYGON_shp.shp'
SA_border <- vect(fname)
plot(SA_border,type='l',xlim=xlim,ylim=ylim)

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/GreaterAdelaidePlanningRegion_shp/GreaterAdelaidePlanningRegion_GDA2020.shp'
GA <- vect(fname)
Greater_Ade_border = terra::project(GA,crs(SA_border))
lines(Greater_Ade_border,col='grey')

# col = colorRampPalette(c("white", "blue", "cyan", "green","yellow","orange","red","brown","black"))(50)

coords <- data.frame(lon=138.5196, lat=-34.9524)
pts <- vect(coords, crs="+proj=longlat")
Airport <- project(pts, crs(SA_border))
#x = xmin(lccpts); y = ymin(lccpts)
#xx=colFromX(p_raster, x)
#yy=rowFromY(p_raster, y)
points(Airport,col='red')


radius = 100000
delta = 128000

Npoints = 1000
radar_list = c('BuckPk','Sellicks')
colList = c('green','blue')
#for (radar in c('BuckPk','Sellicks')){
for (r in 1:length(radar_list)){
  radar = radar_list[r]
    
  if (radar=='BuckPk'){
    dirname = paste0(data.dirname,'BuckPk/tmp/')
    prefix = paste0(dirname,'BuckPk.64.')
  } else {
    dirname = paste0(data.dirname,'Sellicks/tmp/')
    prefix = paste0(dirname,'Sellick.46.')
  }
  
  dirname.date = paste0(prefix,format(date.start,'%Y%m%d'),'.prcp-c5/')
  fname = paste0(dirname.date,'_file_list')
  d = read.csv(fname,header=F)
  filenames = paste0(dirname.date,d[,1])
  fn = filenames[1]
  p_raster <- rast(fn)
  
  coords <- delta*data.frame(x=c(-1,1,1,-1,-1),y=c(-1,-1,1,1,-1))
  box <- vect(coords, geom=c('x','y'),crs=crs(p_raster))
  box <- project(box, crs(SA_border))
  lines(box,col=colList[r],lty=2)
  
  coords_circle = exp(2i * pi * (1:Npoints)/Npoints)
  coords_circle = radius*data.frame(x=Re(coords_circle),y=Im(coords_circle))
  pts_circle <- vect(coords_circle, geom=c('x','y'),crs=crs(p_raster))
  pts_circle <- project(pts_circle, crs(SA_border))
  lines(pts_circle,col=colList[r])
  
  
  
}

lon_min = 138.5; lon_max = 139
lat_min = -35.5; lat_max = -34.5

d_lon = lon_max-lon_min; d_lat = lat_max-lat_min

lon=lon_min+d_lon*c(0,1,1,0,0)
lat=lat_min+d_lat*c(0,0,1,1,0)

coords <- data.frame(lon=lon,lat=lat)
box <- vect(coords, crs=crs(SA_border))
lines(box,col='magenta')


pause





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

#  for (i in 1:length(filenames)){
  for (i in 1:10){
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

# if (make_plots){dev.off()}

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

