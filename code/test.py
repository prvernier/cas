import os
import psycopg2
import geopandas as gpd
import pprint

print("done")
#y = gpd.read_file("../fri/bc_0008/vri1000.geojson")
#y500 = y[y['proj_age_1']>=300]
#print(y500.head())


#conn = psycopg2.connect(database="fri", user="postgres", password="postgres")
#y = gpd.read_postgis("select * from bc_0008.vri", conn, geom_col='wkb_geometry')
#print(y.head())

'''
mypath = "E:/Pierre/Dropbox (BEACONs)/PRV/CASFRI/code/data/"
print(mypath)

y500 = y[y['proj_age_1']>=500]
v500 = y500[['feature_id','wkb_geometry']]
d500 = y500[['feature_id','species_cd_1','proj_age_1','species_pct_1','species_cd_2','proj_age_2','species_pct_2']]
print(d500.head())

v500.to_file("data/vri9.geojson",driver="GeoJSON")
j500 = gpd.read_file("data/vri9.geojson")
print(j500.head())
'''

'''
# Read a file geodatabase (takes a long time for large files)
#x = gp.read_file("C:/Users/beacons/Dropbox (BEACONs)/PRV/cpr/data/dgtl_road_atlas.gdb", layer="TRANSPORT_LINE")
#x = gp.read_file("C:/Users/pvernier/Desktop/GIS Projects/BC/VEG_COMP_LYR_R1_POLY.gdb", layer="VEG_COMP_LYR_R1_POLY")

# Read a shapefile, select stands > 600 years, and save as shapefile - converts columns names to upper case and 10 characters maximum
x = gp.read_file("C:/Users/pvernier/Desktop/GIS Projects/BC/VRI/inventory_region_9.shp")
x600 = x[x['PROJ_AGE_1']>=600]
x600.to_file(os.path.join(mypath, "x600.shp"))

# Do the same with a postgis dataset - saves original column names
conn = psycopg2.connect(database="gis_analysis", user="postgres", password="postgres")
y = gp.read_postgis("select * from bc.vri9", conn, geom_col='wkb_geometry')
y600 = y[y['proj_age_1']>=600]
y600 = y600[['proj_age_1','proj_age_2','wkb_geometry']]
y600.to_file(os.path.join(mypath, "y600.shp"))
conn.close()
'''

# OLDER STUFF
'''
#import geopandas as gp
#x = gp.read_file("C:/Users/beacons/Dropbox (BEACONs)/PRV/cpr/data/dgtl_road_atlas.gdb", layer="TRANSPORT_LINE")

import psycopg2
import requests
from shapely.geometry import Point, MultiPoint


# Create database
connection = psycopg2.connect(database="gis_analysis", user="postgres", password="postgres")
cursor = connection.cursor()
cursor.execute("CREATE TABLE art_pieces (id SERIAL PRIMARY KEY, code VARCHAR(255), location GEOMETRY)")
connection.commit()


# Download data
url="http://coagisweb.cabq.gov/arcgis/rest/services/public/PublicArt/MapServer/0/query"
params={"where":"1=1","outFields":"*","outSR":"4326","f":"json"}
r=requests.get(url,params=params)
data=r.json()
data["features"][0]

# Insert data in database using WKT
for a in data["features"]:
    code = a["attributes"]["ART_CODE"]
    wkt = "POINT(" + str(a["geometry"]["x"]) + " " + str(a["geometry"]["y"]) + ")"
    if a["geometry"]["x"]=='NaN':
        pass
    else:
        cursor.execute("INSERT INTO art_pieces (code, location) VALUES ({},ST_GeomFromText('{}'))".format(code, wkt))
connection.commit()

# Insert data in database using SHAPELY
thepoints=[]
for a in data["features"]:
    code = a["attributes"]["ART_CODE"]
    p = Point(float(a["geometry"]["x"]),float(a["geometry"]["y"]))
    thepoints.append(p)
    if a["geometry"]["x"]=='NaN':
        pass
    else:
        cursor.execute("INSERT INTO art_pieces (code, location) VALUES ('{}',ST_GeomFromText('{}'))".format(code, p.wkt))
connection.commit()
'''