# NONFOREST

Table 63.  The items for the NONFOREST polygon feature class in the ArcSDE geodatabase theme are:
Name	Width	Output	Type	Decimals	Description
OBJECTID	4	5	B	0	Polygon id (internal use)
DATASRC	6	6	C	0	Source of stand attribute data
DATAYR	4	4	I	0	Year of stand attribute data
PLU	3	3	C	0	Primary land use
SLU	2	2	C	0	Specific land use
STATUS	1	1	C	0	Use indicator
LC	2	2	C	0	Land cover code denoting the overall vegetative or non-vegetative nature of the polygon
SHAPE	8	8	C	0	Feature geometry
SHAPE.AREA	8	18	F	5	Area of polygon in square metres
SHAPE.LEN	8	18	F	5	Length of polygon in metres

Table 64.  The values in the item DATASRC for the NONFOREST polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
INTERP	Polygon description data added from photo-interpretation
UPDATE	Polygon description originally added from a disturbance update
UPDATT	Polygon description originally added from a licensee update
UPDTPW	Polygon description originally added from a private woodlot update

Table 65.  The values in the item PLU for the NONFOREST polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
AGR	Land primarily used for growing agricultural products or non-timber tree products as well as fields and pasture land
DND	Land primarily used for National Defense training and exercises
IND	Land primarily used for industrial purposes including their processing facilities
INF	Land primarily used for transportation, communication and/or utilities
REC	Land primarily used for sport, recreational, cultural and/or entertainment activities
SET	Land primarily used for urban or rural residential purposes
WIL	Land that is incapable of growing trees and uninfluenced by human activity

Table 66.  The values in the item SLU for the NONFOREST polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
AI	Land used for airstrips
AR	Abandoned railways
BA	Land occupied by military bases including buildings, parade grounds and installations
BL	Well-drained barren land that is incapable of growing merchantable sized trees
CB	Cultivated land used for blueberry production
CG	Land used for campsites including picnic grounds and parking facilities
CH	Cultivated land used for horticultural purposes; the production of sod, grass, flowers, ornamental trees and shrubs
CL	Cultivated land used  for the production of crops including grains
CO	Cultivated orchards used for the production of fruit and seeds
CS	Land used for communication purposes such as television, radar and telephone towers
CT	Cultivated land used for the production of Christmas trees
EA	Land used for military exercises and maneuvers
FD	Cultivated crop land protected from the tidal action of the Bay of Fundy
FP	Fallow pasture land
FW	Temporary coding for former wetlands which are no longer in the wetland layer
GC	Golf courses
GP	Land used for the extraction of soil and gravel
IP	Land occupied by industrial and processing facilities, including storage and parking areas
IZ	Impact zones for live ammunition ordinance training
LE	Leisure areas including large landscaped open areas used for entertainment purposes, playing fields, zoos, etc.
LF	Landfill sites
NP	Non-Productive Forest (pre-1993 inventory only)
OC	Occupied - city, town, residential area, etc. (to be classified as urban or rural in 2003-2012 inventory)
MI	Land used for mining purposes
PA	Treed parkland in residential settings
PB	Land used for the extraction of peat
PP	Land used for above ground and protected underground pipelines
PR	Provincial highways (DOT roads)
QU	Land used for the extraction and crushing of rock material
RF	Lands located within and along rivers or streams that are periodically scoured by ice flows and possibly devoid of shrub, treed vegetation
RO	Rock outcrop, devoid of soil and vegetation
RR	Railroads
RU	Residential rural settlements including churches, cemeteries, commercial businesses, farm storage facilities
RY	Land used for road right-of-ways
SG	Land used for the treatment of sewage
TM	Transmission lines
TR	Land used for walking, hiking trails
UR	Urban settlements including residential, commercial and non-commercial facilities, infrastructure, parking areas, etc.
WR	Winter roads

Table 67.  The values in the item STATUS for the NONFOREST polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
A	Active
I	Inactive

Table 68.  The values in the item LC for the NONFOREST polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
NV	Land with little or no vegetation present
VG	Land vegetated with grasses, crops, or other ground vegetation
VS	Land vegetated with shrubs
VT	Land vegetated with tree species


# WATERBODY

Table 69.  The items for the WATERBODY polygon feature class in the ArcSDE geodatabase theme are:
Name	Width	Output	Type	Decimals	Description
OBJECTID	4	5	B	0	Polygon id (internal use)
DATASRC	4	4	C	0	Source of stand attribute data
DATAYR	4	4	I	0	Year of stand attribute data
WATER_CODE	2	2	C	0	Water code
BUFFER_CODE	2	2	I	0	Water buffer code
NAME	50	50	C	0	Name associated with water body (currently unassigned)
SHAPE	8	8	C	0	Feature geometry
SHAPE_AREA	8	18	F	5	Area of polygon in square metres
SHAPE.LEN	8	18	F	5	Length of polygon in metres

Table 70.  The values in the item DATASRC for the WATERBODY polygon feature class in the ArcSDE geodatabase theme are:
Refer to the DATASRC item of the NONFOREST polygon feature class to see codes for this item.

Table 71.  The values in the item WATER_CODE for the WATERBODY polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
AQ	Aquaculture -saltwater or freshwater areas used for commercial fish-farming
LK	Lake -a natural or artificial static body of freshwater which has a maximum depth >2 meters and is >5 hectares in area
ON	Ocean -a large body of salt water that is located at, along or near the province’s coastline
PN	Pond -a static body of freshwater often but not always artificially formed and is usually less than five (5) hectares in area
RV	River -a watercourse formed when water flows between continuous, definable banks
SL	Salt lake -a static body of unvegetated brackish water that is usually located on the inland side of coastal sand dunes
WA	Water -unspecified body of water

Table 72.  The values in the item BUFFER_CODE for the WATERBODY polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
-1	No applicable water buffer
1	Class 1 water body requiring applicable buffer
2	Class 2 water body requiring applicable buffer


# WETLAND

Table 73.  The items for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Name	Width	Output	Type	Decimals	Description
OBJECTID	4	5	B	0	Polygon id (internal use)
WLOC	1	1	C	0	Wetland category
WC	2	2	C	0	Dominant wetland class
WRI	2	2	C	0	Water regime indicator
IM	2	2	C	0	Impoundment modifier
VT	2	2	C	0	Specific vegetation cover type
SPVC	1	1	I	0	Percent vegetation cover for specific vegetation cover type
SHAPE	8	8	C	0	Feature geometry
SHAPE_AREA	8	18	F	5	Area of polygon in square metres
SHAPE.LEN	8	18	F	5	Length of polygon in metres

Table 74.  The values in the item WLOC for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
C	Coastal -wetlands seaward of the high water mark / landward limit  line
F	Freshwater - wetlands typically located beyond the extent of salt water inundation and are landward of the high water mark/landward limit line

Table 75.  The values in the item WC for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
AB	Aquatic Bed - wetlands dominated by permanent shallow standing water (<2 meters in depth during mid-summer) that may contain plants that grow on or below the surface of the water
BC	Beach - unconsolidated deposits of sand, gravel, cobble and boulders on the shores of freshwater bodies
BO	Bog - wetlands typically covered by peat, which have a saturated water regime as well as a closed drainage system and frequently covered by ericaceous shrubs, sedges and sphagnum moss and/or black spruce
CM	Coastal Marsh - wetlands dominated by rooted herbaceous plants that drain directly into coastal waters and have the potential to be at least partially inundated with salt or brackish water
DU	Dune - unconsolidated sand or gravel deposits capping beach environments recognized by raised topography and may be vegetated with salt-tolerant vegetation such as marram grass or may be established with ericaceous vegetation or tree species
FE	Fen - wetlands typically covered by peat, having a saturated water regime, and an open drainage system and typically covered by sedges
FM	Freshwater Marsh - wetlands dominated by rooted herbaceous plants and includes most typical marshes as well as seasonally flooded wet meadows
FW	Forested Wetland - forested areas with abundant standing water including the seasonally flooded forest of the Saint John River Valley and other floodplains
RK	Rocky Shore - areas of bedrock exposed between the extreme high and extreme low tide levels on the coastal shores often vegetated with rockweed and other plants that attach to the rock substrate
SB	Shrub Wetland - wetlands dominated by a variety of shrubs including shrub dominated marshes and alder thickets
TF	Tidal Flat - areas of mud and sandy mud exposed between the extreme high tide and extreme low tide mark and can be vegetated with various types of seaweed or sea grasses such as eel grass

Table 76.  The values in the item WRI for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
PF	Permanently Flooded - >= 20% of the wetland is covered by standing surface water for all or most of the growing season
SA	Saturated - the substrate is saturated to the surface for extended periods during the growing season, but less than 20% of the wetland is covered by surface water
SF	Seasonally Flooded - surface water is present on the wetland only for a short period during the growing season in most years
TF	Tidal - surface water may only be present on wetlands during high tide and the level of water fluctuates with tidal influence

Table 77.  The values in the item IM for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
BP	Beaver Pond - used if the beaver dam is affecting the water regime of a wetland
DI	Duck's Unlimited impoundment
MI	Man-made Impoundment (other than Duck's Unlimited impoundments)

Table 78.  The values in the item VT for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
AW	Alders - alder stands or swales that are associated with a watercourse or a wetland
EV	Emergent Vegetation - common marsh plants include cattails, bur-reeds, various sedges, rushes and grasses like bluejoint and cordgrass spp., flowering herbaceous plants, goldenrods, asters and many others
FH	Forested Hardwood Vegetation - non-commercial or commercial hardwood tree species such as silver maple
FS	Forested Softwood Vegetation - non-commercial or commercial softwood tree species such as cedar, tamarack and black spruce
FU	Feature Unvegetated - used to describe coastal features or shoreline features that do not have visible vegetation
FV	Feature Vegetated - used to describe coastal or shoreline features that have visible vegetation (i.e. exposed at low tide or visible submerged vegetation)
OV	Open-water Vegetated - open water with vegetation present on top of or near the water surface
OW	Open-water Unvegetated - open water with no vegetation present
SV	Shrub Vegetation (except alder) - dominant shrubs are willows, dogwoods, meadow sweet, bog rosemary, leatherleaf, Labrador tea and saplings of trees such as red maple

Table 79.  The values in the item SPVC for the WETLAND polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
1	< 5% of the wetland area or coastal feature is covered in vegetation
2	5-25% of the wetland area or coastal feature is covered in vegetation
3	26-75% of the wetland area or coastal feature is covered in vegetation
4	76-95% of the wetland area or coastal feature is covered in vegetation
5	> 95% of the wetland area or coastal feature is covered in vegetation


# ROADS

Table 80.  The items for the ROADS polygon feature class in the ArcSDE geodatabase theme are:
Name	Width	Output	Type	Decimals	Description
OBJECTID	4	5	B	0	Polygon id (internal use)
DATASRC	6	6	C	0	Source of stand attribute data
DATAYR	4	4	I	0	Year of stand attribute data
PLU	3	3	C	0	Primary land use
SLU	2	2	C	0	Specific land use
STATUS	1	1	C	0	Use indicator
LC	2	2	C	0	Land cover code denoting the overall vegetative or non-vegetative nature of the polygon
MAPNO	4	4	I	0	Reference feature dataset Map Index map number
SHAPE	8	8	C	0	Feature geometry
SHAPE.AREA	8	18	F	5	Area of polygon in square metres
SHAPE.LEN	8	18	F	5	Length of polygon in metres

Table 81.  The values in the item DATASRC for the ROADS polygon feature class in the ArcSDE geodatabase theme are:
Refer to the DATASRC item of the NONFOREST polygon feature class to see codes for this item.

Table 82.  The values in the item PLU for the ROADS polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
INF	Land primarily used for industrial purposes including their processing facilities

Table 83.  The values in the item SLU for the ROADS polygon feature class in the ArcSDE geodatabase theme are:
Value	Description
FX	Temporary classification to DNR forest roads which will  be incorporated into the Forest feature class
PR	Roads classed as provincial highways (DOT roads) which will be incorporated into the Non_forest feature class
RD	Unclassified roads which may include DOT roads and/or DNR roads

Table 84.  The values in the item STATUS for the ROADS polygon feature class in the ArcSDE geodatabase theme are:
Refer to the STATUS item of the NONFOREST polygon feature class to see codes for this item.


