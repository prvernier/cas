
library(rpostgis)
library(tidyverse)
library(summarytools)

sink("output/ab06.md")
cat("# AB06 Attributes\n\n")

con = dbConnect(RPostgreSQL::PostgreSQL(), dbname="cas", host="localhost", port=5432, user="postgres", password="postgres")
df = dbGetQuery(con, "SELECT poly_num, density, height, sp1, sp1_per, sp2, sp2_per, sp3, sp3_per, sp4, sp4_per, sp5, sp5_per, trm_1 FROM fri.ab06;")


# CAS_ID
cat("## CAS_ID\n\n")

x1 = "AB_0006"
x2 = "xxxxxGB_S21_TWP"
x3 = paste0("xxxxx",df$trm_1)
x4 = paste0("0",df$poly_num)
x5 = sprintf("%07d",0:(nrow(df)-1))
df$cas_id = paste0(x1,"-",x2,"-",x3,"-",x4,"-",x5)
head(df[,c("poly_num","cas_id")])

<br>
**PHOTO_YEAR**

The year of photography is included in the attributes table (REFERENCE_YEAR)

```{r}
#df$photo_year = df$reference_year
#head(df[,c("reference_year","photo_year")])
```

<br>
**SPECIES_1 - SPECIES_10**

Tabulate all species codes across species fields

```{r}
spp = unique(c(df$sp1,df$sp2,df$sp3,df$sp4,df$sp5))
cat(spp,"\n")
```

<br>
**SPECIES_PER_1 - SPECIES_PER_10**

Tabulate all species percentages to ensure they are within 0-100

```{r}
spp_pct = unique(c(df$sp1_per,df$sp2_per,df$sp3_per,df$sp4_per,df$sp5_per))
cat("Range of values:",range(spp_pct, na.rm=T))
cat("Unique values:",spp_pct,"\n")
```

<br>
**CROWN_CLOSURE_LOWER, CROWN_CLOSURE_HIGHER**

```{r}
print(suppressMessages(dfSummary(df$density)))
```

<br>
**HEIGHT_LOWER, HEIGHT_UPPER**

```{r}
print(suppressMessages(dfSummary(df$height)))
```

sink()