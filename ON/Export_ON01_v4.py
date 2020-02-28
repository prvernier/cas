

##-----------------------------------------------------------------------
#                Export ONTARIO_GOV
##-----------------------------------------------------------------------

##########################################################################
# This script has been written to export Ontario forest inventory provided in 2006 by the Ontario governemnt
#
# The inventory standard is FRI_FIM
#
# The format of the SourceDataset of Ontario is shapefile and it is split by management unit
# Each management unit has a folder bearing their respective name (ex: mu012)
# In each folder, you will find 2 different shapefiles (for0xx and mu0xxl) and an Access files where forest and nonforest attributes are found 
#
# To do the export, you will need to join the spatial polygon to the forest and nonforest attributes by using the field "RECNO" 
#
# The year of photography is included in the file. The name of the colunm is "YRUPD"
#
# ****If you run this script on Ontario forest inventory provided in 2006, you will need to run a shell program. Forest inventory provided in 2006 has typing mistake
#     that you will need to fix before executing the Perl script
#
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
InputDir = "H:/FRIs/ON/SourceDataset/Current"

## This is where we will output all the exported files. This folder should exists before launching the script.
outDirectory = workDir + "/ON/output"

## Set the source file containing the Canada Albers projection
projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "ON"

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId = 1

## Control floating point 
DecDic= {'AREA': 1,'PERIMETER': 1,'HECTARES': 1,'HA': 1,'HT': 1,'STKG': 1}

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
## PROCESS ON VEGETATION INVENTORY
##----------------------------------------
myWrite(logFile, "CASFRI V.00.04 - EXPORT YT Vegetation Inventory\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n")

timeStart = timeit.default_timer()

##Create a list of the directories to process
fcs = os.listdir(InputDir) 

## Create a temporary filegeodatabase
myWrite(logFile, "01 - Creating a gdb...") 
arcpy.CreateFileGDB_management(tempOutputDir, "ON.gdb")
myWrite(logFile, " Done\n")

for fc in fcs:
    ##Keep the first part of the name ([0]) as name of the directory. ex: t83.e00 become t83
    shortFileName = str(fc) + "l.shp"
    try:
        
        inFile = InputDir + "/" + fc + "/" + shortFileName
        ## Count object
        inputCount = str(arcpy.GetCount_management(inFile))
        
        ## Change the projection into Canada Lambert
        outFile = tempOutputDir + "/ON.gdb/" + str(fc).upper()
        myWrite(logFile, "02 - Projecting " + inFile + "into Canada Albers Equal Conic...")
        arcpy.Project_management(inFile, outFile, projection)
        myWrite(logFile, " Done\n")

        ## Check geometry and make
        inFile = tempOutputDir + "/ON.gdb/" + str(fc).upper() 
        outFile = tempOutputDir + "/" + fc + "_CheckGeometry.dbf"
        myWrite(logFile, "03 - Checking geometry of " + inFile + "...")
        arcpy.CheckGeometry_management(inFile, outFile)
        myWrite(logFile, " Done\n")

        ## Calculate number of rows to create only shp files and csv files when data exist
        inFile = tempOutputDir + "/" + fc + "_CheckGeometry.dbf"
        count = str(arcpy.GetCount_management(inFile))
        myWrite(logFile, "04 - Repairing geometry of for " + count + " polygons:")
        if count == '0':
            arcpy.Delete_management(inFile)
        if count > '0':
            inFile = tempOutputDir + "/ON.gdb/" + str(fc).upper()
            arcpy.RepairGeometry_management(inFile,"KEEP_NULL")
        myWrite(logFile, count + " wrong geometry\n")

        ## Create a CAS_ID field and derive its value
        inFile = tempOutputDir + "/ON.gdb/" + str(fc).upper() 
        myWrite(logFile, "05 - Adding CAS_ID to " + inFile + "...")
        arcpy.AddField_management(inFile, "CAS_ID", "TEXT", 40)
        arcpy.CalculateField_management(inFile, "CAS_ID", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "-" + str(shortFileName[:6]).upper().rjust(15,'x') + "-" + str(fc).upper().rjust(10,'x') + "-' + str(long(!RECNO!)).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
        myWrite(logFile, " Done\n")

        ## Create a HEADER_ID field and set its value
        myWrite(logFile, "06 - Adding HEADER_ID to " + inFile + "...")
        arcpy.AddField_management(inFile, "HEADER_ID", "SHORT")
        arcpy.CalculateField_management(inFile, "HEADER_ID", HeaderId, "PYTHON")
        myWrite(logFile, " Done\n")
 
        ## Create a AREA field and derive its value
        myWrite(logFile, "07 - Adding Field AREA to " + inFile + "...")
        arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
        arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
        myWrite(logFile, " Done\n")

        ## Create PERIMETER field and set its value
        myWrite(logFile, "08 - Adding Field PERIMETER to " + inFile + "...")    
        arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
        arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
        myWrite(logFile, " Done\n")
        
        ## Convert shp to a FeatureLayer to allow the join 
        inFile = tempOutputDir + "/ON.gdb/" + str(fc).upper()
        outFile = fc + "_layer"
        myWrite(logFile, "09 - Transforming " + inFile + " into " + outFile + " ...")
        arcpy.MakeFeatureLayer_management(inFile, outFile)
        myWrite(logFile, " Done\n")
        
        ## Create an outFile where the merge files will go
        outfc1 = tempOutputDir + "/ON.gdb/" + fc + "_merge"

        ## Identify the objects to merge 
        forest = InputDir + "/" + fc + "/shape_data_" + fc + ".mdb/tbl_forest_" + fc[2:]
        nonforest = InputDir + "/" + fc + "/shape_data_" + fc + ".mdb/tbl_nonfor_" + fc[2:]
        
        ## Merge the two access database table together. All the attributes will then be put in the same file
        myWrite(logFile, "10 - Merging tbl_forest_" + fc[2:] + "tbl_nonfor_" + fc[2:] + "...")
        arcpy.Merge_management([forest, nonforest], outfc1)
        myWrite(logFile, " Done\n")
        
        ## Create a TableView to allow the join                
        inFile = tempOutputDir + "/ON.gdb/"  + fc + "_merge"
        outFile = fc + "_view"
        myWrite(logFile, "11 - Transforming " + fc + "_merge into " + outFile + " ...")
        arcpy.MakeTableView_management(inFile, outFile)
        arcpy.AddIndex_management(fc + "_view","RECNO", fc + "_index")
        myWrite(logFile, " Done\n")
        
        ## Join the FeatureLayer and the TableView together
        env.qualifiedFieldNames = False
        myWrite(logFile, "12 - Joining " + fc + "_layer and " + fc + "_view...")
        arcpy.AddJoin_management(fc + "_layer", "RECNO", fc + "_view", "RECNO")
        myWrite(logFile, " Done\n")
        
        ## Export into FeatureClass        
        inFile = fc + "_layer"
        outFile = tempOutputDir + "/ON.gdb/"  + fc + "_final"
        myWrite(logFile, "13 - Converting " + inFile + "into shp...")
        arcpy.CopyFeatures_management(inFile, outFile)
        myWrite(logFile, " Done\n")

        ## Delete FeatureLayer 
        myWrite(logFile, "14 - Deleting " + fc + "_layer " + "...")
        arcpy.Delete_management(fc + "_layer","FeatureLayer")
        arcpy.Delete_management(fc + "_view")
        myWrite(logFile, " Done\n")
                      
        ## Create string of field to copy from SHP to CSV
        ## First List include fields from the coverage
        inFile = tempOutputDir + "/ON.gdb/"  + fc + "_final"
        myWrite(logFile, "15 - Creating a source fieldList from " + inFile + "...")
        Listlayer  = []        
        fieldslist = arcpy.ListFields(inFile)
        for f in fieldslist:
            if not (str(f.name) == "FID" or str(f.name) == "Shape" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI" or str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "OBJECTID" or str(f.name) =="Shape" or str(f.name) == "Shape_Area" or str(f.name) == "Shape_Length"):
                Listlayer.append(str(f.name))
        # Begin de string with field that you add       
        srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
        for field in Listlayer:
            srcFields = srcFields + ";" + str(field)
        myWrite(logFile, " Done\n")
        
        ## Export the ON file into csv
        outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + str(fc).upper() + ".csv"
        myWrite(logFile, "16 - Exporting " + inFile + " into .csv...")
        arcpy.ExportXYv_stats(inFile, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
        myWrite(logFile, " Done\n")
        
        ## Delete fields except CAS_ID        
        inFile = tempOutputDir + "/ON.gdb/"  + fc + "_final" 
        myWrite(logFile, "17 - Deleting from " + inFile + " all the unecessary field, except CAS_ID...")
        arcpy.DeleteField_management(inFile, srcFields[7:])
        myWrite(logFile, " Done\n")

        ## Rename the ON file 
        inFile = tempOutputDir + "/ON.gdb/"  + fc + "_final"
        outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + str(fc).upper() + ".shp"
        myWrite(logFile, "18 - Renaming " + inFile + "...")
        arcpy.CopyFeatures_management(inFile, outFile)
        arcpy.DeleteField_management(outFile, "OBJECTID;Shape_Area;Shape_Length;Shape_Leng")
        myWrite(logFile, " Done\n")
                    
        inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + str(fc).upper() + ".shp"
        exportCount = str(arcpy.GetCount_management(inFile))
        outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + str(fc).upper() + "_index.shp"
        myWrite(logFile, "18 - Dissolve " + inFile + "...")
        arcpy.Dissolve_management(inFile, outFile)
        myWrite(logFile, " Done\n")
        
        ## Create a filename field and derive its value
        inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') +  "_" + str(fc).upper() + "_index.shp"
        myWrite(logFile, "19 - Adding Field filename to " + fc + "_index...")
        arcpy.AddField_management(inFile, "filename", "TEXT", 50)
        arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + fc + "'" ,"PYTHON")
        myWrite(logFile, " Done\n\n")
                              
    except:
        myWrite(logFile, " ERROR\n")
        myWrite(logError, "Failed to process...\n")
        myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")
        sys.exit()

    myWrite(logFile, "Sourcedataset geometry count = " + inputCount)
    myWrite(logFile, "\nGeometries exported = " + str(exportCount) + "\n")


timeStop = timeit.default_timer()
time = timeStop - timeStart     

myWrite(logFile, "\nTime to process Export = " + str(time/60) + " minutes\n")

#myWrite(logMain, "Done\n")                      
                
shutil.rmtree(tempOutputDir)




