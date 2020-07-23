# Export partial inventories to geojson files
# PVernier 2019-01-14

library(sf)

# BC_0008 - random selection of 10,000 polygons
x = st_read(dsn="PG:host=localhost dbname=fri user=postgres password=postgres", layer="bc_0008.vri10000", 
	query=paste0("SELECT * FROM bc_0008.vri10000"), stringsAsFactors = FALSE, as_tibble=FALSE)
st_write(x, dsn="../fri/bc_0008/fri10000.geojson")

# AB_0006
x = st_read(dsn="PG:host=localhost dbname=fri user=postgres password=postgres", layer="ab_0006.avi", 
	query=paste0("SELECT * FROM ab_0006.avi LIMIT 1000"), stringsAsFactors = FALSE, as_tibble=FALSE)
st_write(x, dsn="../fri/ab_0006/fri1000.geojson")

# AB_0016

# NB_0001
x = st_read(dsn="PG:host=localhost dbname=fri user=postgres password=postgres", layer="nb_0001.forest", 
	query=paste0("SELECT * FROM nb_0001.forest LIMIT 1000"), stringsAsFactors = FALSE, as_tibble=FALSE)
st_write(x, dsn="../fri/nb_0001/fri1000.geojson")
