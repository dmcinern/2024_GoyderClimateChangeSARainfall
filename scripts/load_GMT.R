fname = 'C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/8_Data_External/GMT.txt'
d = read.table(fname,skip=5)
GMT.year = d$V1
#GMT.anom = d$V2
GMT.anom = d$V3
