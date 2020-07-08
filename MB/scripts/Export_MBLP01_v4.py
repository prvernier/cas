##-----------------------------------------------------------------------
#                Export MANITOBA_LOUISIANA PACIFIC AND PORCUPINE MOUNTAIN
##-----------------------------------------------------------------------


################################################################################
# The forest inventory of Louisiana Pacific (Duck_Mountain and Porcupine Mountain) are .e00 files that have been transformed into gdb format prior to the storage
# They are stored in a gdb called MB_LP and are respectively named "Duck_mountain" and "Porc_mountain" 
# 
# Each coverage supports many table attributes identified using the suffix "os" or "us". Duck have 5 attributes tables (duck.os, duck.us2, duck.us3, duck.us4, duck.us5)
# whereas porcupine have 4 (porcupine.os, porcupine.us2, porcupine.us3, porcupine.us4). Common field name between the tables is FORESTKEY
#
# To obtain the final CSV table holding all the attributes, we joined the coverage of each area to their respective attribute tables
#
################################################################################

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
InputDir = "H:/FRIs/MB/SourceDataset/NONGOV/LouisianaPacific/gdb"

## Name of the sourceFile
gdbName = "MB_LP.gdb"

## This is where we will output all the exported files. This folder should exists before launching the script.
outDirectory = workDir + "/MBLP/output"

## Set the source file containing the Canada Albers projection
projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "MB"

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId_Duck = 2  # Louisiana Pacific
HeaderId_Porc = 4  # Porcupine Mountain

"""
###############################################################
def mainAB(InputDir, outDirectory):
    if not os.path.exists(InputDir):
        return -1
    #reste du script

    return 0

if __name__ == "__mainMB__":
    main(sys.argv[1], sys.argv[2])
################################################################
"""
################################################################################
# Define the function to write the information about the processing into the textepad sheet, 
def myWrite(file, str):
    file.write(str)
    file.flush()
    
################################################################################
##-----------------------------------------------------------------------
# You  should not have to change anything below this line
##-----------------------------------------------------------------------

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
## PROCESS ON VEGETATION INVENTORY
##----------------------------------------
myWrite(logFile, "CASFRI V.00.04 - EXPORT MB Louisiana Pacific Vegetation Inventory\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n\n")

timeStart = timeit.default_timer()

## Create a temporary filegeodatabase
myWrite(logFile, "01 - Creating a gdb...") 
arcpy.CreateFileGDB_management(tempOutputDir, "MB.gdb")
myWrite(logFile, " Done\n")

## Create a list of the directories to process
env.workspace = InputDir + "/" + gdbName
fileList = arcpy.ListFeatureClasses("", "polygon")
for fileName in fileList:

    try:
        if fileName == "duck_mountain":
            HeaderId = HeaderId_Duck
            Photo_Year = 1998
            ## Count object
            DuckCount = str(arcpy.GetCount_management(fileName))

        if fileName == "porc_mountain":
            HeaderId = HeaderId_Porc
            Photo_Year = 2000   
            ## Count object
            PorcCount = str(arcpy.GetCount_management(fileName))

        ## Reproject in Canada Lambert
        myWrite(logFile, "\n" +  fileName + " \n")
        outFile = tempOutputDir + "/MB.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
        myWrite(logFile, "02 - Reproject" + fileName + " in Canada Albers Equal Conic ...")
        arcpy.Project_management(fileName, outFile, projection)
        myWrite(logFile, " Done\n")
        
        ## Check geometry 
        inFile = tempOutputDir + "/MB.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')
        outFile = checkgeoOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + "_CheckGeometry.dbf"
        myWrite(logFile, "03 - Checking geometry of " + inFile + "...")
        arcpy.CheckGeometry_management(inFile, outFile)
        myWrite(logFile, " Done\n")

        ## Calculate number of rows to create only shp files and csv files when data exist
        inFile = checkgeoOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0')  + "_CheckGeometry.dbf"
        myWrite(logFile, "04 - Repairing geometry of " + inFile + "...")
        count = str(arcpy.GetCount_management(inFile))
        if count == '0':
            arcpy.Delete_management(inFile)
        if count > '0':
            inFile = tempOutputDir + "/MB.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')          
            arcpy.RepairGeometry_management(inFile)
        myWrite(logFile, " Done\n")
        
        ## Create a CAS_ID field and derive its value
        inFile = tempOutputDir + "/MB.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0')   
        myWrite(logFile, "05 - Adding CAS_ID  and calculate its value ...")
        arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
        arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "-" + fileName.upper().rjust(15,'x') + "-' + str('T' +  str(!TWP!) + 'R' + str(!RGE!) + 'M' + str(!MER!)).rjust(10,'x') + '-' + str(!POLYNUM!).rjust(10,'0') + '-' + str(!OBJECTID!).rjust(7, '0')", "PYTHON")
        myWrite(logFile, " Done\n")

        ## Create a HEADER_ID field and set its value
        myWrite(logFile, "06 - Adding HEADER_ID  and calculate its value ...")
        arcpy.AddField_management(inFile, "HEADER_ID", "SHORT")
        arcpy.CalculateField_management(inFile, "HEADER_ID", HeaderId, "PYTHON")
        myWrite(logFile, " Done\n")
        
        ## Create a AREA field and derive its value
        myWrite(logFile, "07 - Adding Field AREA and calculate its value...")
        arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
        arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
        myWrite(logFile, " Done\n")
        
        ## Create a PERIMETER field and set its value
        myWrite(logFile, "08 - Adding Field PERIMETER and calculate its value...")    
        arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
        arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
        myWrite(logFile, " Done\n")
                
        ## Create a FeatureLayer to allow the join
        inFile = tempOutputDir + "/MB.gdb/" + prefixName + "_" + str(HeaderId).rjust(4, '0') 
        outFile = prefixName + "_" + str(HeaderId).rjust(4, '0') + "_layer" 
        myWrite(logFile, "09 - Making Feature Layer to join attribute tables ...")
        arcpy.MakeFeatureLayer_management(inFile, outFile)
        myWrite(logFile, " Done\n")
                                           
        env.workspace = InputDir + "/" + gdbName
        myWrite(logFile, "15 - Join attributes table from ...\n")
        tbls = arcpy.ListTables()
        for table in tbls:
            if table[:13] == fileName:
                inFile = InputDir + "/" + gdbName + "/" + str(table)
                outFile = str(table) + "_view"
                myWrite(logFile, "  " +  str(table) + "\n")
                arcpy.MakeTableView_management(inFile, outFile)
                arcpy.AddJoin_management(prefixName + "_" + str(HeaderId).rjust(4, '0') + "_layer","FORESTKEY", str(table) + "_view", "FORESTKEY", "KEEP_ALL")
                
        ## Create a fieldList that contain all the fieldnames
        outFile = tempOutputDir + "/MB.gdb/" + str(fileName) + "_merge"
        env.qualifiedFieldNames = False
        myWrite(logFile, "16 - Save joined attributes from " + str(fileName) + " ...")
        arcpy.CopyFeatures_management(prefixName + "_" + str(HeaderId).rjust(4, '0') + "_layer", outFile)
        myWrite(logFile, " Done\n")

        inFile = tempOutputDir + "/MB.gdb/" + str(fileName) + "_merge"
        myWrite(logFile, "17 - Creating a fieldList from " + inFile + "...")
        fieldslist = arcpy.ListFields(inFile)
        Listlayer  = []        
        for f in fieldslist:
            if not (str(f.name) == "OBJECTID" or str(f.name) == "Shape" or str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI" or str(f.name) =="Shape" or str(f.name) == "Shape_Area" or str(f.name) == "Shape_Length"):
                Listlayer.append(str(f.name))            
        srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
        for field in Listlayer:
            srcFields = srcFields + ";" + str(field)
        myWrite(logFile, " Done\n")

        ## Export the LP file into csv
        inFile =  tempOutputDir + "/MB.gdb/" + str(fileName) + "_merge"
        outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".csv"
        myWrite(logFile, "18 - Exporting " + inFile + " into CSV ...")
        arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
        myWrite(logFile, " Done\n")

        ##Cannot delete required field Shape_Area  ## Delete all fields except CAS_ID 
        myWrite(logFile, "19 - Deleting fields except CAS_ID from " + inFile )
        arcpy.DeleteField_management(inFile, srcFields[7:])
        myWrite(logFile, " Done\n")

        inFile = tempOutputDir + "/MB.gdb/" + str(fileName) + "_merge"
        outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
        myWrite(logFile, "20 - Copying geometries " + inFile + "...")
        arcpy.CopyFeatures_management(inFile, outFile)
        inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
        arcpy.DeleteField_management(inFile, "OBJECTID;Shape_leng;Shape_Area")
        myWrite(logFile, " Done\n")

        if fileName == "duck_mountain":
            DuckExport = str(arcpy.GetCount_management(inFile))
        if fileName == "porc_mountain":
            PorcExport = str(arcpy.GetCount_management(inFile))
     
        ## Add PhotoYear information
        inFile = tempOutputDir + "/MB.gdb/" + str(fileName) + "_merge"
        myWrite(logFile, "21 - Adding PhotoYear to " + inFile + "...")
        arcpy.AddField_management(inFile, "PhotoYear", "TEXT", 40)
        myWrite(logFile, " Done\n")
        myWrite(logFile, "22 - Calculating the value of the CAS_ID in " + inFile + "...")
        arcpy.CalculateField_management(inFile, "PhotoYear", "'" + str(Photo_Year) + "'", "PYTHON")
        myWrite(logFile, " Done\n")
                
        ## Export the LP file into csv
        inFile = tempOutputDir + "/MB.gdb/" + str(fileName) + "_merge"
        outFile = tempOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_photoyear.csv"
        myWrite(logFile, "23 - Exporting " + inFile + " into CSV ...")
        arcpy.ExportXYv_stats(inFile, "CAS_ID;PhotoYear","SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
        myWrite(logFile, " Done\n")
        
        ## Delete xcoord and ycoord field
        inFile = tempOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_photoyear.csv"
        outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_photoyear.csv"
        myWrite(logFile, "24 - Deleting coordinate attributes from " + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_photoyear.csv...")
        with open(inFile,"rb") as source:
            rdr= csv.reader( source, delimiter=';' )
            with open(outFile,"wb") as result:
                wtr= csv.writer( result, delimiter=';' )
                for r in rdr:
                    wtr.writerow( (r[2], r[3] ))
        myWrite(logFile, " Done\n")

        ## Create Spatial extent of the dataset       
        inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + ".shp"
        outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
        myWrite(logFile, "25 - Dissolve " + inFile + "...")
        arcpy.Dissolve_management(inFile, outFile)
        myWrite(logFile, " Done\n")

        ## Create a filename field and derive its value
        inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_index.shp"
        myWrite(logFile, "26 - Adding Field AREA to " + inFile + "...")
        arcpy.AddField_management(inFile, "filename", "TEXT", 50)
        arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0')+ "_mu'" ,"PYTHON")
        myWrite(logFile, " Done\n")

        arcpy.DeleteFeatures_management(prefixName + "_" + str(HeaderId).rjust(4, '0') + "_layer")
        
    except:
        myWrite(logFile, " Error\n")
        myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")

myWrite(logFile, "Done\n\n")
myWrite(logFile, "Sourcedataset geometry Duck Mountain count = " + DuckCount + "\n")
myWrite(logFile, "Geometries exported = " + DuckExport + "\n\n")
myWrite(logFile, "Sourcedataset geometry Porcupine Mountain count = " + PorcCount + "\n")
myWrite(logFile, "Geometries exported = " + PorcExport + "\n\n")


timeStop = timeit.default_timer()
time = timeStop - timeStart     

if os.path.exists(tempOutputDir):
    shutil.rmtree(tempOutputDir)

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

#myWrite(logMain, "Done\n")


    