library(plyr)
library(rpostgis)
library(tidyverse)
library(summarytools)

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="1Boreal!")

nb01 = as_tibble(dbGetQuery(con, "SELECT l1cc, l1ht, l1s1, l1pr1, l1estyr, l1trt, l1trtyr FROM rawfri.nb01"))
write_csv(nb01, "data/nb01/rawfri_nb01_in.csv")
sink("data/rawfri_nb01_in.txt"); dfSummary(nb01, graph.col=FALSE, max.distinct.values=99); sink()
nb = nb01 %>%
    mutate(structure_per = -8888, layer=1, layer_rank=1, productive_for = "PF" ) %>%
    mutate(productive_for=if_else((!is.na(l1s1) & (l1s1=="" | l1s1==" ")) & (!is.na(l1cc) | !is.na(l1ht)), "PP", productive_for)) %>%
    mutate(productive_for=if_else(!is.na(l1trt) & l1trt=="CC","PF", productive_for))
write_csv(ab06, "data/nb01/rawfri_nb01_out.csv")
sink("data/rawfri_nb01_out.txt"); print(dfSummary(nb, graph.col=FALSE, max.distinct.values=99)); sink()
