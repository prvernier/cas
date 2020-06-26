# SK SFV01 Inventories
# PV 2020-06-12

library(rpostgis)
library(summarytools)


# Read inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
pe = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.pe01")
sink("PEI/pe01.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(pe))
for (i in names(pe)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(pe[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)

LRY Attributes

crown_closure_upper
fri('J','I','H','G','F','E','D','C','B','A'}
cas(10,20,30,40,50,60,70,80,90,100)

crown_closure_lower
fri('J','I','H','G','F','E','D','C','B','A'}
cas(1,11,21,31,41,51,61,71,81,91)

# NFL Attributes

nat_non_veg
fri = {'SO','SD','WW','FL'}
cas = {'SL','SA','LA','FL'}

non_for_anth
fri = {'CL','WF','PL','RN','RD','RR','AG','EP','UR'}
cas = {'OT','OT','FA','FA','FA','FA','CL','BP','SE'}

non_for_veg
fri = {'AL','BO'}
cas = {'ST','OM'}

Land Type codes
---------------
- AG agricultural land including farm buildings
- AL alders
- BO bog
? BR burned land
? CC clearcuts
- CL cleared land, land cleared of trees but not in agricultural use
- EP excavation pit
- FL flooded land
? HH >75% hardwood species
? HS 50-75% hardwood species
- PL power line electrical transmission corridor
? PN forest plantation
- RD road from 1985/88 base mapping
- RN land used for recreation, i.e. campground or golf course
- RR railway right of way from 1985/88 base mapping
- SD sand dune
? SH 50-75% softwood species
- SO swamp
? SS >75% softwood species
- UR urban area
- WF area where trees have been blown down and species not identifyable
- WW water


DST Attributes

dist_type_1
fri = {'BR','CC','WF','FL','DI','EP','OF','HR','RN','SD','SY','UR','SW','E', 'PN','TH','RC','PC','ST'}
cas = {'BU','CO','WF','FL','DI','OT','OT','OT','OT','OT','OT','OT','OT','PN','SI','SI','PC','PC','PC'}

Origin/History (combinations of codes occur)
--------------------------------------------
BR burn, polygon orginated from a burn
CC clearcut, polygon orginated from a clearcut
DI disease or insect damage noted
EP excavation pit, forest grew in an excavation pit
FL flooded land, site is flooded
HR hedgerow, forest polygon is a hedgerow
OF old field, forest has regenerated on former agriculture land
PC partial cut, forest polygon has been partially harvested
PN plantation, polygon orginated from planting
RN recreation, forest polygon is used for recreation
SD sand dune, forest id growing on a sand dune
ST steep, site is steep land
SY sandy, forest polygon is growing on a sandy site
TH thinned, forest stand has been thinned
SW swamp, site is wet
UR urban, forest polygon in an urban area
WF wind fall, forest stand has had some wind blow