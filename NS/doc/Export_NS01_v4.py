


##-----------------------------------------------------------------------
#                Export NOVA SCOTIA GOV
##-----------------------------------------------------------------------

##########################################################################
# This script has been written to export Nova Scotia forest inventory provided by the NS governemnet website (Forest interpretation Cycle 2 and 3) - Downloaded by M. Houle October 17, 2014. 
# Nova Scotia used only one  standard
# The format of the SourceDataset was originally shapefiles (20 regions).
# To facilitate the export stage, a merge into a gdb has been execute prior to the FRIs storage.
# The year of photography is included in the attributes table (PHOTOYR)
#
##########################################################################

## Import the necessary modules
import arcgisscripting, sys, os, csv, shutil, os.path, arcpy, timeit, time
from arcpy import env

## Look for the date
starttime = time.asctime( time.localtime(time.time()) )

## Set the name of the person executing the export script
Executer = "Melina Houle"

gp = arcgisscripting.create(9.3)

## Set the source folder containing the source shapefiles (or Workspace)
InputDir = "H:/FRIs/NS/SourceDataset/v.00.04"

gdbName = "NS Forest Inventory(Cycle 2-3).gdb"

tblName = "forest"

## This is where we will output all the exported files. This folder should exists before launching the script.
workDir= "H:/Melina/CAS"

outDirectory = workDir + "/NS/output"

###############################################################
"""
def mainAB(InputDir, outDirectory):
    if not os.path.exists(InputDir):
        return -1
    #reste du script

    return 0

if __name__ == "__mainAB__":
    main(sys.argv[1], sys.argv[2])
"""
################################################################

## Set the source file containing the Canada Albers Equal Conic
projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId = 2

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "NS"

##-----------------------------------------------------------------------
# You  should not have to change anything below this line
##---------------------------------------------------------------------------------------------------------------------------------------

##-----------------------------
##-----------------------------
##  CREATE DIRECTORIES
##-----------------------------
##-----------------------------

# This is the dir where we write the final shapefiles
shpOutputDir = outDirectory + "/shp"
if os.path.exists(shpOutputDir):
    shutil.rmtree(shpOutputDir)
os.makedirs(shpOutputDir)

# This is the dir where we write the final csv
csvOutputDir = outDirectory + "/csv"
if os.path.exists(csvOutputDir):
    shutil.rmtree(csvOutputDir)
os.makedirs(csvOutputDir)

# This is the dir where we write the joined shapefiles
shpidxOutputDir = outDirectory + "/spatial_index"
if os.path.exists(shpidxOutputDir):
    shutil.rmtree(shpidxOutputDir)
os.makedirs(shpidxOutputDir)

# This is the dir where we write check_geometry  files
checkgeoOutputDir = outDirectory + "/checkgeo"
if os.path.exists(checkgeoOutputDir):
    shutil.rmtree(checkgeoOutputDir)
os.makedirs(checkgeoOutputDir)

# This is the dir where we write the files based on their standard 
tempOutputDir = outDirectory + "/temp"
if os.path.exists(tempOutputDir):
    shutil.rmtree(tempOutputDir)
os.makedirs(tempOutputDir)

##-----------------------------
##-----------------------------
##  CREATE LOG FILES
##-----------------------------
##-----------------------------

## Fill the MainLog Error
logMain = open(workDir + "/Main.log", 'w')

## Create a textpad sheet where the script process is written 
if os.path.exists(outDirectory + "/log.log"):
    try:
        os.remove(outDirectory + "/log.log")
    except:
        logFile.close()
        os.remove(outDirectory + "/log.log")
logFile = open(outDirectory + "/log.log", 'w')

## Create a textpad sheet where error is written 
if os.path.exists(outDirectory + "/error.log"):
    try:
        os.remove(outDirectory + "/error.log")
    except:
        logError.close()
        os.remove(outDirectory + "/error.log")
logError = open(outDirectory + "/error.log", 'w')

################################################################################
# Define the function to write the information about the processing into the textepad sheet, 
def myWrite(file, str):
    file.write(str)
    file.flush()
    
################################################################################

##----------------------------------------
## PROCESS NS Forest Invemtory Cycle 2 and 3 
##----------------------------------------
myWrite(logFile, "CASFRI V.00.04 - EXPORT NS Forest Inventory - Cycle 2 and 3\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n\n")
    
timeStart = timeit.default_timer()

gp.OverWriteOutput = 1
        
try:
    myWrite(logMain, "NS FRI...")
    inFile = InputDir + "/" + gdbName + "/" + tblName
    inputCount = str(arcpy.GetCount_management(inFile))
    
    ## Create a temporary filegeodatabase
    myWrite(logFile, "01 - Creating a gdb...") 
    arcpy.CreateFileGDB_management(tempOutputDir, "NS_GOV.gdb")
    myWrite(logFile, " Done\n")
    
    ## Change projection into Canada Albers Equal Conic
    outFile = tempOutputDir + "/NS_GOV.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    myWrite(logFile, "02 - Changing projection of " + inFile + " into Canada Albers...")
    arcpy.Project_management(inFile, outFile, projection)
    myWrite(logFile, " Done\n")
    
    ## Check geometry and make
    inFile = tempOutputDir + "/NS_GOV.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    outFile = checkgeoOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + "_CheckGeometry.dbf"
    myWrite(logFile, "03 - Checking geometry of " + inFile + "...")
    arcpy.CheckGeometry_management(inFile, outFile)
    myWrite(logFile, " Done\n")

    ## Calculate number of rows to create only shp files and csv files when data exist
    inFile = checkgeoOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + "_CheckGeometry.dbf"
    count = str(arcpy.GetCount_management(inFile))
    myWrite(logFile, "04 - Repairing geometry for " + count + " polygons:  ")
    if count == '0':
        arcpy.Delete_management(inFile)
        shutil.rmtree(checkgeoOutputDir)
    if count > '0':
        inFile = tempOutputDir + "/NS_GOV.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
        arcpy.RepairGeometry_management(inFile)
    myWrite(logFile, count + " wrong geometry\n")
    
    ## Create a CAS_ID field and derive its value
    inFile = tempOutputDir + "/NS_GOV.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    myWrite(logFile, "05 - Adding CAS_ID to " + inFile + " and derive its value...") 
    arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
    arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "-" + tblName.upper().rjust(15,'x') + "-' + str(!MAPSHEET!).upper().rjust(10,'x') + '-' + str(long(!FOREST_ID!)).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
    myWrite(logFile, " Done\n")
        
    ## Create a HEADER_ID field and set its value
    myWrite(logFile, "06 - Adding Field HEADER_ID to " + inFile + " and derive its value...")
    arcpy.AddField_management(inFile, "HEADER_ID", "SHORT")
    arcpy.CalculateField_management(inFile, "HEADER_ID", HeaderId, "PYTHON")
    myWrite(logFile, " Done\n")
    
    ## Create AREA field and set its value
    myWrite(logFile, "07 - Adding Field AREA to " + inFile + "...")    
    arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
    arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
    myWrite(logFile, " Done\n")

    ## Create PERIMETER field and set its value
    myWrite(logFile, "08 - Adding Field PERIMETER to " + inFile + "...")    
    arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
    arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
    myWrite(logFile, " Done\n")

    ## Create a field list that contain the existing fields that you want to export     
    ListsrcFields  = []        
    myWrite(logFile, "09 - Creating a list of source field from " + inFile + "...")
    flist = arcpy.ListFields(inFile)
    for f in flist:
        if not (str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI" or str(f.name) == "OBJECTID" or str(f.name) =="Shape" or str(f.name) == "Shape_Area" or str(f.name) == "Shape_Length"):
            ListsrcFields.append(str(f.name))           
    ## Begin de string with field that you add       
    srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
    for field in ListsrcFields:
        srcFields = srcFields + ";" + str(field)                
    myWrite(logFile, " Done\n")              

    ## Export selected features into csv
    myWrite(logFile, "10 - Exporting " + inFile + " to csv...")
    outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".csv"                
    arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON", outFile, "ADD_FIELD_NAMES")
    myWrite(logFile, " Done\n")

    ## Copy feature class into a shapefile
    inFile = tempOutputDir + "/NS_GOV.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0') 
    myWrite(logFile, "11 - Copy " + prefixName + "_" + str(HeaderId).rjust(4, '0') + " to shp...")
    outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    arcpy.CopyFeatures_management(inFile, outFile)
    myWrite(logFile, " Done\n")

    ## Delete all fields excpet CAS_ID 
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "12 - Deleting fields except CAS_ID from " + inFile )                
    arcpy.DeleteField_management(inFile, srcFields[7:] + ";OBJECTID;Shape_Area;Shape_Lenght;Shape_Leng")
    myWrite(logFile, " Done\n")

    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    exportCount = str(arcpy.GetCount_management(inFile))
    
    ## Create a spatial index
    inFile = tempOutputDir + "/NS_GOV.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    myWrite(logFile, "13 - Dissolve " + prefixName + "_" + str(HeaderId).rjust(4, '0') + "...")
    arcpy.Dissolve_management(inFile,outFile)
    arcpy.AddField_management(outFile, "filename", "TEXT", 50)
    arcpy.CalculateField_management(outFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "'" ,"PYTHON")
    myWrite(logFile, " Done\n\n")

except:
    myWrite(logFile, " ERROR\n")
    myWrite(logError, "Failed to process...\n")
    myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
    sys.exit()
    
myWrite(logFile, "Sourcedataset geometry count = " + inputCount)
myWrite(logFile, "\nGeometries exported = " + str(exportCount))

timeStop = timeit.default_timer()
time = timeStop - timeStart     

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

#myWrite(logMain, "Done\n")                      

shutil.rmtree(tempOutputDir)
                    
