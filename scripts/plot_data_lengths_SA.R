
rm(list=ls())

setwd('C:/Users/a1065639/Box/2024_GoyderClimateChangeSARainfall/3_Tasks/data lengths/')

#d = readxl::read_xlsx('pluvio_SA.xlsx')

d = read.csv('pluvio_SA.csv')
pluvio.sites = as.character(d$Site)
pluvio.site.names = d$Name
pluvio.site.lat = d$Lat
pluvio.site.lon = d$Lon
names(pluvio.site.names) = names(pluvio.site.lat) = names(pluvio.site.lon) = pluvio.sites
  
pluvio = list()
for (s in 1:length(pluvio.sites)){
  site = pluvio.sites[s]
  pluvio[[site]] = list()
  pluvio[[site]]$start = as.integer(format(as.Date(d$Start[s],format='%d/%m/%Y'),'%Y'))
  pluvio[[site]]$end = as.integer(format(as.Date(d$End[s],format='%d/%m/%Y'),'%Y'))
  pluvio[[site]]$years = pluvio[[site]]$start:pluvio[[site]]$end
}

d = read.csv('aws_SA.csv')
aws.sites = as.character(d$Site)

aws.site.names = d$Name
aws.site.lat = d$Lat
aws.site.lon = d$Lon
names(aws.site.names) = names(aws.site.lat) = names(aws.site.lon) = aws.sites

aws = list()
for (s in 1:length(aws.sites)){
  site = aws.sites[s]
  aws[[site]] = list()
  aws[[site]]$start = as.integer(format(as.Date(d$Start[s],format='%d/%m/%Y'),'%Y'))
  aws[[site]]$end = as.integer(format(as.Date(d$End[s],format='%d/%m/%Y'),'%Y'))
  aws[[site]]$years = aws[[site]]$start:aws[[site]]$end
}

all.sites = unique(c(pluvio.sites,aws.sites))

all.site.names = rep(NA,length(all.sites))
names(all.site.names) = all.sites
all.site.names[pluvio.sites] = pluvio.site.names
all.site.names[aws.sites] = aws.site.names

all.site.lat = rep(NA,length(all.sites))
names(all.site.lat) = all.sites
all.site.lat[pluvio.sites] = pluvio.site.lat
all.site.lat[aws.sites] = aws.site.lat

all.site.lon = rep(NA,length(all.sites))
names(all.site.lon) = all.sites
all.site.lon[pluvio.sites] = pluvio.site.lon
all.site.lon[aws.sites] = aws.site.lon

nComboYears = comboYearMax = rep(NA,length(all.sites))
names(nComboYears) = all.sites
year.min = 3000
year.max = 1000
for (s in 1:length(all.sites)){
  site = all.sites[s]
  nComboYears[s] = length(unique(c(pluvio[[site]]$years,aws[[site]]$years)))
  year.min = min(year.min,pluvio[[site]]$start,aws[[site]]$start)
  year.max = max(year.max,pluvio[[site]]$end,aws[[site]]$end)
  comboYearMax[s] = max(pluvio[[site]]$end,aws[[site]]$end)
}

sites.long = all.sites[(nComboYears>30)&(comboYearMax>=2015)]

sites.long = names(sort(nComboYears[sites.long],decreasing = T))

xlim = c(year.min,year.max)
ylim = c(-1,length(sites.long))

par(mfrow=c(1,1),mar=c(2,1,1,10))
plot(x=NULL,y=NULL,xlim=xlim,ylim=ylim,xlab='year',ylab='',yaxt='n')
for (s in 1:length(sites.long)){
  site = sites.long[s]
  
  y.val = s -0.1
  x = pluvio[[site]]$years
  y = rep(y.val,length(pluvio[[site]]$years))
  points(x,y,col='red',pch=15,cex=0.5)

  y.val = s + 0.1
  x = aws[[site]]$years
  y = rep(y.val,length(aws[[site]]$years))
  points(x,y,col='blue',pch=15,cex=0.5)
}

axis(side=4,at=seq(1:length(sites.long)),labels=all.site.names[sites.long],las=2,cex.axis=0.6)
abline(v=2015)     
     

oz::sa()
#oz::sa(ylim=c(-31,-27))
points(all.site.lon[sites.long],all.site.lat[sites.long],cex=0.5,pch=16)
text(x=all.site.lon[sites.long],y=all.site.lat[sites.long],
     labels = all.site.names[sites.long],cex=0.25,pos = 2)

par(mfrow=c(1,1),mar=c(3,3,1,1))
plot(all.site.lon[sites.long],all.site.lat[sites.long],
     cex=0.5,pch=16,type='p',
     xlim=c(138.25,139.25),ylim=c(-35.5,-34.5))
text(x=all.site.lon[sites.long],y=all.site.lat[sites.long],
     labels = all.site.names[sites.long],cex=0.5,pos = 2)

