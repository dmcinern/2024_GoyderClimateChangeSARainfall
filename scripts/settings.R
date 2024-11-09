library(lubridate)
library(tidyverse)
library(quantreg)

#dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/'
dirname = 'C:/Users/a1065639/Work/2024_GoyderClimateChangeSARainfall/'

Data_dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/working/'
Code_dirname = paste0(dirname,'scripts/')
#RData_dirname = paste0(dirname,'RData/')
#Fig_dirname = paste0(dirname,'figures/')

RData_dirname = paste0(dirname,'RData/')
Fig_dirname = paste0(dirname,'figures/')

source(paste0(Code_dirname,'load_data.R'))
source(paste0(Code_dirname,'process_data.R'))
source(paste0(Code_dirname,'aggregate_data.R'))
source(paste0(Code_dirname,'annual_metrics.R'))
#source(paste0(Code_dirname,'plotting.R'))
source(paste0(Code_dirname,'load_GMT.R'))
source(paste0(Code_dirname,'plotting_new.R'))
source(paste0(Code_dirname,'seasonality.R'))

source(paste0(Code_dirname,'combine_sites_source.R'))
source(paste0(Code_dirname,'double_mass.R'))
source(paste0(Code_dirname,'instrument_change.R'))
source(paste0(Code_dirname,'remove_data.R'))
source(paste0(Code_dirname,'plot_timeseries_metric_dates.R'))

source(paste0(Code_dirname,'timeseries_functions.R'))

source(paste0(Code_dirname,'calc_cor_metrics.R'))

Site_labels = list()
Site_labels[['023034']] = 'Adelaide airport'
Site_labels[['023090']] = 'Adelaide Kent Town'
Site_labels[['023083']] = 'Edinburgh RAAF'
Site_labels[['023013']] = 'Parafield airport'
Site_labels[['023885']] = 'Noarlunga'
Site_labels[['023842']] = 'Mount Lofty'
Site_labels[['023343']] = 'Rosedale'
Site_labels[['023000']] = 'West Terrace'
Site_labels[['023763']] = 'Mt Crawford (Forest H)'
Site_labels[['023801']] = 'Lenswood'
Site_labels[['024515']] = 'Langhorne Creek'
Site_labels[['023823']] = 'Hindmarsh Valley (Fern)'
Site_labels[['023824']] = 'Hindmarsh Valley (Spring)'
Site_labels[['023878']] = 'Mt Crawford (AWS)'

Site_labels[['026021']] = 'Mount Gambier'
Site_labels[['018012']] = 'Ceduna'
Site_labels[['018116']] = 'Cleve' # Eyre Pen
Site_labels[['021060']] = 'Jamestown' # Mid north
Site_labels[['024515']] = 'Langhorne Creek'
Site_labels[['026049']] = 'Policeman Point' # Coorong
Site_labels[['026082']] = 'Struan' # SE
Site_labels[['016001']] = 'Woomera'
Site_labels[['016032']] = 'Nonning' # Eyre pen


