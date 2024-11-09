######################################################}

plot_double_mass = function(p1,date1,p2,date2,
                            year.min=NULL,year.max=NULL,
                            xlab,ylab,instrumentChange=NULL,
                            blend_year_change=NULL,
                            source_change=NULL){
  
  if (is.null(year.min)){year.min=-99999}
  if (is.null(year.max)){year.max=99999}
  
  year1 = as.integer(format(date1,'%Y'))
  year2 = as.integer(format(date2,'%Y'))
  
  year.min = max(year.min,min(year1),min(year2))
  year.max = min(year.max,max(year1),max(year2))
  
  print(year.min)
  print(year.max)
  
  keep1 = which((year1>=year.min)&(year1<=year.max))
  p1 = p1[keep1]
  date_keep = date1[keep1]
  
  keep2 = which((year2>=year.min)&(year2<=year.max))
  p2 = p2[keep2]
  
  Jan1 = which((format(date_keep,'%d/%m')=='01/01')&((as.integer(format(date_keep,'%Y'))%%5)==0))
  Lab = as.integer(format(date_keep,'%Y'))[Jan1]
  
  i_instrumentChange = which(format(date_keep,'%Y/%m')%in%format(instrumentChange$dates,'%Y/%m'))
  
  i_blend_year_change = c()
  if(!is.null(blend_year_change)){
    print(blend_year_change)
    if (!is.na(blend_year_change)){
      i_blend_year_change = min(which(as.integer(format(date_keep,'%Y'))==blend_year_change))
    }
  }

  i_source_change = c()
  if(!is.null(source_change)){
    print(source_change)
    if (!is.na(source_change)){
      i_source_change = min(which(date_keep==source_change))
    }
  }
  
  
  # P1[is.na(P1)] = P2[is.na(P1)]
  # P2[is.na(P2)] = P1[is.na(P2)]
  #
  # P1[is.na(P1)] = P2[is.na(P2)] = 0.
  
  p2[is.na(p1)] = NA
  p1[is.na(p2)] = NA
  p_missing = length(which(is.na(p1)))/length(p1)
  
  p1[is.na(p1)] = 0
  p2[is.na(p2)] = 0
  
  cum1 = cumsum(p1)
  cum2 = cumsum(p2)

  plot(x=c(0,max(cum1)),y=c(0,max(cum2)),col='red',type='l',xlab=xlab,ylab=ylab)
  #lmfit = lm(cum2~cum1)
  #a = lmfit$coefficients[1]; b=lmfit$coefficients[2]
  #x = c(0,max(cum1))
  #y = a + b*x
  #plot(x=x,y=y,col='red',type='l',xlab=xlab,ylab=ylab)
  lines(cum1,cum2,type='l')
  if (length(Jan1)>0){
    points(cum1[Jan1],cum2[Jan1],col='black',cex=0.6)
    text(x=cum1[Jan1],y=cum2[Jan1],labels=Lab,cex=0.6,pos=4)
    points(x=cum1[i_instrumentChange],y=cum2[i_instrumentChange],col='blue',pch=15)
    if(!is.null(blend_year_change)){
      if (!is.na(blend_year_change)){
        points(x=cum1[i_blend_year_change],y=cum2[i_blend_year_change],col='green',pch=19)
      }
    }
    if(!is.null(source_change)){
      if (!is.na(source_change)){
        points(x=cum1[i_source_change],y=cum2[i_source_change],col='green',pch=19)
      }
    }
  }
  legend('bottomright',c('observed','linear','change instrument','change source (pluvio->AWS'),
         col=c('black','red','blue','green'),
         pch=c(NA,NA,15,19),
         lty=c(1,1,NA,NA))
  
  title(paste0('Cummulative rain. ',year.min,'-',year.max, '. ', format(p_missing*100,digits=2),'% missing'))
  
}

######################################################}
