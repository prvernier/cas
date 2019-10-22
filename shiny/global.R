library(sf)
library(DT)
library(shiny)
library(leaflet)
library(mapview)
library(rpostgis)
library(tidyverse)
library(shinydashboard)

#con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")

mapviewOptions(basemaps=c("Esri.WorldImagery","Esri.NatGeoWorldMap"), layers.control.pos="topright")

# British Columbia
bc08 = st_read(con, query="SELECT * from rawfri.bc08 order by random() limit 100;") %>% mutate(proj_height_1=round(proj_height_1,1), site_index=round(site_index,1))
bc09 = st_read(con, query="SELECT * from rawfri.bc09 order by random() limit 100;") %>% mutate(proj_height_1=round(proj_height_1,1), site_index=round(site_index,1))

# Alberta
ab06 = st_read(con, query="SELECT * from rawfri.ab06 order by random() limit 100;")
ab16 = st_read(con, query="SELECT * from rawfri.ab16 order by random() limit 100;")

# New Brunswick
nb01 = st_read(con, query="SELECT * from rawfri.nb01 order by random() limit 100;")
nb02 = st_read(con, query="SELECT * from rawfri.nb02 order by random() limit 100;")

# Northwest Territories
nt01 = st_read(con, query="SELECT * from rawfri.nt01 order by random() limit 100;")
nt02 = st_read(con, query="SELECT * from rawfri.nt02 order by random() limit 100;")

# Quebec
qc01 = st_read(con, query="SELECT * from rawfri.qc01 order by random() limit 100;")
qc02 = st_read(con, query="SELECT * from rawfri.qc02 order by random() limit 100;")
qc03 = st_read(con, query="SELECT * from rawfri.qc03 order by random() limit 100;")

# Ontario

dbDisconnect(con)
