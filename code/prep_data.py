import os
import geopandas as gp

# Read a file geodatabase (takes a long time for large files)
fri = gp.read_file("C:/Users/PIVER37/Documents/CASFRI/FRIs/BC/SourceDataset/v.00.06/VEG_COMP_LYR_R1_POLY.gdb", layer="WHSE_FOREST_VEGETATION_2018_VEG_COMP_LYR_R1_POLY")

mypath = "E:/Pierre/Dropbox (BEACONs)/PRV/CASFRI/code/data/"
print(mypath)

y500 = y[y['proj_age_1']>=500]
v500 = y500[['feature_id','wkb_geometry']]
d500 = y500[['feature_id','species_cd_1','proj_age_1','species_pct_1','species_cd_2','proj_age_2','species_pct_2']]
print(d500.head())

v500.to_file("data/vri9.geojson",driver="GeoJSON")
j500 = gpd.read_file("data/vri9.geojson")
print(j500.head())

# Read a shapefile, select stands > 600 years, and save as shapefile
#   - converts columns names to upper case and 10 characters maximum
x = gp.read_file("C:/Users/pvernier/Desktop/GIS Projects/BC/VRI/inventory_region_9.shp")
x600 = x[x['PROJ_AGE_1']>=600]
x600.to_file(os.path.join(mypath, "x600.shp"))
