# Download translation tables from Google spreadsheet
# PV 2019-12-09

library(googlesheets)
library(tidyverse)

# Download inventory tables
ws = "qc4th"
#gs = gs_title("quebec")
#for (ws in gs_ws_ls(gs)) {
    gs_title("quebec") %>% 
        gs_download(ws=ws, to=paste0("tables/",ws,".csv"), overwrite=TRUE)
#}

# Split inventory tables into attribute groups
for (i in c("qc4th")) {
    x = read_csv(paste0("tables/",i,".csv"))
    for (j in c("CAS","LYR","NFL","DST","ECO","GEO")) {
        y = filter(x, group==j) %>% select(-1)
        write_csv(y, paste0("tables/",i,"_",tolower(j),".csv"))
    }
    file.remove(paste0("tables/",i,".csv"))
}
