

##-----------------------------------------------------------------------
#                Export MANITOBA_GOV update
##-----------------------------------------------------------------------

##########################################################################
# This script has been written to export MB GOV forest inventory provided by the MB governemnet
# The attributes of the forest inventory of Manitoba gov are stored in a geodatabase
# The information on the inventory standard is found in the "FRI_FLI" column

# The year of photography is included in the attributes table (YEAR_PHOTO)
# This scirpt has been written for ArcGIS 10.1
# The Geoprocessing Check Geometry/Repair Geometry has been process on the Source Inventories and do not need to be perform here.
##########################################################################

## Import the necessary modules
import arcgisscripting, sys, os, csv, shutil, zipfile, os.path, zlib, arcpy, timeit, time
from arcpy import env

starttime = time.asctime( time.localtime(time.time()) )

## Create a geoprocessing object
gp = arcgisscripting.create(9.3)

## Set name of the person executing theexport script
Executer = "Melina Houle"

##Set the working directoy
workDir= "H:/Melina/CAS"

## Set the source folder containing the source shapefiles (or Workspace)
InputDir = "H:/FRIs/MB/SourceDataset/GOV/v.00.04"
#InputDir = "H:/Melina/CAS/MBGov"

## Name of the sourceFile
gdbName = "MFAGeodatabase.gdb"

## Name of the table
tblName = "MB_FRIFLI_Updatedto2010FINAL_v6"

invName = "GOV"

## This is where we will output all the exported files. This folder should exists before launching the script.
outDirectory = workDir + "/MBGov/output"

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

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId_FRI = 5  # When FRI_FLI column = FRI
HeaderId_FLI = 6  # When FRI_FLI column = FLI

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "MB"

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

myWrite(logFile, "CASFRI V.00.04 - EXPORT MB_GOV 4inv\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n\n")

timeStart = timeit.default_timer()

sumExport = 0

try:
    
    myWrite(logMain, "MB GOV ... ")
    inFile = InputDir + "/" + gdbName + "/" + tblName

    ## Count object
    inputCount = str(arcpy.GetCount_management(inFile))

    ## Create a temporary filegeodatabase
    myWrite(logFile, "01 - Creating a gdb...") 
    arcpy.CreateFileGDB_management(tempOutputDir, "MB_GOV.gdb")
    myWrite(logFile, " Done\n")

    ## Change projection
    inFile = InputDir + "/" + gdbName + "/" + tblName
    outFile = tempOutputDir + "/MB_GOV.gdb/" + prefixName 
    myWrite(logFile, "02 - Change projection to Canada Albers Equal Conic ...") 
    arcpy.Project_management(inFile, outFile, projection)
    myWrite(logFile, " Done\n")
    
    ## Create a AREA field and derive its value
    inFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName 
    myWrite(logFile, "03 - Adding Field AREA to " + inFile + "...")
    arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
    arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
    myWrite(logFile, " Done\n")
    
    ## Create a PERIMETER field and set its value in hectare
    myWrite(logFile, "04 - Adding Field PERIMETER to " + inFile + "...")    
    arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
    arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
    myWrite(logFile, " Done\n")

    ## Add HEADER_ID and CAS_ID
    myWrite(logFile, "05 - Adding Field CAS_DID and HEADER_ID to " + inFile + "...")    
    arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
    arcpy.AddField_management(inFile, "HEADER_ID", "SHORT")
    myWrite(logFile, " Done\n")
    
    layer = "MB"
    inFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName 
    myWrite(logFile, "06 - Making a layer from " + inFile + "...") 
    arcpy.MakeFeatureLayer_management(inFile,layer)
    myWrite(logFile, " Done\n")
    
    ## First List include fields from the coverage
    ListsrcFields = []
    myWrite(logFile, "07 - Creating a field List of  " + layer + "...")
    flist = arcpy.ListFields(layer)
    for f in flist:
        if not (str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI" or str(f.name) == "OBJECTID" or str(f.name) =="Shape" or str(f.name) == "Shape_Area" or str(f.name) == "Shape_Length"):
            ListsrcFields.append(str(f.name))           
        ## Begin de string with field that you add       
    srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
    for field in ListsrcFields:
        srcFields = srcFields + ";" + str(field)                
    myWrite(logFile, " Done\n")              
    
    StandradList =['FRI', 'FLI']
    for standard in StandradList:
        if standard == "FRI":
            HeaderId = HeaderId_FRI
        if standard == "FLI":
            HeaderId = HeaderId_FLI

        try:  
            ## Create a HEADER_ID field and set its value
            myWrite(logFile, "\n" + standard + "\n")
            arcpy.SelectLayerByAttribute_management(layer,"NEW_SELECTION", " \"FRI_FLI" + "\"= '" + standard + "'")
            myWrite(logFile, "08 - Calculate HEADER_ID for standard ...")
            arcpy.CalculateField_management( layer, "HEADER_ID", HeaderId, "PYTHON")
            myWrite(logFile, " Done\n")
            myWrite(logFile, "09 - Calculate CAS_ID...")
            arcpy.CalculateField_management(layer, "CAS_ID", "'" + prefixName + "_' + str(!HEADER_ID!).rjust(4, '0') + '-" + gdbName.rsplit(".")[0].rjust(15,'x') + "-' + str(int(!MU_ID!)).rjust(10,'x') + '-' + str(!FID_MB_FRI_v11_Updatedto2010FINALErased!).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
            myWrite(logFile, " Done\n")

            ## Save polygon as shp
            outFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName + "_" + str(HeaderId).rjust(4, '0')
            myWrite(logFile, "10 - Make a copy of the geometries with " + standard + " standard...")
            arcpy.CopyFeatures_management(layer, outFile)
            arcpy.SelectLayerByAttribute_management(layer, "CLEAR_SELECTION")
            myWrite(logFile, " Done\n")

            inFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName + "_" + str(HeaderId).rjust(4, '0')
            field = "MU_ID"
            muid = [row[0] for row in arcpy.da.SearchCursor(layer, (field))]
            unique_muid = set(muid)
            list_muid = sorted(unique_muid)
            lyr = "fri"
            myWrite(logFile, "11 - Making a layer from " + inFile + "...") 
            arcpy.MakeFeatureLayer_management(inFile,lyr)
            myWrite(logFile, " Done\n")

            for mu in list_muid:
                myWrite(logFile, "\nMU_ID" + str(int(mu)) + "\n")
                arcpy.SelectLayerByAttribute_management(lyr,"NEW_SELECTION", '\"MU_ID\" = {}'.format(mu))
                myWrite(logFile, "  12 - Check if " + str(int(mu)) + " geometries exist...")
                outFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0')
                arcpy.CopyFeatures_management(lyr, outFile)
                arcpy.SelectLayerByAttribute_management(lyr, "CLEAR_SELECTION")
                inFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0')
                count = str(arcpy.GetCount_management(inFile))
                myWrite(logFile, count + " geometries\n")

                if count > '0':
                    outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + ".csv"
                    myWrite(logFile, "  13 - Exporting attributes from " + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + "...")
                    arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
                    myWrite(logFile, " Done\n")
                     
                    ##Cannot delete required field Shape_Area  ## Delete all fields except CAS_ID 
                    myWrite(logFile, "  14 - Deleting fields except CAS_ID from " + inFile )
                    arcpy.DeleteField_management(inFile, srcFields[7:])
                    myWrite(logFile, " Done\n")

                    inFile = tempOutputDir + "/MB_GOV.gdb/" +  prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0')
                    outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + ".shp"
                    myWrite(logFile, "  15 - Copying geometries " + inFile + "...")
                    arcpy.CopyFeatures_management(inFile, outFile)
                    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + ".shp"
                    arcpy.DeleteField_management(inFile, "OBJECTID;Shape_leng;Shape_Area")
                    myWrite(logFile, " Done\n")
                    """
                    inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + ".shp"
                    exportCount = str(arcpy.GetCount_management(inFile))
                    sumExport = str(int(sumExport) + int(exportCount))
                    outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + "_index.shp"
                    myWrite(logFile, "  16 - Dissolve " + inFile + "...")
                    arcpy.Dissolve_management(inFile, outFile)
                    myWrite(logFile, " Done\n")

                    ## Create a filename field and derive its value
                    inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_mu" + str(int(mu)).rjust(2, '0') + "_index.shp"
                    myWrite(logFile, "  17 - Adding Field AREA to " + inFile + "...")
                    arcpy.AddField_management(inFile, "filename", "TEXT", 50)
                    arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0')+ "_mu" + str(int(mu)).rjust(2, '0') + "'" ,"PYTHON")
                    myWrite(logFile, " Done\n")
                    """
        except:
            myWrite(logFile, " ERROR\n")
            myWrite(logError, "Failed to process...\n")
            myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
            sys.exit()
            

    ## Delete FeatureLayer 
    myWrite(logFile, "\nDeleting Feature Layers...")
    arcpy.Delete_management(layer,"FeatureLayer")
    arcpy.Delete_management(lyr,"FeatureLayer") 
    myWrite(logFile, " Done\n\n\n")           

except:
    myWrite(logFile, " ERROR\n")
    myWrite(logError, "Failed to process...\n")
    myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
    myWrite(logMain, " Done\n")                      

myWrite(logFile, "Sourcedataset geometry count = " + inputCount)
myWrite(logFile, "\nGeometries exported = " + str(sumExport))

timeStop = timeit.default_timer()
time = timeStop - timeStart     

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

#myWrite(logMain, "Done\n")                      
    
#shutil.rmtree(tempOutputDir)
      
