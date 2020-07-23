library(plyr)
library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

#ab06 = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.ab06"))
#sink(paste0("data/ab06/rawfri_ab06.txt")); dfSummary(ab06, graph.col=FALSE, max.distinct.values=20); sink()

ab06 = as_tibble(dbGetQuery(con, "SELECT moist_reg, density, height, sp1, sp1_per, struc_val, tpr, mod1, origin, nfl, nat_non, anth_veg, anth_non FROM rawfri.ab06"))
#sink("data/ab06/rawfri_ab06_in.txt"); print(dfSummary(ab06, graph.col=FALSE, max.distinct.values=99)); sink()
ab = ab06 %>%
    mutate(soil_moist_reg=if_else(moist_reg==" ", "NULL_VALUE", mapvalues(moist_reg, c('a','A','d','D','m','M','w','W'), c('A','A','D','D','F','F','W','W')))) %>%
    mutate(structure_per=if_else(struc_val==0, -9999, as.double(struc_val))) %>%
    mutate(layer=1) %>%
    mutate(layer_rank=1) %>%
    mutate(crown_closure_upper=if_else(density==" ", -9998, as.double(mapvalues(density, c('A','B','C','D'),c(30,50,70,100))))) %>%
    mutate(crown_closure_lower=if_else(density==" ", -9998, as.double(mapvalues(density, c('A','B','C','D'),c(6,31,51,71))))) %>%
    mutate(height_upper=if_else(height<1 | height>100, -9999, as.double(height))) %>%
    mutate(height_lower=if_else(height<1 | height>100, -9999, as.double(height))) %>%
    mutate(species_1=if_else(sp1==" ", "EMPTY_STRING", sp1)) %>%
    mutate(species_per_1=sp1_per) %>%
    #mutate(productive_for=if_else(mod1!="CC" & sp1==" " & (density %in% c("A","B","C","D") | (height>0 & height<=100)), "PP", "PF")) %>%
    mutate(productive_for=if_else(mod1!="CC" & species_1=="EMPTY_STRING" & (crown_closure_upper!=-9998 | height_upper!=-9999), "PP", "PF")) %>%
    mutate(origin_upper=if_else(origin==0,-9999,as.double(origin))) %>%
    mutate(origin_lower=if_else(origin==0,-9999,as.double(origin))) %>%
    mutate(site_class=if_else(tpr==" ","NULL_VALUE", if_else(!tpr==" " & !tpr %in% c('U','F','M','G'), "NOT_IN_SET", mapvalues(tpr, c('U','F','M','G'), c('U','P','M','G'))))) %>%
    mutate(site_index=-8887)
    
    # NAT_NON_FOR
    friList = c('NWL','NWF','NMB')
    casList = c('LA','FL','EX')
    ab = mutate(ab, nat_non_veg=if_else(nat_non==" ","NULL_VALUE", if_else(!nat_non==" " & !nat_non %in% friList, "NOT_IN_SET", mapvalues(nat_non, friList, casList))))


    #mutate(moist_reg=NULL, density=NULL, height=NULL, sp1=NULL, sp1_per=NULL, struc_val=NULL, tpr=NULL, mod1=NULL, origin=NULL)

#knitr::kable(ab)
#write_csv(ab06, "data/ab06/rawfri_ab06_out.csv")
#sink("data/ab06/rawfri_ab06_out.txt"); print(dfSummary(ab, graph.col=FALSE, max.distinct.values=99)); sink()
