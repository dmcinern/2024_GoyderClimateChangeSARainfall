library(lubridate)
library(tidyverse)
library(quantreg)

dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/R_code/2024_GoyderClimateChangeSARainfall/'

data_dirname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/working/'
code_dirname = paste0(dirname,'scripts/')
RData_dirname = paste0(dirname,'RData/')
fig_dirname = paste0(dirname,'figures/')

source(paste0(code_dirname,'load_data.R'))
source(paste0(code_dirname,'process_data.R'))
source(paste0(code_dirname,'aggregate_data.R'))
source(paste0(code_dirname,'annual_metrics.R'))
source(paste0(code_dirname,'plotting.R'))

site_labels = list()
site_labels[['023034']] = 'Adelaide airport'
site_labels[['023090']] = 'Adelaide Kent Town'
site_labels[['023083']] = 'Edinburgh RAAF'
site_labels[['023013']] = 'Parafield airport'
site_labels[['023885']] = 'Noarlunga'
site_labels[['023842']] = 'Mount Lofty'
site_labels[['023343']] = 'Rosedale'
site_labels[['023000']] = 'West Terrace'
site_labels[['023763']] = 'Mt Crawford (Forest H)'
site_labels[['023801']] = 'Lenswood'
site_labels[['024515']] = 'Langhorne Creek'
site_labels[['023823']] = 'Hindmarsh Valley'
site_labels[['023878']] = 'Mt Crawford (AWS)'

