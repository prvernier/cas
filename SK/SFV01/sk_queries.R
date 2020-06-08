# Return all possible combinations of nvsl, aquatic_class, luc, transp_class

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="casfri50_pierrev", host="localhost", port=5432, user="postgres", password="1postgres")
sk2 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk02")
sk3 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk03")
sk4 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk04")
sk5 = RPostgreSQL::dbGetQuery(con, "SELECT * FROM rawfri.sk05")
dbDisconnect(con)

nfl2 = as_tibble(sk2) %>% select(nvsl, aquatic_class, luc, transp_class, shrub1, herbs1)
nfl3 = as_tibble(sk3) %>% select(nvsl, aquatic_class, luc, transp_class, shrub1, herbs1)
nfl4 = as_tibble(sk4) %>% select(nvsl, aquatic_class, luc, transp_class, shrub1, herb1) %>%
    mutate(herbs1 = herb1, herb1=NULL)
nfl5 = as_tibble(sk5) %>% select(nvsl, aquatic_class, luc, transp_class, shrub1, herbs1)

nfl = bind_rows(nfl2, nfl3, nfl4, nfl5) %>% 
    mutate(nat_non_veg = paste0(nvsl, aquatic_class),
        non_for_anth = paste0(luc, transp_class),
        non_for_veg = paste0(shrub1, herbs1))

table(nfl$nat_non_veg)
table(nfl$non_for_anth)
table(nfl$non_for_veg)

# NAT_NON_VEG (remove NA since this is a null value in one or both source attributes)
fri = c("  "," LA"," FL"," RI","SA "," FP","SB "," SF","CB ","RK ","MS ","WA ","NANA","WAFL","WALA","UKLA"," rf","UK ","WARI","WAST"," ST","WASF","WAFP","UKNA","MSNA","GRNA","WADI","SBNA","SANA","RKNA","CBNA")
cas = c("  "," LA"," FL"," RI","SA "," FP","SB "," SF","CB ","RK ","MS ","WA ","NANA","WAFL","WALA","UKLA"," rf","UK ","WARI","WAST"," ST","WASF","WAFP","UKNA","MSNA","GRNA","WADI","SBNA","SANA","RKNA","CBNA")
