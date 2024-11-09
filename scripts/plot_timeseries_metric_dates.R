plot_timeseries_metrics_dates = function(site_list,
                                         plot.aggPeriod_list,
                                         metric_list,
                                         instrument,
                                         annual_metrics_list,
                                         agg_data_list,
                                         processed_data_list,
                                         nearbySite_list){

  for (s in 1:length(site_list)){
    site = site_list[s]
    
    for (aggPeriod in plot.aggPeriod_list){
      
      for (metric in metric_list){
        
        dates_plot = annual_metrics_list[[site]][[instrument]][[aggPeriod]]$metrics.dates[,metric]
        
        for (y in 1:length(dates_plot)){
          
          if (!is.na(dates_plot[y])){
            
            date_plot = as.POSIXct(dates_plot[y],origin= "1970-01-01",tz = 'UTC')
            
            a = agg_data_list[[site]][[instrument]][[aggPeriod]]
            date_agg = a$date
            i_agg = which(date_agg==date_plot)
            dt_agg = date_agg[(i_agg+1)] - date_agg[i_agg]
            
            if (instrument=='combo_sources_sites'){
              
              source = a$source[i_agg]
              
              if (source=='pluvio.site'){
                intrument.plot = 'pluvio'
                site.plot = site
              } else if (source=='pluvio.nearbySite'){
                intrument.plot = 'pluvio'
                site.plot = nearbySite_list[[site]]
              } else if (source=='AWS.site'){
                intrument.plot = 'AWS'
                site.plot = site
              } else if (source=='AWS.nearbySite'){
                intrument.plot = 'AWS'
                site.plot = nearbySite_list[[site]]
              }
              
            } else {
              
              source = NULL
              intrument.plot = instrument
              site.plot = site
              
            }
            
            p = processed_data_list[[site.plot]][[intrument.plot]]
            date_processed = p$date
            i_processed = which(date_processed==date_plot)
            
            date_min = date_processed[i_processed] - dt_agg
            date_max = date_processed[i_processed] + 2*dt_agg
            
            i_min = which(date_processed==date_min)
            i_max = which(date_processed==date_max)
            
            dt_proc = date_processed[(i_min+1)] - date_processed[i_min]
            
            P_period = p$P[i_min:i_max]
            
            col = rep('black',length(i_min:i_max))
            
            col[p$accPeriod[i_min:i_max]>1] = 'red'
            
            plot(date_processed[i_min:i_max],P_period,type='p',xlab='time',ylab='rain (mm)',col=col)
            lines(date_processed[i_min:i_max],P_period,type='l')
            # barplot(P_period,)
            #axis(side=1,at=c(i_min,i_processed,i_max),labels = c(date_min,date_plot,date_max))
            
            # if (any(col=='red')){browser()}
            
            abline(v=(date_agg[i_agg]-dt_proc/2),lty=2)
            abline(v=(date_agg[(i_agg+1)]-dt_proc/2),lty=2)
            
            title(paste0(site,', ',date_plot,', ',aggPeriod,', ',metric,', ',source),cex.main=0.7)
            
          }
        }
      }
      
    }
    
  }
  
}