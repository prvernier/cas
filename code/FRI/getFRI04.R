# Read CAS_04 exported csv files and save selected attributes
# PV 2019-01-22

library(tidyverse)
baseDir = "C:/Users/beacons/Documents/CASFRI/CAS_04/ExportedSourceFiles/Version.00.04/ExportedFiles/"

# ab_0006
ab6 = read_delim(paste0(baseDir,"AB/AB_CROWNFMA/csv/AB_0006-GB_S21_TWP.csv"), delim=";") %>%
    select(DENSITY,HEIGHT,SP1,SP1_PER,SP2,SP2_PER,SP3,SP3_PER,SP4,SP4_PER,SP5,SP5_PER)
write_csv(ab6, "fri/ab_0006/cas_04/fri.csv")

# ab_0016
x=list.files(paste0(baseDir,"AB/AB_0016-CANFOR/csv"), pattern=".csv")
y=list.files(paste0(baseDir,"AB/AB_0016-CANFOR/csv"), pattern="photo.csv")
z=x[!x %in% y]
ab16 = read_delim(paste0(paste0(baseDir,"AB/AB_0016-CANFOR/csv/",z[1])), delim=";") %>%
    select(DENSITY,HEIGHT,SP1,SP1_PER,SP2,SP2_PER,SP3,SP3_PER,SP4,SP4_PER,SP5,SP5_PER)
i=1
for (f in z[-1]) {
    print(i); flush.console()
    f1 = read_delim(paste0(paste0(baseDir,"AB/AB_0016-CANFOR/csv/",f)), delim=";") %>%
        select(DENSITY,HEIGHT,SP1,SP1_PER,SP2,SP2_PER,SP3,SP3_PER,SP4,SP4_PER,SP5,SP5_PER)
    ab16=bind_rows(ab16,f1)
    #ab16=rbind(ab16,f1)
    i=i+1
}
write_csv(ab16, "fri/ab_0016/cas_04/fri.csv")

# bc_0008
z=list.files(paste0(baseDir,"BC/GOV/csv"), pattern=".csv")
bc8 = read_delim(paste0(paste0(baseDir,"BC/GOV/csv/",z[1])), delim=";") %>%
    select(INVENTORY_STANDARD_CD,CROWN_CLOSURE,CROWN_CLOSURE_CLASS_CD,SPECIES_CD_1,SPECIES_PCT_1,SPECIES_CD_2,SPECIES_PCT_2,SPECIES_CD_3,SPECIES_PCT_3,SPECIES_CD_4,SPECIES_PCT_4,SPECIES_CD_5,SPECIES_PCT_5,SPECIES_CD_6,SPECIES_PCT_6,PROJ_HEIGHT_1,PROJ_HEIGHT_CLASS_CD_1)
i=1
for (f in z[-1]) {
    print(i); flush.console()
    f1 = read_delim(paste0(paste0(baseDir,"BC/GOV/csv/",f)), delim=";") %>%
        select(INVENTORY_STANDARD_CD,CROWN_CLOSURE,CROWN_CLOSURE_CLASS_CD,SPECIES_CD_1,SPECIES_PCT_1,SPECIES_CD_2,SPECIES_PCT_2,SPECIES_CD_3,SPECIES_PCT_3,SPECIES_CD_4,SPECIES_PCT_4,SPECIES_CD_5,SPECIES_PCT_5,SPECIES_CD_6,SPECIES_PCT_6,PROJ_HEIGHT_1,PROJ_HEIGHT_CLASS_CD_1)
    bc8=bind_rows(bc8,f1)
    #ab16=rbind(ab16,f1)
    i=i+1
}
write_csv(bc8, "fri/bc_0008/cas_04/fri.csv")

# bc_0008 (TFL 48)
bc8 = read_csv(paste0(baseDir,"BC/tfl48/csv/BC_0007.csv")) %>%
    select(CROWN_CLOS,CROWN_CL_1,SPECIES_CD,SPECIES_PC,SPECIES__1,SPECIES__2,SPECIES__3,SPECIES__4,SPECIES__5,SPECIES__6,SPECIES__7,SPECIES__8,SPECIES__9,SPECIES_10,PROJ_HEIGH,PROJ_HEI_1,PROJ_HEI_2,PROJ_HEI_3)
write_csv(bc8, "fri/bc_0008/cas_04/fri_tfl48.csv")

# nb_0001
nb1 = read_delim(paste0(baseDir,"NB/csv/NB_0001.csv"), delim=";") %>%
    select(L1S1,L1PR1,L1S2,L1PR2,L1S3,L1PR3,L1S4,L1PR4,L1S5,L1PR5,L1HT,L1CC)
write_csv(nb1, "fri/nb_0001/cas_04/fri.csv")

