rm(list=ls())

library(terra)

if (Sys.info()['sysname']=='Windows'){
  data.dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/Working/'
  shapefile.dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/'
} else {
  dirname = '../../../Data/Radar'
  shapefile.dirname = '../../../Data/Shapefiles'
}
RData.dirname = data.dirname
fig.dirname = data.dirname

#####################################################################

#radar = 'Sellicks'
radar = 'BuckPk'

year.start = 2020
year.end = 2020

make_plots = F

#####################################################################

sites.names = c('AdelaideAirport',
                'KentTown',
                'EdinburghRAAF')
sites.lon = c(138.5196,
              138.6216,
              138.6223)
sites.lat = c(-34.9524,
              -34.9211,
              -34.7111)

lon_min = 138.5; lon_max = 139
lat_min = -35.5; lat_max = -34.5

#####################################################################

fname = paste0(shapefile.dirname,'sa_state_polygon_shp/SA_STATE_POLYGON_shp.shp')
SA_boundary_latlon <- vect(fname)

fname = paste0(shapefile.dirname,'GreaterAdelaidePlanningRegion_shp/GreaterAdelaidePlanningRegion_GDA2020.shp')
GA_boundary_latlon <- vect(fname)
GA_boundary_latlon = terra::project(GA_boundary_latlon,crs(SA_boundary_latlon))

#####################################################################

if (radar=='BuckPk'){
  dirname = paste0(data.dirname,'BuckPk/prcp-c5/')
  prefix = paste0(dirname,'BuckPk.64.')
} else {
  dirname = paste0(data.dirname,'Sellicks/tmp/')
  prefix = paste0(dirname,'Sellick.46.')
}

date.start = as.Date('2019/06/08')
#date.start = as.Date('2019/06/09')
#date.end = as.Date('2019/06/08')
#date.end = as.Date('2019/06/13')
date.end = as.Date('2019/06/30')
#date.end = as.Date('2019/06/11')
#date.end = date.start

# if (make_plots){pdf(file=paste0(fig.dirname,'radar.pdf'))}

col = colorRampPalette(c("white", "blue", "cyan", "green","yellow","orange","red","brown","black"))(50)

#####################################################################

dirname.date = paste0(prefix,format(date.start,'%Y%m%d'),'.prcp-c5/')
fname = paste0(dirname.date,'_file_list')
d = read.csv(fname,header=F)
filenames = paste0(dirname.date,d[,1])
fn = filenames[1]
p_raster_xy_base <- rast(fn)

#####################################################################

coords_latlon <- data.frame(lon=sites.lon, lat=sites.lat)
coords_latlon_vect <- vect(coords_latlon, crs="+proj=longlat")
coords_xy_vect <- project(coords_latlon_vect, crs(p_raster_xy_base))
g = geom(coords_xy_vect)
x = g[,3]; y = g[,4]
colNum=colFromX(p_raster_xy_base, x)
rowNum=rowFromY(p_raster_xy_base, y)

extent_box_latlon = ext(lon_min,lon_max,lat_min,lat_max)

d_lon = lon_max-lon_min; d_lat = lat_max-lat_min
lon=lon_min+d_lon*c(0,1,1,0,0)
lat=lat_min+d_lat*c(0,0,1,1,0)
coords <- data.frame(lon=lon,lat=lat)
box_latlon <- vect(coords, crs=crs(SA_boundary_latlon))

#####################################################################

date.fmt = format(seq(date.start,date.end,by='days'),'%Y%m%d')

P_max_all_vec = P_sites_mat = P_max_GA_vec = P_max_box_vec = date_str_vec = c()

for (date. in date.fmt){

  print(date.)

  dirname.date = paste0(prefix,date.,'.prcp-c5/')

  fname = paste0(dirname.date,'_file_list')
  d = read.csv(fname,header=F)

  filenames = paste0(dirname.date,d[,1])

  par(mfrow=c(1,1))
  
  for (i in 1:length(filenames)){
    fn = filenames[i]
    
    a=strsplit(fn,'[/]')
    
    date_str = substr(a[[1]][11],4,18)
    date_str_vec = c(date_str_vec,date_str)

    p_raster_xy <- rast(fn)
    
    fname = paste0(fn,'.RData')
    
    save(file=fname,p_raster_xy)
    
    pause
    
    p_raster_latlon = terra::project(p_raster_xy,crs(SA_boundary_latlon))

    P_all = values(p_raster_latlon)
    P_max_all = max(P_all,na.rm=T)
    P_max_all_vec = c(P_max_all_vec,P_max_all)

    P_sites = terra::extract(x=p_raster_xy,y=coords_xy_vect)$precipitation
    P_sites_mat = rbind(P_sites_mat,P_sites)

    P_GA = terra::extract(p_raster_latlon,GA_boundary_latlon)$precipitation
    P_max_GA = max(P_GA,na.rm=T)
    P_max_GA_vec = c(P_max_GA_vec,P_max_GA)
    
    P_box = crop(p_raster_latlon,extent_box_latlon)
    P_max_box = max(values(P_box),na.rm=T)
    P_max_box_vec = c(P_max_box_vec,P_max_box)
    
    if (make_plots){

      plot(p_raster_latlon,range=c(0,2),col=col)
      
      # location of max radar rainfall
      if (P_max_all>0.2){
        i=which(P_all==P_max_all)
        xy = xyFromCell(p_raster_latlon,i)
        points(xy,col='green',cex=5)
      }

      # greater Adelaide boundary
      lines(GA_boundary_latlon,col='red')
      
      # location of max GA radar rainfall
      if (P_max_GA>0.2){
        i=which(P_all==P_max_GA)
        xy = xyFromCell(p_raster_latlon,i)
        points(xy,col='red',cex=4)
      }

      lines(box_latlon,col='orange')
      
      # location of max box radar rainfall
      if (P_max_box>0.2){
        i=which(P_all==P_max_box)
        xy = xyFromCell(p_raster_latlon,i)
        points(xy,col='orange',cex=4)
      }
      
      # Adelaide airport
      points(x=sites.lon,y=sites.lat,col='magenta',cex=1,pch=15)

      # state boundary
      lines(SA_boundary_latlon)
      
      title(a[[1]][length(a[[1]])])

    }

  }

}

out = list(P_max_all_vec = P_max_all_vec,
           P_sites_mat = P_sites_mat,
           P_max_GA_vec = P_max_GA_vec,
           P_max_box_vec = P_max_box_vec,
           date_str_vec = date_str_vec)

date_str_first = date_str_vec[1]
date_str_last = date_str_vec[length(date_str_vec)]

fname = paste0(RData.dirname,'out.',radar,'.',date_str_first,'.',date_str_last)
save(file=fname,out)

##############

par(mfrow=c(2,1))

plot(P_sites_mat[,1],type='l')

load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
i.start=which(out$date == date.start)
i.end=which(out$date == date.end) + 48
keep = i.start:i.end
plot(out$date[keep],out$P[keep],type='l')

##############

par(mfrow=c(2,1))

plot(P_sites_mat[,2],type='l')

load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023090_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
i.start=which(out$date == date.start)
i.end=which(out$date == date.end) + 48
keep = i.start:i.end
plot(out$date[keep],out$P[keep],type='l')

##############

par(mfrow=c(2,1))

#plot(P_sites_mat[,2],type='l')
plot(P_sites_mat[,3],type='l')

#load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023090_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023013_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
i.start=which(out$date == date.start)
i.end=which(out$date == date.end) + 48
keep = i.start:i.end
plot(out$date[keep],out$P[keep],type='l')

##############


