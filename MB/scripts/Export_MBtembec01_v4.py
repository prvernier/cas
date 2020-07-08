


##-----------------------------------------------------------------------
#                Export MANITOBA_TEMBEC
##-----------------------------------------------------------------------

##########################################################################
# The forest inventory SourceDataset from Tembec (Manitoba) is a unique shapefiles name "fml1_fri97"
#
# The year of photography is included in the file and correspon the the field "FRI_YEAR"
#
# To process the export, you will need to placed the SourceDataset in a folder named "input" and create a folder named "output" where the
# exported .csv and .shp will be created 
##########################################################################


## Import the necessary modules
import arcgisscripting, sys, os, csv, shutil, os.path, zlib, arcpy, timeit, time
from arcpy import env

starttime = time.asctime( time.localtime(time.time()) )

## Create a geoprocessing object
gp = arcgisscripting.create(9.3)

## Set name of the person executing theexport script
Executer = "Melina Houle"

##Set the working directoy
workDir= "H:/Melina/CAS"

## Set the source folder containing the source shapefiles (or Workspace)
InputDir = "H:/FRIs/MB/SourceDataset/v.00.04/Tembec"

## Set the name of the source shapefiles 
shpName = "fml1_fri97"

## Set the destination folder where all the exported files will be placed. This folder should exists before launching the script.
outDirectory = workDir + "/MBTembec/output"

## Set the source file containing the Canada Albers Equal Conic projection
projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

"""
###############################################################
def mainAB(InputDir, outDirectory):
    if not os.path.exists(InputDir):
        return -1
    #reste du script

    return 0

if __name__ == "__mainAB__":
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
prefixName = "MB"

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId = 1  #  MB_Louisiana Pacific is 2 and MB_GOV is 3 MB_Porcupine Mountain is 4

##-----------------------------------------------------------------------
# You  should not have to change anything below this line
##---------------------------------------------------------------------------------------------------------------------------------------
##--------------------
##CREATE DIRECTORIES
##--------------------
# This is the dir where we write check_geometry  files
checkgeoOutputDir = outDirectory + "/checkgeo"
if os.path.exists(checkgeoOutputDir):
    shutil.rmtree(checkgeoOutputDir)
os.makedirs(checkgeoOutputDir)

# This is the dir where we write the final shp
shpOutputDir = outDirectory + "/shp"
if os.path.exists(shpOutputDir):
    shutil.rmtree(shpOutputDir)
os.makedirs(shpOutputDir)

# This is the dir where we write the final shp
tempOutputDir = outDirectory + "/temp"
if os.path.exists(tempOutputDir):
    shutil.rmtree(tempOutputDir)
os.makedirs(tempOutputDir)

# This is the dir where we write the final csv
csvOutputDir = outDirectory + "/csv"
if os.path.exists(csvOutputDir):
    shutil.rmtree(csvOutputDir)
os.makedirs(csvOutputDir)

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

myWrite(logFile, "CASFRI V.00.04 - EXPORT MB TEMBEC FRI\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n")

timeStart = timeit.default_timer()

try:

    myWrite(logMain, "MB ... ")
    inFile = InputDir + "/" + shpName + ".shp" 

    ## Count object
    inputCount = str(arcpy.GetCount_management(inFile))

    ## Project the shapefiles in Canada Lambert
    outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "\n01 - Projecting " + inFile + " into Canada Albers Equal Conic...")     
    arcpy.Project_management(inFile, outFile, projection)
    myWrite(logFile, " Done\n")

    ## Check geometry and make -- We check and the dataset do not have any wrong geometries
    #inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + ".shp"
    #outFile = checkgeoOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + "_CheckGeometry.dbf"
    myWrite(logFile, "02 and 03 - Checking geometry of " + inFile + "...")
    shutil.rmtree(checkgeoOutputDir)
    #arcpy.CheckGeometry_management(inFile, outFile)
    #myWrite(logFile, " Done\n")

    ## Calculate number of rows to create only shp files and csv files when data exist
    #inFile = checkgeoOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + "_CheckGeometry.dbf"
    #count = str(arcpy.GetCount_management(inFile))
    #myWrite(logFile, "03 - Repairing " + count + "geometries ...")
    #if count == '0':
    #    arcpy.Delete_management(inFile)
    #    shutil.rmtree(checkgeoOutputDir)
    #if count > '0':
    #    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    #    arcpy.RepairGeometry_management(inFile)
    myWrite(logFile, "  0 wrong geometry...Done\n")
 
    ## Create a AREA field and derive its value
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "04 - Adding Field AREA to " + inFile + "...")
    arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
    arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
    myWrite(logFile, " Done\n")

    ## Create PERIMETER field and set its value
    myWrite(logFile, "05 - Adding Field PERIMETER to " + inFile + "...")    
    arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
    arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
    myWrite(logFile, " Done\n")

    ## Create a HEADER_ID field and set its value
    myWrite(logFile, "06 - Adding Field HEADER_ID to " + inFile + "...")     
    arcpy.AddField_management(inFile, "HEADER_ID", "SHORT")
    arcpy.CalculateField_management(inFile, "HEADER_ID", HeaderId, "PYTHON")
    myWrite(logFile, " Done\n")
    
    ## Create a CAS_ID field and derive its value
    myWrite(logFile, "07 - Adding Field CAS_ID to " + inFile + "...")     
    arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
    arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "-" + str(shpName).upper().rjust(15,'x') + "-' + str(!TILE!).upper().rjust(10,'x') + '-' + str(!LND_ID!).rjust(10,'0') + '-' + str(!FID!).rjust(7, '0')", "PYTHON")
    myWrite(logFile, " Done\n")

    ## List fields to delete     
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "08 - Listing fields from" + inFile + "...")
    ListsrcFields  = []        
    fieldslist = arcpy.ListFields(inFile)
    for f in fieldslist:
        if not (str(f.name) == "FID" or str(f.name) == "Shape" or str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI"):
            ListsrcFields.append(str(f.name))
    srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
    for field in ListsrcFields:
        srcFields = srcFields + ";" + str(field)
    myWrite(logFile, " Done\n")
                   
    ## Export selected features into csv
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".csv"
    myWrite(logFile, "09 - Exporting " + inFile + " to CSV...")     
    arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
    myWrite(logFile, " Done\n")

    ## Delete duplicate fields from the shapefile in order to keep only CAS_ID
    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "10 - Deleting most of the fields from " + inFile + "...")     
    arcpy.DeleteField_management(inFile,  srcFields[7:])
    myWrite(logFile, " Done\n")

    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    exportCount = str(arcpy.GetCount_management(inFile))
    outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    myWrite(logFile, "11 - Dissolve " + inFile + "...")
    arcpy.Dissolve_management(inFile, outFile)
    myWrite(logFile, " Done\n")

    ## Create a filename field and derive its value
    inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    myWrite(logFile, "12 - Adding Field AREA to " + inFile + "...")
    arcpy.AddField_management(inFile, "filename", "TEXT", 50)
    arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "'" ,"PYTHON")
    myWrite(logFile, " Done\n")

    myWrite(logFile, "\nSourcedataset geometry count = " + inputCount)
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

#myWrite(logMain, "Done\n")                      
                
shutil.rmtree(tempOutputDir)

          