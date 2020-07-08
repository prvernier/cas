##-----------------------------------------------------------------------
#                Export Manitoba High Rock
##-----------------------------------------------------------------------

##########################################################################
# This script has been written to export Manitoba High Rock forest inventory provided by the MB governemnet downloaded on May 27, 2014 by Melina Houle
#
# The format of the SourceDataset is  a geodatabase
# The inventory standard if FLI
# The geodatabase has been stored in a folder named SourceDataset/v.00.04/HighRock
#
# The year of photography is included in the attributes table (YEARPHOTO)
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
InputDir = "H:/FRIs/MB/SourceDataset/v.00.04/HighRock"

## Name of the sourceFile
gdbName = "LCV_MB_FLI_HIGHROCK_20072009.gdb"

## Name of the table
tblName = "LCV_MB_FLI_HIGHROCK_20072009"

## Set the destination folder where all the exported files will be placed. This folder should exists before launching the script.
outDirectory = workDir + "/MBHR/output"

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

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId = 7  

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "MB"

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
## PROCESS BC GOV VEGETATION INVENTORY
##----------------------------------------

myWrite(logFile, "CASFRI V.00.04 - EXPORT MANITOBA HIGH ROCK \n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n")

timeStart = timeit.default_timer()
               
try:
    
    myWrite(logMain, "MB High Rock ... ")
    inFile = InputDir + "/" + gdbName + "/" + tblName

    ## Count object
    inputCount = str(arcpy.GetCount_management(inFile))

    ## Create a temporary filegeodatabase
    myWrite(logFile, "01 - Creating a gdb...") 
    arcpy.CreateFileGDB_management(tempOutputDir, "MB_HR.gdb")
    myWrite(logFile, " Done\n")
    
    inFile = InputDir + "/" + gdbName + "/" + tblName
    outFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    myWrite(logFile, "02 - Copy polygons of " + inFile + "...")
    arcpy.CopyFeatures_management(inFile, outFile)
    myWrite(logFile, " Done\n")
    
    ## Check for wrong geometrie. These step have been erase since there is no wrong geometry
    inFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    myWrite(logFile, "03 -04 - Checking geometry : There is no wrong geometries in High Rock")
        
    ## Create AREA field and set its value
    inFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
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
    arcpy.CalculateField_management(inFile, "HEADER_ID", str(HeaderId),"PYTHON")
    myWrite(logFile, " Done\n")    
                
    ## Create a CAS_ID field and derive its value
    myWrite(logFile, "08 - Adding CAS_ID to " + inFile + " and derive its value...")
    arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
    arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_' + str(!HEADER_ID!).rjust(4, '0') + '-" + tblName.upper().rjust(15,'x') + "-xxxxxxxxxx-' + str(!OBJECTID!).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
    myWrite(logFile, " Done\n")
    
    ## First List include fields from the coverage
    ListsrcFields = []
    inFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    myWrite(logFile, "09 - Creating a field List of  " + inFile + "...")
    flist = arcpy.ListFields(inFile)
    for f in flist:
        if not (str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI" or str(f.name) == "OBJECTID" or str(f.name) == "Shape" or str(f.name) == "Shape_Area" or str(f.name) == "Shape_Length"):
            ListsrcFields.append(str(f.name))           
        ## Begin de string with field that you add       
    srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
    for field in ListsrcFields:
        srcFields = srcFields + ";" + str(field)                
    myWrite(logFile, " Done\n")              
               
    ## Export selected features into csv
    myWrite(logFile, "10 - Exporting " + inFile + " to csv...")
    inFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".csv"
    arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
    myWrite(logFile, " Done\n")

    ## Delete all fields excpet CAS_ID
    inFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    myWrite(logFile, "11 - Deleting fields except CAS_ID from " + inFile )                
    arcpy.DeleteField_management(inFile, srcFields[7:])
    myWrite(logFile, " Done\n")

    inFile = tempOutputDir + "/MB_HR.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
    outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "12- Reprojecting High Rock into Albers...")  
    arcpy.Project_management(inFile, outFile, projection)
    myWrite(logFile, " Done\n")

    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    arcpy.DeleteField_management(inFile, "SHAPE_Area;SHAPE_Leng;OBJECTID")
    outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    exportCount = str(arcpy.GetCount_management(inFile))
    myWrite(logFile, "13 - Dissolve " + prefixName + "_" + str(HeaderId).rjust(4, '0') + " to create a spatial extent...")
    arcpy.Dissolve_management(inFile, outFile)
    myWrite(logFile, "Done\n")

    ## Create a filename field and derive its value
    inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
    myWrite(logFile, "14 - Adding Field filename to " + inFile + "...")
    arcpy.AddField_management(inFile, "filename", "TEXT", 50)
    arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "'" ,"PYTHON")
    myWrite(logFile, " Done\n\n")
                                           
    myWrite(logFile, "Sourcedataset geometry count = " + inputCount)
    myWrite(logFile, "\nGeometries exported = " + str(exportCount))


except:
    myWrite(logFile, " ERROR\n")
    myWrite(logError, "Failed to process...\n")
    myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
    myWrite(logMain, " Done\n")                      

timeStop = timeit.default_timer()
time = timeStop - timeStart     

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

#myWrite(logMain, "Done\n")                      
                
#shutil.rmtree(tempOutputDir)
