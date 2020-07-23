library(plyr)
library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

#ab16 = as_tibble(dbGetQuery(con, "SELECT * FROM rawfri.ab16"))
#sink(paste0("data/ab16/rawfri_ab16.txt"))
#dfSummary(ab16, graph.col=FALSE, max.distinct.values=20)
#sink()

ab16 = as_tibble(dbGetQuery(con, "SELECT moisture, crownclose, height, sp1, sp1_percnt, std_struct, tpr, modcon1, origin FROM rawfri.ab16"))
write_csv(ab06, "data/ab16/rawfri_ab16_in.csv")
sink("data/rawfri_ab16_in.txt"); dfSummary(ab16, graph.col=FALSE, max.distinct.values=99); sink()
ab = ab16 %>%
    mutate(soil_moist_reg=if_else(moisture==" ", "NULL_VALUE", mapvalues(moisture, c('a','A','d','D','m','M','w','W'), c('A','A','D','D','F','F','W','W')))) %>%
    mutate(structure_per=if_else(std_struct %in% c("C4","C5"), as.integer(substr(std_struct,2,2)), as.integer(-9999))) %>%
    mutate(layer=1) %>%
    mutate(layer_rank=1) %>%
    mutate(crown_closure_upper=if_else(crownclose=="", -9998, as.double(mapvalues(crownclose, c('A','B','C','D'),c(30,50,70,100))))) %>%
    mutate(crown_closure_lower=if_else(crownclose=="", -9998, as.double(mapvalues(crownclose, c('A','B','C','D'),c(6,31,51,71))))) %>%
    mutate(height_upper=if_else(height<1 | height>100, -9999, as.double(height))) %>%
    mutate(height_lower=if_else(height<1 | height>100, -9999, as.double(height))) %>%
    mutate(species_1=if_else(sp1=="", "EMPTY_STRING", sp1)) %>%
    mutate(species_per_1=sp1_percnt) %>%
    #mutate(productive_for=if_else(modcon1!="CC" & sp1==" " & (crownclose %in% c("A","B","C","D") | (height>0 & height<=100)), "PP", "PF")) %>%
    mutate(productive_for=if_else(modcon1!="CC" & species_1=="EMPTY_STRING" & (crown_closure_upper!=-9998 | height_upper!=-9999), "PP", "PF")) %>%
    mutate(origin_upper=if_else(origin==0,-9999,as.double(origin))) %>%
    mutate(origin_lower=if_else(origin==0,-9999,as.double(origin))) %>%
    mutate(site_class=if_else(tpr==" ","NULL_VALUE", if_else(!tpr==" " & !tpr %in% c('U','F','M','G'), "NOT_IN_SET", mapvalues(tpr, c('U','F','M','G'), c('U','P','M','G'))))) %>%
    mutate(site_index=-8887) %>%
    mutate(moisture=NULL, crownclose=NULL, height=NULL, sp1=NULL, sp1_percnt=NULL, std_struct=NULL, tpr=NULL, modcon1=NULL, origin=NULL)
write_csv(ab06, "data/ab16/rawfri_ab16_out.csv")
sink("data/rawfri_ab16_out.txt"); print(dfSummary(ab, graph.col=FALSE, max.distinct.values=99)); sink()
