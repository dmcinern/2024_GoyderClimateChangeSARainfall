#dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/20240724_BOM_subdaily_rainfall_radar/BuckPk/prcp-c5/'
dirname = '../../../Data/Radar/BuckPk/prcp-c5/'

files = list.files(dirname)

#date_str = strsplit(files[1],"[.]")[[1]][3]
#first.date = as.Date(date_str,format='%Y%m%d')

#date_str = strsplit(files[length(files)],"[.]")[[1]][3]
#last.date = as.Date(date_str,format='%Y%m%d')

first.date = as.Date('2020/01/01')
last.date = as.Date('2020/12/31')

all_dates = seq(first.date,last.date,by='days')

all_dates_str = format(all_dates,'%Y%m%d')

length(all_dates)

length(files)

files_dates_str = c()
for (f in 1:length(files)){
  files_dates_str[f] = strsplit(files[f],"[.]")[[1]][3]
}

all_dates_str[which(!(all_dates_str %in% files_dates_str))]

# output : "20190929" "20200330" "20200331" "20200725" "20200726" "20200727" "20200728"
# note these dates are missing from aus unified radar archive 
