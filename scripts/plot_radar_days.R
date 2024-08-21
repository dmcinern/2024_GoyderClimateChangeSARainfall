rm(list=ls())

#radar = 'Sellicks'
radar = 'BuckPk'

make_plots = T
save_data = F

#####################################################################

#date.start = as.Date('2020/04/29')
#date.start = as.Date('2020/01/31')
date.start = as.Date('2023/06/06')

date.end = date.start

source('calc_plot_radar.R')
