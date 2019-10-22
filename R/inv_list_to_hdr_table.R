# Convert inventory_list_cas05.csv to HDR tables
# PV 2019-08-07

library(tidyverse)

hdr_cols = c("header_id","jurisdiction","owner_type","owner_name","inventory_type","inventory_version","inventory_manual","source_data_format","acquisition_date","data_transfer","received_from","contact_info","data_availability","redistribution","permission","license_agreement","source_data_photoyear","photoyear_start","photoyear_end")

inv_list = read_csv("../../casfri/docs/inventory_list_cas05.csv")
