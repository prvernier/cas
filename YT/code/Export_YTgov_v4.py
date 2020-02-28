##-----------------------------------------------------------------------
#                Export Yukon Vegetation Inventory
##-----------------------------------------------------------------------

##########################################################################
# This script has been written to export Yukon vegetation forest inventory provided by the Yukon governemnet downloaded on May 27, 2014 by Melina Houle
#
# The inventory was received from Sur Deforest on July 28th, 2014
# The format of the SourceDataset is a geodatabase  
# The geodatabase has been stored in a folder named YukonVegInventory
#
# The year of photography is included in the attributes table (REF_YEAR)
#
# This scirpt has been written for ArcGIS 10.1
##########################################################################

## Import the necessary modules
import arcgisscripting, sys, os, csv, shutil, os.path, arcpy, timeit, time
from arcpy import env

starttime = time.asctime( time.localtime(time.time()) )

## Create a geoprocessing object
gp = arcgisscripting.create(9.3)

## Set name of the person executing theexport script
Executer = "Melina Houle"

##Set the working directoy
workDir= "H:/Melina/CAS"

## Set the source folder containing the source shapefiles (or Workspace)
InputDir = "H:/FRIs/YT/SourceDataset/v.00.04"

## Name of the sourceFile
gdbName = "YukonVegInventory.gdb"

## Name of the table
tblName = "YTVegInventory"

invName = "GOV"

## Set the destination folder where all the exported files will be placed. This folder should exists before launching the script.
outDirectory = workDir + "/YT/output"

## Set the source file containing the Canada Albers Equal Conic projection
projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

"""
###############################################################
def main(InputDir, outDirectory):
    if not os.path.exists(InputDir):
        return -1
    #reste du script

    return 0

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
################################################################
"""
################################################################################
# Define the function to write the information about the processing into the textepad sheet, 
def myWrite(file, str):
    file.write(str)
    file.flush()
    
################################################################################

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "YT"

HeaderId = 2

##-----------------------------------------------------------------------
# You  should not have to change anything below this line
##---------------------------------------------------------------------------------------------------------------------------------------
##--------------------
##CREATE DIRECTORIES
##--------------------
#This is the dir where we write the final shapefiles
shpOutputDir = outDirectory + "/shp"
if os.path.exists(shpOutputDir):
    shutil.rmtree(shpOutputDir)
os.makedirs(shpOutputDir)

# This is the dir where we write the final csv
csvOutputDir = outDirectory + "/csv"
if os.path.exists(csvOutputDir):
    shutil.rmtree(csvOutputDir)
os.makedirs(csvOutputDir)

# This is the dir where we write check_geometry  files
checkgeoOutputDir = outDirectory + "/checkgeo"
if os.path.exists(checkgeoOutputDir):
    shutil.rmtree(checkgeoOutputDir)
os.makedirs(checkgeoOutputDir)

## This is the dir where we write the files based on their standard 
tempOutputDir = outDirectory + "/temp"
if os.path.exists(tempOutputDir):
    shutil.rmtree(tempOutputDir)
os.makedirs(tempOutputDir)

# This is the dir where we write the final shp
shpidxOutputDir = outDirectory + "/spatial_index"
if os.path.exists(shpidxOutputDir):
    shutil.rmtree(shpidxOutputDir)
os.makedirs(shpidxOutputDir)

##-------------------
## CREATE LOG FILE
##-------------------
# Fill the MainLog Error
logMain = open(workDir + "/Main.log", 'w')

# Create a textpad sheet where the script process is written 
if os.path.exists(outDirectory + "/log.log"):
    try:
        os.remove(outDirectory + "/log.log")
    except:
        logFile.close()
        os.remove(outDirectory + "/log.log")
logFile = open(outDirectory + "/log.log", 'w')

# Create a textpad sheet where error is written 
if os.path.exists(outDirectory + "/error.log"):
    try:
        os.remove(outDirectory + "/error.log")
    except:
        logError.close()
        os.remove(outDirectory + "/error.log")
logError = open(outDirectory + "/error.log", 'w')

gp.OverWriteOutput = 1

##----------------------------------------
## PROCESS YUKON VEGETATION INVENTORY
##----------------------------------------

myWrite(logFile, "CASFRI V.00.04 - EXPORT YT Vegetation Inventory\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n")

timeStart = timeit.default_timer()
               
try:
    
    myWrite(logMain, "YT ... ")
    inFile = InputDir + "/" + gdbName + "/" + tblName

    ## Count object
    inputCount = str(arcpy.GetCount_management(inFile))

    ## Create a temporary filegeodatabase
    inFile = InputDir + "/" + gdbName + "/" + tblName
    myWrite(logFile, "01 - Creating a gdb...") 
    arcpy.CreateFileGDB_management(tempOutputDir, "YT.gdb")
    myWrite(logFile, " Done\n")
    
    layer = "YT"
    inFile = InputDir + "/" + gdbName + "/" + tblName
    myWrite(logFile, "02 - Making a layer from " + inFile + "...") 
    arcpy.MakeFeatureLayer_management(inFile,layer)
    outFile = tempOutputDir + "/YT.gdb/" + layer
    arcpy.CopyFeatures_management(layer, outFile)
    myWrite(logFile, " Done\n")
        
    inFile = tempOutputDir + "/YT.gdb/" + layer
    outFile = checkgeoOutputDir + "/" + layer + ".dbf"
    myWrite(logFile, "03 - Checking geometry of " + inFile + "...")
    arcpy.CheckGeometry_management(inFile, outFile)
    myWrite(logFile, " Done\n")

    ## Calculate number of rows to create only shp files and csv files when data exist
    inFile = checkgeoOutputDir + "/" + layer + ".dbf"
    count = str(arcpy.GetCount_management(inFile))
    myWrite(logFile, "04 - Repairing geometry of for " + count + " polygons:  ")
    if count == '0':
        arcpy.Delete_management(inFile)
    if count > '0':
        inFile = tempOutputDir + "/YT.gdb/" + layer
        arcpy.RepairGeometry_management(inFile,"KEEP_NULL")
    myWrite(logFile, count + " wrong geometry\n")

    ## Create AREA field and set its value
    inFile = tempOutputDir + "/YT.gdb/" + layer
    myWrite(logFile, "05 - Adding Field AREA to " + inFile + "...")
    arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
    arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
    myWrite(logFile, " Done\n")

    ## Create PERIMETER field and set its value
    myWrite(logFile, "06 - Adding Field PERIMETER to " + inFile + "...")    
    arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
    arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
    myWrite(logFile, " Done\n")

    myWrite(logFile, "07 - Adding Field HEADER to " + inFile + "...")  
    arcpy.AddField_management(inFile, "HEADER_ID", "TEXT", 40)
    arcpy.CalculateField_management( inFile, "HEADER_ID", HeaderId, "PYTHON")
    myWrite(logFile, " Done\n")
                                            
    ## Create a CAS_ID field and derive its value
    myWrite(logFile, "08 - Adding CAS_ID to " + inFile + " and derive its value...")
    arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
    arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_' + str(!HEADER_ID!).rjust(4, '0') + '-" + tblName.upper().rjust(15, 'x') + "-xxxxxxxxxx-' + str(!POLY_NO!).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
    myWrite(logFile, " Done\n")

                   
    ## First List include fields from the coverage
    ListsrcFields = []
    myWrite(logFile, "09 - Creating a field List of  " + inFile + "...")
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
    outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') +  ".csv"
    arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
    myWrite(logFile, " Done\n")

    #Cannot delete required field Shape_Area  ## Delete all fields excpet CAS_ID 
    myWrite(logFile, "11 - Deleting fields except CAS_ID from " + inFile )                
    arcpy.DeleteField_management(inFile, srcFields[7:])
    myWrite(logFile, " Done\n")

    outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') +  ".shp"
    myWrite(logFile, "12 - Exporting geometries...")
    arcpy.Project_management(inFile, outFile, projection)
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') +  ".shp"
    arcpy.DeleteField_management(inFile, "OBJECTID;Shape_Area;Shape_Leng")
    myWrite(logFile, " Done\n")
    exportCount = str(arcpy.GetCount_management(inFile))

    ## Delete FeatureLayer 
    myWrite(logFile, "13 - Deleting " +  layer + "...")
    arcpy.Delete_management(layer ,"FeatureLayer")         
    myWrite(logFile, " Done\n\n\n")           
                
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    myWrite(logFile, "14 - Dissolve " + inFile + "...")
    arcpy.Dissolve_management(inFile, outFile)
    myWrite(logFile, " Done\n")

    ## Create a filename field and derive its value
    inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    myWrite(logFile, "15 - Adding Field AREA to " + inFile + "...")
    arcpy.AddField_management(inFile, "filename", "TEXT", 50)
    arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "'" ,"PYTHON")
    myWrite(logFile, " Done\n")
                
    myWrite(logFile, "Sourcedataset geometry count = " + inputCount)
    myWrite(logFile, "\nGeometries exported = " + str(exportCount))


except:
    myWrite(logFile, " ERROR\n")
    myWrite(logError, "Failed to process...\n")
    myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
    myWrite(logMain, " Done\n")                      
    sys.exit()

timeStop = timeit.default_timer()
time = timeStop - timeStart     

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

myWrite(logMain, "Done\n")                      
                
shutil.rmtree(tempOutputDir)
