common_time_series = function(time.min,time.max,
                              time.1,P.1,
                              time.2,P.2,
                              time.inc){
  
  common.time = seq(time.min,time.max,by=time.inc)
  
  P.1.new = P.2.new = rep(NA,length(common.time))
  
  keep1 = which(time.1%in%common.time)
  keep2 = which(common.time%in%time.1)
  P.1.new[keep2] = P.1[keep1]
  
  keep1 = which(time.2%in%common.time)
  keep2 = which(common.time%in%time.2)
  P.2.new[keep2] = P.2[keep1]
  
  common = which((!is.na(P.1.new))&(!is.na(P.2.new)))
  P.1_P.2_fac = mean(P.1.new[common])/mean(P.2.new[common])
  
  return(list(t=common.time,
              P.1=P.1.new,
              P.2=P.2.new,
              fac=P.1_P.2_fac))
  
}

