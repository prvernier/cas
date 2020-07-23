library(readxl)
library(tidyverse)

for (sheet in excel_sheets("appendices/cas_appendices.xlsx")) {
    x = read_excel("appendices/cas_appendices.xlsx", sheet=sheet, skip=2)
    write_csv(x, paste0("appendices/",sheet,".csv"))
}