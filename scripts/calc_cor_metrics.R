##########################

calc_annual_metrics_cor = function(annual_metrics_list,
                                   site_list,
                                   metric_list,
                                   instrument_1,
                                   instrument_2,
                                   aggPeriod_list,
                                   missing_year_thresh,
                                   nonsite_year_thresh){
  
  for (site in site_list){
    for (aggPeriod in aggPeriod_list){
      
        m1 = annual_metrics_list[[site]][[instrument_1]][[aggPeriod]]
        m2 = annual_metrics_list[[site]][[instrument_2]][[aggPeriod]]
  
        if ((!is.null(m1))|(!is.null(m2))){
          
        missing1 = m1$missing
        years1 = m1$year
  
        missing2 = m2$missing
        years2 = m2$year
        
        if (instrument_1%in%c('combo_sources_sites','combo_AWS_sites','combo_pluvio_sites')){
          sources.all = m1$sources.years
          nonsiteFrac.all1 = 1-apply(sources.all[,c('AWS.site','pluvio.site')],1,sum)
        } else {
          nonsiteFrac.all1 = rep(0,length(years))
        }

        if (instrument_2%in%c('combo_sources_sites','combo_AWS_sites','combo_pluvio_sites')){
          sources.all = m2$sources.years
          nonsiteFrac.all2 = 1-apply(sources.all[,c('AWS.site','pluvio.site')],1,sum)
        } else {
          nonsiteFrac.all2 = rep(0,length(years))
        }
        
        yearsBoth = intersect(years1,years2)
        keep1 = years1%in%yearsBoth
        keep2 = years2%in%yearsBoth
        
        missing1_keep = missing1[keep1]
        missing2_keep = missing2[keep2]
        
        nonsiteFrac.all1.keep = nonsiteFrac.all1[keep1]
        nonsiteFrac.all2.keep = nonsiteFrac.all2[keep2]
          
        omit1 = (missing1_keep > missing_year_thresh) | (nonsiteFrac.all1 > nonsite_year_thresh)
        omit2 = (missing2_keep > missing_year_thresh) | (nonsiteFrac.all2 > nonsite_year_thresh)
        
        pchList1 = pchList2 = rep(19,length(yearsBoth))
        pchList1[omit1] = 1
        pchList2[omit2] = 1
        
        for (metric in metric_list){
          
          metrics1 = m1$metrics[,metric]
          metrics2 = m2$metrics[,metric]
          
          metrics1 = metrics1[keep1]
          metrics2 = metrics2[keep2]
          
          metrics1_good = metrics1
          metrics2_good = metrics2
          
          metrics1_good[omit1] = NA
          metrics2_good[omit2] = NA
          
          N = length(which(!is.na(metrics1_good+metrics2_good)))
          
          cor_inst = cor(metrics1_good,metrics2_good,use='pairwise.complete.obs')
          text_str = paste(site,aggPeriod,metric,instrument_1,instrument_2,'cor =',format(cor_inst,digits=2),'N =',N)
          print(text_str)
          
          plot(yearsBoth,metrics1_good,pch=pchList1,col='red',type='o')
          lines(yearsBoth,metrics2_good,pch=pchList2,col='blue',type='o')
          title(text_str,cex.main=0.7)
          
        }
        
      }
      
    }
  }
  
}

