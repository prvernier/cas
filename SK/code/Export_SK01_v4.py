

##-----------------------------------------------------------------------
#                Export SASKATCHEWAN_GOV
##-----------------------------------------------------------------------

##########################################################################
# The forest inventory of Saskatchewan is one big geodatabase (more than 2 Go)
# 
# The year of photography is include in the attribute table. The name of the field is "SYR"
# 
# To process Saskatchewan forest inventory, you will need to split it by mapsheet. Objects that have mapsheet = 0 is not part of the forest inventory 
#
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
InputDir = "H:/FRIs/SK/SourceDataset/v.00.04"

## This is where we will output all the exported files. This folder should exists before launching the script.
outDirectory = workDir + "/SK/output"

## Set the name of the source gdbfiles 
gdbName = "UTM"

## Set the source file containing the Canada Lambert projection
projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId = 1

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "SK"
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
##--------------------
##CREATE DIRECTORIES
##--------------------
# This is the dir where we write check_geometry  files
checkgeoOutputDir = outDirectory + "/checkgeo"
if os.path.exists(checkgeoOutputDir):
    shutil.rmtree(checkgeoOutputDir)
os.makedirs(checkgeoOutputDir)

# This is the dir where we write temporary shp files
tempOutputDir = outDirectory + "/temp"
if os.path.exists(tempOutputDir):
    shutil.rmtree(tempOutputDir)
os.makedirs(tempOutputDir)

# This is the dir where we write the final shp
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

##-------------------
## CREATE LOG FILE
##-------------------
## Fill the MainLog Error
#logMain = open(workDir + "/Main.log", 'w')

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

gp.OverWriteOutput = 1

##----------------------------------------
## PROCESS SK VEGETATION INVENTORY
##----------------------------------------
myWrite(logFile, "CASFRI V.00.04 - EXPORT WBNP Vegetation Inventory\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n")

timeStart = timeit.default_timer()

try:
    inFile = InputDir + "/" + gdbName + ".gdb" + "/fpoly"
    ## Count object
    inputCount = str(arcpy.GetCount_management(inFile))
    
    ## Change the projection into Canada Lambert
    outFile = tempOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "01 - Projecting " + inFile + "into Canada Albers Conformal Conic...")
    arcpy.Project_management(inFile, outFile, projection)
    myWrite(logFile, " Done\n")

    ## Create a CAS_ID field and derive its value
    inFile = tempOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "02 - Adding Field CAS_ID to " + inFile + "...") 
    arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
    arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "-" + str(gdbName).rjust(15,'x') + "-' + str(!MAP!).rjust(10,'x') + '-' + str(!OBJECTID!).rjust(10, '0') + '-' + str(!FID!).rjust(7,'0')", "PYTHON")
    myWrite(logFile, " Done\n")

    ## Create a HEADER_ID field and set its value
    myWrite(logFile, "03 - Adding Field HEADER_ID to " + inFile + "...")
    arcpy.AddField_management(inFile, "HEADER_ID", "SHORT")
    arcpy.CalculateField_management(inFile, "HEADER_ID", HeaderId, "PYTHON")
    myWrite(logFile, " Done\n")

    ## Create a AREA field and derive its value
    myWrite(logFile, "04 - Adding Field AREA to " + inFile + "...")
    arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
    arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
    myWrite(logFile, " Done\n")
    
    ## Create a PERIMETER field and set its value in hectare
    myWrite(logFile, "05 - Adding Field PERIMETER to " + inFile + "...")    
    arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
    arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
    myWrite(logFile, " Done\n")
            
    ## Create a List of MAP to split the shp
    # Set an empty List  
    MapList =[u'0', u'210', u'211', u'212', u'220', u'230', u'240', u'250', u'260', u'270', u'280']
    
    ## Convert shp into layer
    layer = "SK"
    inFile = tempOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
    myWrite(logFile, "06 - Making a layer from " + inFile + "...") 
    arcpy.MakeFeatureLayer_management(inFile,layer)
    myWrite(logFile, " Done\n")
    
    ## Split the shp into mapsheet to allow the process 
    for Map in MapList:
        myWrite(logFile, "Mapsheet = " + str(Map) + "\n") 
        ## Faire une sélection à partir du layer selon les éléments contenu dans la list
        myWrite(logFile, "07 - Selecting " + str(Map) + "from " + inFile + "...") 
        arcpy.SelectLayerByAttribute_management(layer, "NEW_SELECTION", " \"CZONE" + "\"= '" + Map + "'")
        myWrite(logFile, " Done\n")
        outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_CZONE" + str(Map).rjust(3, '0')
        arcpy.CopyFeatures_management(layer, outFile)
        arcpy.SelectLayerByAttribute_management(layer, "CLEAR_SELECTION")
    myWrite(logFile, " Done\n")

    ## Delete FeatureLayer 
    myWrite(logFile, "08 - Deleting " +  layer + "...")
    arcpy.Delete_management(layer,"FeatureLayer")         
    myWrite(logFile, " Done\n")           
  
    sumExport = '0'
    arcpy.env.workspace = shpOutputDir
    fcList = arcpy.ListFeatureClasses()
    for fc in fcList:
    
        try:
            ## Check geometry
            fname = fc.rsplit(".")[0]
            inFile = shpOutputDir + "/" + fc
            outFile = checkgeoOutputDir + "/" + fname + "_CheckGeometry.dbf"
            myWrite(logFile, "09 - Checking geometry of " + inFile + "...")
            arcpy.CheckGeometry_management(inFile, outFile)
            myWrite(logFile, " Done\n")

            ## Repair geometry that has problems
            fname = fc.rsplit(".")[0]
            inFile = checkgeoOutputDir + "/" + fname + "_CheckGeometry.dbf"
            myWrite(logFile, "10 - Repairing geometry of " + inFile + "...")
            count = str(arcpy.GetCount_management(inFile))
            myWrite(logFile, "11 - Repairing geometry for " + count + " polygons:  ")
            if count == '0':
                arcpy.Delete_management(inFile)
            if count > '0':
                inFile = shpOutputDir + "/" + fc
                arcpy.RepairGeometry_management(inFile,"KEEP_NULL")
            myWrite(logFile, count + " wrong geometry\n")

            ## Create a List of fields to export
            inFile = shpOutputDir + "/" + fc         
            myWrite(logFile, "12 - Listing field from " + inFile + "...")
            ListsrcFields  = []        
            fieldslist = arcpy.ListFields(inFile)
            for f in fieldslist:
                if not (str(f.name) == "FID" or str(f.name) == "Shape" or str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI"):
                    ListsrcFields.append(str(f.name))
            srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
            for field in ListsrcFields:
                srcFields = srcFields + ";" + str(field)      
            myWrite(logFile, " Done\n")
            
            ## Export the file into csv
            myWrite(logFile, "13 - Exporting " + inFile + " to csv...")
            outFile = csvOutputDir + "/" + fname + ".csv"                
            arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
            myWrite(logFile, " Done\n")

            ## Delete fields except CAS_ID        
            inFile = shpOutputDir + "/" + fname +  ".shp"
            myWrite(logFile, "14 - Deleting all fields except CAS_ID from " + inFile )
            arcpy.DeleteField_management(inFile, srcFields[7:])
            myWrite(logFile, " Done\n")
            exportCount = str(arcpy.GetCount_management(inFile))
            sumExport = str(int(sumExport) + int(exportCount))
            
            inFile = shpOutputDir + "/" + fname + ".shp"
            outFile = shpidxOutputDir + "/" + fname + "_index.shp"
            myWrite(logFile, "15 - Dissolve " + inFile + " to create index...")
            arcpy.Dissolve_management(inFile, outFile)
            myWrite(logFile, " Done\n")

            ## Create a filename field and derive its value
            inFile = shpidxOutputDir + "/" + fname + "_index.shp"
            myWrite(logFile, "16 - Adding Field Filename to " + fname + "_index...")
            arcpy.AddField_management(inFile, "filename", "TEXT", 50)
            arcpy.CalculateField_management(inFile, "filename", "'" + fname + "'" ,"PYTHON")
            myWrite(logFile, " Done\n")

        except:                   
                myWrite(logFile, " ERROR\n")
                myWrite(logError, "Failed to process...\n")
                myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
                sys.exit()
            
    myWrite(logFile, "Sourcedataset geometry count = " + inputCount)
    myWrite(logFile, "\nGeometries exported = " + str(sumExport))


except:
    myWrite(logFile, " ERROR\n")
    myWrite(logError, "Failed to process...\n")
    myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
    myWrite(logMain, " Done\n")                      

timeStop = timeit.default_timer()
time = timeStop - timeStart     

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

#myWrite(logMain, "Done\n")                      
                         
## Erase Temp folder
if os.path.exists(tempOutputDir):
    shutil.rmtree(tempOutputDir)


    