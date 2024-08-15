rm(list=ls())

library(terra)

if (Sys.info()['sysname']=='Windows'){
  data.dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/Working/'
  shapefile.dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/'
  RData.dirname = data.dirname
  fig.dirname = data.dirname
} else {
  data.dirname = '../../../Data/Radar/'
  shapefile.dirname = '../../../Data/Shapefiles/'
  RData.dirname = '../RData/Radar/'
  fig.dirname = '../figures/Radar/'
}

#####################################################################

args = commandArgs(trailingOnly=TRUE)
radar = args[1]
year = as.integer(args[2])
month = as.integer(args[3])

#radar = 'Sellicks'
#radar = 'BuckPk'
#year = 2021
#month = 1

prcp = 'prcp-c5'

make_plots = F

agg_data_thresh = 0.8

#####################################################################

aggPeriod_list = c('5 mins','10 mins','30 mins','1 hour','3 hours')

#####################################################################

sites.names = c('AdelaideAirport',
                'KentTown',
                'EdinburghRAAF',
		'Hindmarsh Valley')

sites.lon = c(138.5196,
              138.6216,
              138.6223,
              138.5751)
sites.lat = c(-34.9524,
              -34.9211,
              -34.7111,
              -35.4123)

lon_min = 138.25; lon_max = 139
lat_min = -35.5; lat_max = -34.5

#####################################################################

fname = paste0(shapefile.dirname,'sa_state_polygon_shp/SA_STATE_POLYGON_shp.shp')
SA_boundary_latlon <- vect(fname)

#fname = paste0(shapefile.dirname,'GreaterAdelaidePlanningRegion_shp/GreaterAdelaidePlanningRegion_GDA2020.shp')
#GA_boundary_latlon <- vect(fname)
#GA_boundary_latlon = terra::project(GA_boundary_latlon,crs(SA_boundary_latlon))

#####################################################################

date.start = as.Date(paste0(year,'/',month,'/01'))
days = lubridate::days_in_month(date.start)
#days = 1
date.end = as.Date(paste0(year,'/',month,'/',days))

mins.radar = 5

time.start = as.POSIXct(date.start)
time.end = as.POSIXct(date.end) + 60*(24*60-mins.radar)	
times.all = seq(time.start,time.end,by=paste0(mins.radar,' mins'))

agg = list()
for (aggPeriod in aggPeriod_list){
  agg[[aggPeriod]] = list()
  agg[[aggPeriod]]$times.start = seq(time.start,time.end,aggPeriod)
  agg[[aggPeriod]]$times.end = seq(agg[[aggPeriod]]$times.start[2]-mins.radar*60,time.end,aggPeriod)
  agg[[aggPeriod]]$n_aggs = length(agg[[aggPeriod]]$times.start)
  agg[[aggPeriod]]$times_per_agg = length(times.all)/agg[[aggPeriod]]$n_aggs
}

if (make_plots){pdf(file=paste0(fig.dirname,'radar.pdf'))}

col = colorRampPalette(c("white", "blue", "cyan", "green","yellow","orange","red","brown","black"))(50)

#####################################################################
# read in a single precip raster. this will be used to calculate coordinates.

if ( (radar=='BuckPk') & (prcp=='prcp-c5') ){
  prefix = paste0(data.dirname,'BuckPk/prcp-c5/BuckPk.64.')
  num = 64
} else if ( (radar=='Sellicks') & (prcp=='prcp-c5') ){
  prefix = paste0(data.dirname,'Sellicks/prcp-c5/Sellick.46.')
  num = 46
}

if (prcp=='prcp-c5'){
  prefix.date = paste0(prefix,format(date.start,'%Y%m%d'),'.prcp-c5')
}
tar.date = paste0(prefix.date,'.tar')
dirname.date = paste0(prefix.date,'/')
untar(tarfile=tar.date,exdir=dirname.date)

fname = paste0(dirname.date,'_file_list')
d = read.csv(fname,header=F)
filenames = paste0(dirname.date,d[,1])
fn = filenames[1]
p_raster_xy_base <- rast(fn)

unlink(dirname.date, recursive = TRUE)

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

date.vec = seq(date.start,date.end,by='days')

date.fmt = format(seq(date.start,date.end,by='days'),'%Y%m%d')

P_max_all_vec = P_max_box_vec = rep(NA,length(times.all))
P_sites_mat = matrix(nrow=length(times.all),ncol=dim(coords_latlon)[1])

for (aggPeriod in aggPeriod_list){
#  agg[[aggPeriod]]$P_all_sum = agg[[aggPeriod]]$P_all_count = agg[[aggPeriod]]$t = 0.
  agg[[aggPeriod]]$P_all_count = agg[[aggPeriod]]$t = 0.
  agg[[aggPeriod]]$P_max_all_vec = agg[[aggPeriod]]$P_max_box_vec = 
	  rep(NA,agg[[aggPeriod]]$n_agg)
  agg[[aggPeriod]]$P_sites_mat = matrix(nrow=agg[[aggPeriod]]$n_agg,ncol=dim(coords_latlon)[1])
}

for (t in 1:length(times.all)){

  time. = times.all[t]

  if (as.integer(format(time.,'%H%M'))==0){

    date. = as.Date(time.)   
    print(date.)

    date.fmt = format(date.,'%Y%m%d')

    if (prcp=='prcp-c5'){
      prefix.date = paste0(prefix,date.fmt,'.prcp-c5')
    }
    tar.date = paste0(prefix.date,'.tar')
    dirname.date = paste0(prefix.date,'/')

    if (file.exists(tar.date)){
      untar(tarfile=tar.date,exdir=dirname.date)
    }

  }
  
  fn = paste0(dirname.date,num,'_',date.fmt,'_',format(time.,'%H%M%S'),'.',prcp,'.nc')
    
  if (file.exists(fn)){

    p_raster_xy <- rast(fn)
    
    p_raster_latlon = terra::project(p_raster_xy,crs(SA_boundary_latlon))

    P_all = values(p_raster_latlon)
    P_max_all = max(P_all,na.rm=T)
    P_max_all_vec[t] = P_max_all

    P_sites = terra::extract(x=p_raster_xy,y=coords_xy_vect)$precipitation
    P_sites_mat[t,] = P_sites

#    P_GA = terra::extract(p_raster_latlon,GA_boundary_latlon)$precipitation
#    P_max_GA = max(P_GA,na.rm=T)
#    P_max_GA_vec[t] = P_max_GA

    P_box = crop(p_raster_latlon,extent_box_latlon)
    P_max_box = max(values(P_box),na.rm=T)
    P_max_box_vec[t] = P_max_box

    for (aggPeriod in aggPeriod_list){
#      agg[[aggPeriod]]$P_all_sum = agg[[aggPeriod]]$P_all_sum + P_all
      if (is.null(agg[[aggPeriod]]$p_raster_xy_sum)){
        agg[[aggPeriod]]$p_raster_xy_sum = p_raster_xy
      } else {
        agg[[aggPeriod]]$p_raster_xy_sum = agg[[aggPeriod]]$p_raster_xy_sum + p_raster_xy
      }
      agg[[aggPeriod]]$P_all_count = agg[[aggPeriod]]$P_all_count + 1
    }

    if (make_plots){
  
      plot(p_raster_latlon,range=c(0,2),col=col)
        
      # location of max radar rainfall
      if (P_max_all>0.2){
        i=which(P_all==P_max_all)
        xy = xyFromCell(p_raster_latlon,i)
        points(xy,col='green',cex=5)
      }
  
      # greater Adelaide boundary
      #lines(GA_boundary_latlon,col='red')
        
      # location of max GA radar rainfall
      #if (P_max_GA>0.2){
      #  i=which(P_all==P_max_GA)
      #  xy = xyFromCell(p_raster_latlon,i)
      #  points(xy,col='red',cex=4)
      #}
  
      lines(box_latlon,col='orange')
        
      # location of max box radar rainfall
      if (P_max_box>0.2){
        i=which(P_all==P_max_box)
        xy = xyFromCell(p_raster_latlon,i)
        points(xy,col='orange',cex=4)
      }
        
      # stations
      points(x=sites.lon,y=sites.lat,col='magenta',cex=1,pch=15)
  
      # state boundary
      lines(SA_boundary_latlon)
        
      title(a[[1]][length(a[[1]])])
  
    }
  } else {

    cat(fn,' does not exist\n') 

  }

  #if (as.integer(format(time.,'%H%M'))==2355){
  #  unlink(dirname.date, recursive = TRUE)
  #}

  for (aggPeriod in aggPeriod_list){

    if (time. %in% agg[[aggPeriod]]$times.end){

      agg[[aggPeriod]]$t = agg[[aggPeriod]]$t + 1

      if (agg[[aggPeriod]]$P_all_count > agg_data_thresh*agg[[aggPeriod]]$times_per_agg) {

        p_raster_xy = agg[[aggPeriod]]$p_raster_xy_sum / agg[[aggPeriod]]$P_all_count * agg[[aggPeriod]]$times_per_agg

        p_raster_latlon = terra::project(p_raster_xy,crs(SA_boundary_latlon))

        P_all = values(p_raster_latlon)

#        P_all = agg[[aggPeriod]]$P_all_sum / agg[[aggPeriod]]$P_all_count * agg[[aggPeriod]]$n      
        P_max_all = max(P_all,na.rm=T)
        agg[[aggPeriod]]$max_all_vec[agg[[aggPeriod]]$t] = P_max_all

        P_sites = terra::extract(x=p_raster_xy,y=coords_xy_vect)$precipitation
        agg[[aggPeriod]]$P_sites_mat[agg[[aggPeriod]]$t,] = P_sites

        #P_GA = terra::extract(p_raster_latlon,GA_boundary_latlon)$precipitation
        #P_max_GA = max(P_GA,na.rm=T)
        #agg[[aggPeriod]]$P_max_GA_vec[agg[[aggPeriod]]$t] = P_max_GA

        P_box = crop(p_raster_latlon,extent_box_latlon)
        P_max_box = max(values(P_box),na.rm=T)
        agg[[aggPeriod]]$P_max_box_vec[agg[[aggPeriod]]$t] = P_max_box

      } else {

	agg[[aggPeriod]]$max_all_vec[agg[[aggPeriod]]$t] = NA
        agg[[aggPeriod]]$P_sites_mat[agg[[aggPeriod]]$t,] = NA
        #agg[[aggPeriod]]$P_max_GA_vec[agg[[aggPeriod]]$t] = NA
        agg[[aggPeriod]]$P_max_box_vec[agg[[aggPeriod]]$t] = NA

      }

#      agg[[aggPeriod]]$P_all_sum = agg[[aggPeriod]]$P_all_count = 0
      agg[[aggPeriod]]$P_all_count = 0
      agg[[aggPeriod]]$p_raster_xy_sum = NULL

    }
  }
}

for (aggPeriod in aggPeriod_list){
  agg[[aggPeriod]]$p_raster_xy_sum = agg[[aggPeriod]]$P_all_count = NULL
}

#out = list(P_max_all_vec = P_max_all_vec,
#           P_sites_mat = P_sites_mat,
#           P_max_GA_vec = P_max_GA_vec,
#           P_max_box_vec = P_max_box_vec,
#	   times.all = times.all,
#	   agg)

rm(p_raster_xy, p_raster_latlon, P_all, P_max_all, P_sites, P_box, P_max_box,
   tar.date,fn,fname,p_raster_xy_base,time.,aggPeriod,d,date.,filenames,g,prefix.date,t)

date_str_first = format(times.all[1],'%Y%m%d')
date_str_last = format(times.all[length(times.all)],'%Y%m%d')

fname = paste0(RData.dirname,'out.',radar,'.',date_str_first,'.',date_str_last,'.RData')
save.image(file=fname)

##############

#$#par(mfrow=c(2,1))
#$#
#$#plot(P_sites_mat[,1],type='l')
#$#
#$#load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
#$#i.start=which(out$date == date.start)
#$#i.end=which(out$date == date.end) + 48
#$#keep = i.start:i.end
#$#plot(out$date[keep],out$P[keep],type='l')
#$#
#$###############
#$#
#$#par(mfrow=c(2,1))
#$#
#$#plot(P_sites_mat[,2],type='l')
#$#
#$#load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023090_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
#$#i.start=which(out$date == date.start)
#$#i.end=which(out$date == date.end) + 48
#$#keep = i.start:i.end
#$#plot(out$date[keep],out$P[keep],type='l')
#$#
#$###############
#$#
#$#par(mfrow=c(2,1))
#$#
#$##plot(P_sites_mat[,2],type='l')
#$#plot(P_sites_mat[,3],type='l')
#$#
#$##load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023090_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
#$#load("C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall_orig//RData/AWS_023013_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData")
#$#i.start=which(out$date == date.start)
#$#i.end=which(out$date == date.end) + 48
#$#keep = i.start:i.end
#$#plot(out$date[keep],out$P[keep],type='l')
#$#
#$###############
#$#
#$#
