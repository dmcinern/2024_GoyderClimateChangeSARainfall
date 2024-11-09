#Year.min.manual = Year.max.manual = list()
# Year.min.manual[['023090']]=list(AWS=2003) # unrealistically large 30 min rainfall on 14/1/2002 - now below
# Year.max.manual[['023885']]=list(AWS=2022) # unrealistically large 30 min rainfall on 3/7/2023
# 
# Year.max.manual[['023824']]=list(pluvio=2015) # unrealistically large rain in May 2016

Period.remove = list()
Period.remove[['023034']] = list()
# remove single date where unrealistic large accumulation has occurred
Period.remove[['023034']]$AWS = list(start = as.POSIXct('2009-07-21 12:32:00',tz = 'UTC'),
                                     end = as.POSIXct('2009-07-21 12:32:00',tz = 'UTC'))


Period.remove[['023034']]$pluvio = list(start = c(as.POSIXct('1993-06-01 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2001-06-01 00:00:00',tz = 'UTC')),
                                     end = c(as.POSIXct('1993-07-31 23:54:00',tz = 'UTC'),
                                             as.POSIXct('2001-06-30 23:54:00',tz = 'UTC')))


Period.remove[['023090']] = list()
Period.remove[['023090']]$AWS = list(start = as.POSIXct('2002-01-14 14:00:00',tz = 'UTC'),
                                     end = as.POSIXct('2002-01-14 15:00:00',tz = 'UTC'))
Period.remove[['023090']]$pluvio = list(start = c(as.POSIXct('1996-08-01 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2003-05-01 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2013-06-01 00:00:00',tz = 'UTC')),
                                        end = c(as.POSIXct('1996-09-30 23:54:00',tz = 'UTC'),
                                                as.POSIXct('2003-08-31 23:54:00',tz = 'UTC'),
                                                as.POSIXct('2013-07-31 23:54:00',tz = 'UTC')))


Period.remove[['023013']] = list()
Period.remove[['023013']]$pluvio = list(start = c(as.POSIXct('2000-05-01 00:00:00',tz = 'UTC')),
                                        end = c(as.POSIXct('2000-08-31 23:54:00',tz = 'UTC')))

Period.remove[['023823']] = list()
Period.remove[['023823']]$pluvio = list(start = c(as.POSIXct('1978-05-01 00:00:00',tz = 'UTC')), # unrealistically large event
                                        end = c(as.POSIXct('1978-05-31 23:54:00',tz = 'UTC')))

Period.remove[['023824']] = list()
Period.remove[['023824']]$pluvio = list(start = c(as.POSIXct('1993-08-01 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2003-07-01 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2014-04-01 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2016-05-11 00:00:00',tz = 'UTC'),
                                                  as.POSIXct('2016-05-01 00:00:00',tz = 'UTC')), # large event
                                        end = c(as.POSIXct('1993-08-31 23:54:00',tz = 'UTC'),
                                                as.POSIXct('2003-08-31 23:54:00',tz = 'UTC'),
                                                as.POSIXct('2014-06-30 23:54:00',tz = 'UTC'),
                                                as.POSIXct('2016-05-11 23:54:00',tz = 'UTC'),
                                                as.POSIXct('2016-05-31 23:54:00',tz = 'UTC')))
