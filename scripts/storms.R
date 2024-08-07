library(ncdf4)

# fname = 'C:/Users/a1065639/Downloads/46_19931213_grid/46_19931213_062400_grid.nc'
#
# nc1 = nc_open(fname)
#
#
# fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/tmp/BuckPk.64.20190608.prcp-c5/tmp.nc'
#
# nc2 = nc_open(fname)

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/Python_code/MTD-Modified-main/Data/03_20100729_RAINRATE.nc'

nc3 = nc_open(fname)

fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/Python_code/MTD-Modified-main/Output/0_Connected_objects.nc'

nc4 = nc_open(fname)

o=ncvar_get(nc4,'__xarray_dataarray_variable__')

n = dim(o)[2]

storm = c()
set = list()
all = o[,1]
s = 1
set[[s]] = o[,1]
for (i in 2:n){
  all = o[,1:(i-1)]
  if (!((o[1,i]%in%all)|(o[2,i]%in%all))){
    s = s+1
    set[[s]] = o[,i]
  } else {
    set[[s]] = unique(c(set[[s]],o[,i]))
  }
  storm[o[1,i]] = s
  storm[o[2,i]] = s

}


fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/Python_code/MTD-Modified-main/Output/0_Tracked.nc'

nc5 = nc_open(fname)

P = ncvar_get(nc5,'rainrate')

obj = ncvar_get(nc5,'MTD_tracked')
image(P[,,10])

colList = c('red','blue','green','cyan','magenta','brown','yellow','orange','salmon','purple','seagreen')

#for (t im 1:dim(obj)[3]){
for (t in 1:50){
  ss = obj[,,t]
  oo = unique(as.vector(obj[,,t]))
  print(oo)
  for (i in 1:length(oo)){
    ss[ss==oo[i]] = oo[i]
  }
  print(max(ss,na.rm=T))
  if (!all(ss==0)){image[ss]}
}
