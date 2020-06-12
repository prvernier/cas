# SK SFV01 Inventories
# PV 2020-06-12

library(rpostgis)
library(summarytools)


# Read inventory
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


# General Notes

  * two layers (layer 1 + disturbance; NFL)


# Site class

The CAS attribute SITE_CLASS requires two source attributes (site_sw and site_hw), but since they use the same codes we can't concatenate them:

SITE_CLASS: mapText({site_sw}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13}, {'P','P','P','P','P','M','M','M','M','M','G','G','G','G'})
SITE_CLASS: mapText({site_hw}, {0,1,2,3,4,5}, {'P','P','M','M','G','G'})


# Secondary species

There can be two layer2 species and species_per created from one source attribute (ss_species):

SPECIES_1: mapText({sp1}, {'S','SH','HS','H'}, {'Soft unkn','Soft unkn','Hard unkn','Hard unkn'})
SPECIES_PER_1: mapText({ss_species}, {'S','SH','HS','H'}, {'85','60','40','15'})
SPECIES_2: mapText({ss_species}, {'S','SH','HS','H'}, {'Hard unkn','Hard unkn','Soft unkn','Soft unkn'})
SPECIES_PER_2: mapText({ss_species}, {'S','SH','HS','H'}, {'15','40','60','85'})

Original Perl code:

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


