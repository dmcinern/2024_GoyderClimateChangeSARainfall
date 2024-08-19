rm(list=ls())

aggPeriod = '30 mins'

load('../RData/Radar/out_merge.BuckPk.2020.2023.RData')

P_agg_BuckPk = out_merge$agg[[aggPeriod]]$P_sites_mat[,1]
times_agg_BuckPk = out_merge$agg[[aggPeriod]]$times.start

load('../RData/Radar/out_merge.Sellicks.2020.2023.RData')

P_agg_Sellicks = out_merge$agg[[aggPeriod]]$P_sites_mat[,1]
times_agg_Sellicks = out_merge$agg[[aggPeriod]]$times.start


load('../RData/AWS_023034_accumHandling.spread_processed.RData_aggPeriod.30mins_aggDataThresh.0.8_agg.RData')

P_agg_AWS = out$P
times_agg_AWS = out$date

i.start = which(times_agg_AWS==times_agg_BuckPk[1])
i.end = which(times_agg_AWS==times_agg_BuckPk[length(times_agg_BuckPk)])

P_agg_AWS_sel = P_agg_AWS[i.start:i.end]

print(mean(P_agg_AWS_sel,na.rm=T))
print(mean(P_agg_BuckPk,na.rm=T))
print(mean(P_agg_Sellicks,na.rm=T))

