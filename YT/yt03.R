# YT03 Inventory
# PV 2021-02-18

library(rpostgis)
library(summarytools)
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
x = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.yt03")
sink("YT/yt03.otl")
cat("= V7 Outline MultiLine NoSorting TabWidth=30\n\n")
print(names(x))
for (i in names(x)) {
    cat("\nH=", i,"\n", sep="")
    flush.console()
    print(dfSummary(x[[i]], graph.col=FALSE, max.distinct.values = 20))
}
sink()
dbDisconnect(con)

################################################################################

# NAT_NON_VEG
"notNull(water,exposed_land,snow_ice);notEmpty(water,exposed_land,snow_ice);matchList(water,exposed_land,snow_ice, {'NW','NS','NE'});yvi01_nat_non_veg_validation(type_lnd, class, landpos)",
"mapText(water,exposed_land,snow_ice,{})",
"Checks type_lnd is not empty and is in 'NW','NS','NE'. Then checks either landpos is 'A', or class is in 'R','L','RS','E','S','B','RR'. Translation converts landpos A to ALPINE, and 'R','L','RS','E','S','B','RR' to 'RIVER','LAKE','WATER_SEDIMENT','EXPOSED_LAND','SAND','EXPOSED_LAND','ROCK_RUBBLE'."

# NON_FOR_ANTH
"notNull(anthropogenic);notEmpty(anthropogenic);matchList(anthropogenic, {'Airport', 'Anthropogenic Other', 'Cultivated', 'Generic Clearing', 'Gravel Pit' ,'Industrial Corridor' ,'Industrial Site' ,'Mine Site' ,'Mine Tailings' ,'Railway' ,'Road' ,'Rural Residential' ,'Seismic' ,'Tower Site' ,'Urban/Settlement'})",
"mapText(class, {'Airport', 'Anthropogenic Other', 'Cultivated', 'Generic Clearing', 'Gravel Pit' ,'Industrial Corridor' ,'Industrial Site' ,'Mine Site' ,'Mine Tailings' ,'Railway' ,'Road' ,'Rural Residential' ,'Seismic' ,'Tower Site' ,'Urban/Settlement'}, {'AIRPORT', 'ANTHROPOGENIC OTHER', 'CULTIVATED', 'GENERIC CLEARING', 'GRAVEL PIT' ,'INDUSTRIAL CORRIDOR' ,'INDUSTRIAL SITE' ,'MINE SITE' ,'MINE TAILINGS' ,'RAILWAY' ,'ROAD' ,'RURAL RESIDENTIAL' ,'SEISMIC' ,'TOWER SITE' ,'URBAN/SETTLEMENT'})",
"Checks anthropogenic is not empty. Checks anthropogenic values. Translates anthropogenic."

# NON_FOR_VEG
"notNull(shrub_type,non_shrub_type);notEmpty(shrub_type,non_shrub_type);matchList(shrub_type,non_shrub_type, {'S','H','C','M'})",
"mapText(type_lnd, class, cl_mod,{})",
"Checks type_lnd is not empty. Checks type_lnd is VN, and class is S, H, C or M. Converts cl_mod of TS, TSo, TSc, LS to TALL_SHRUB, TALL_SHRUB, TALL_SHRUB, LOW_SHRUB. And classes of C, H and M to BRYOID, HERBS and HERBS.",TRUE
