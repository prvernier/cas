# SK SFV01 Inventories
# PV 2020-06-04

library(rpostgis)
library(summarytools)


# NS03 Inventory
con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
ns = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.ns03")
sink("NS/ns03.txt")
cat("FRI Attributes\n---------------------\n\n")
print(names(sk))
for (i in names(sk)) {
    cat("\n\n", toupper(i),"\n\n", sep="")
    print(dfSummary(sk[[i]], graph.col=FALSE))
}
sink()
dbDisconnect(con)



fri = c('S','SH','HS','H")
cas = c('NOSC SOFT','NOSC SOFT','NOSC HARD','NOSC HARD')

if($Sp eq "S") {
    $Sp1="NOSC SOFT";  $spper1=85;  $Sp2="NOSC HARD"; $spper2=15; $spfreq->{$Sp}++;
}
elsif($Sp eq "SH") {
    $Sp1="NOSC SOFT";  $spper1=60; $Sp2="NOSC HARD";  $spper2=40; $spfreq->{$Sp}++;
}
elsif($Sp eq "HS") {
    $Sp1="NOSC HARD";  $spper1=60; $Sp2="NOSC SOFT";  $spper2=40; $spfreq->{$Sp}++;
}
elsif($Sp eq "H") {
    $Sp1="NOSC HARD";  $spper1=85; $Sp2="NOSC SOFT"; $spper2=15; $spfreq->{$Sp}++;


# Notes
  * two layers (layer 1 + disturbance; NFL)
  * use new codes for "template" line in source attribute table (https://github.com/edwardsmarc/CASFRI/issues/263)