library(readxl)
library(readr)

# Convert lyr.xlsx to individual csv files e.g., bc08_vri01_lyr.csv
for (sheet in excel_sheets("tables/cas_lyr.xlsx")) {
    #if (sheet %in% c("ab06_avi01","ab16_avi01","bc08_vri01")) {
        x = read_excel("tables/cas_lyr.xlsx", sheet=sheet)
        write_csv(x, paste0("../translation/tables/",sheet,"_lyr.csv"))
    #}
}

# Convert cas_attributes.xlsx to individual csv files e.g., a1_current_inventories.csv
#for (sheet in excel_sheets("tables/cas_attributes.xlsx")) {
#    x = read_excel("tables/cas_attributes.xlsx", sheet=sheet, skip=2)
#    write_csv(x, paste0("tables/",sheet,".csv"))
#}
