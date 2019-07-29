# Assemble CAS_04 tables
library(tidyverse)

folder = "C:/Users/PIVER37/Documents/casfri/data/CAS_04/TranslatedCASFiles/Version.00.04/TranslatedFiles/BC/"

j = 1
for (i in list.dirs(folder, full.names=FALSE)) {
    print(i)
    if (j==2) {
        hdr = read_csv(paste0(folder,i,"/",i,".hdr"))
        cas = read_csv(paste0(folder,i,"/",i,".cas"))
        lyr = read_csv(paste0(folder,i,"/",i,".lyr"))
        nfl = read_csv(paste0(folder,i,"/",i,".nfl"))
        dst = read_csv(paste0(folder,i,"/",i,".dst"))
        eco = read_csv(paste0(folder,i,"/",i,".eco"))
    } else if (j>2) {
        hdr2 = read_csv(paste0(folder,i,"/",i,".hdr"))
        cas2 = read_csv(paste0(folder,i,"/",i,".cas"))
        lyr2 = read_csv(paste0(folder,i,"/",i,".lyr"))
        nfl2 = read_csv(paste0(folder,i,"/",i,".nfl"))
        dst2 = read_csv(paste0(folder,i,"/",i,".dst"))
        eco2 = read_csv(paste0(folder,i,"/",i,".eco"))
        hdr = bind_rows(hdr, hdr2)
        cas = bind_rows(cas, cas2)
        lyr = bind_rows(lyr, lyr2)
        nfl = bind_rows(nfl, nfl2)
        dst = bind_rows(dst, dst2)
        eco = bind_rows(eco, eco2)
    }
    j = j + 1
}

write_csv(hdr, "data/BC_0004/BC_0004.hdr")
write_csv(cas, "data/BC_0004/BC_0004.cas")
write_csv(lyr, "data/BC_0004/BC_0004.lyr")
write_csv(nfl, "data/BC_0004/BC_0004.nfl")
write_csv(dst, "data/BC_0004/BC_0004.dst")
write_csv(eco, "data/BC_0004/BC_0004.eco")

