# Download translation worksheets from CASFRI workbooks
# PV 2019-08-16

library(googlesheets)
library(dplyr)

# Download tables from google docs
cas_gs = "cas_attributes"
for (i in cas_gs) {
    gs = gs_title(i)
    for (ws in gs_ws_ls(gs)) {
        if (ws %in% c("errors_general","errors_specific")) {
            gs_title(i) %>% gs_download(ws=ws, to=paste0("../docs/specifications/errors/cas_",ws,".csv"), overwrite=TRUE)
        } else if (ws %in% c("schema","attributes")) {
            gs_title(i) %>% gs_download(ws=ws, to=paste0("../docs/specifications/attributes/cas_",ws,".csv"), overwrite=TRUE)
        } else {
            gs_title(i) %>% gs_download(ws=ws, to=paste0("tables/",ws,".csv"), overwrite=TRUE)
        }        
    }    
}
#file.copy("tables/schema.csv", "../casfri/docs/specifications/attributes/cas_schema.csv")
