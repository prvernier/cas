##-----------------------------------------------------------------------
#                Export BRITISH COLUMBIA_GOV
##-----------------------------------------------------------------------

##########################################################################
# This script has been written to export VRI British Columbia forest inventory provided by the BC governemnet downloaded on May 27, 2014 by Melina Houle
#
# The format of the SourceDataset of British Columbia is  a geodatabase  
# The geodatabase has been stored in a folder named SourceDataset
#
# British Columbia used 3 differents standards: VRI, FLI, I
# The information on the inventory standard is found in the "INVENTORY_STANDARD_CD" column
#
# The year of photography is included in the attributes table (REFERENCE_YEAR)
#
# This scirpt has been written for ArcGIS 10.1
##########################################################################

## Import the necessary modules
import sys, os, csv, shutil, os.path, arcpy, timeit, time
from arcpy import env

starttime = time.asctime( time.localtime(time.time()) )

## Set name of the person executing theexport script
Executer = "Pierre Vernier"

##Set the working directoy
#workDir= "H:/Melina/CAS"
workDir = "C:/Users/PIVER37/Documents/casfri/tmp"

## Set the source folder containing the source shapefiles (or Workspace)
#InputDir = "H:/FRIs/BC/SourceDataset/v.00.04/BCGOV"
InputDir = "C:/Users/PIVER37/Documents/casfri/FRIs/BC/SourceDataset/v.00.04/BCGOV"

## Name of the sourceFile
gdbName = "VEG_COMP_LYR_R1_POLY.gdb"

## Name of the table
tblName = "VEG_COMP_LYR_R1_POLY"

invName = "GOV"

## Set the destination folder where all the exported files will be placed. This folder should exists before launching the script.
outDirectory = workDir + "/BC/output"

## Set the source file containing the Canada Albers Equal Conic projection
#projection = "H:/CAS/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"
projection = "C:/Users/PIVER37/Documents/casfri/CAS_04/ExportedSourceFiles/Version.00.04/tools/CanadaAlbersEqualAreaConic.prj"

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

## Create a standard list
StandardList =  ['F','V','I']

## This is the unique number ID associated with the inventory. You must determine it using the HeaderInformation.csv file.
HeaderId_F = 4  # When INV_STD_CD column = F
HeaderId_V = 5  # When INV_STD_CD column = V
HeaderId_I = 6  # When INV_STD_CD column = I

## Prefix of the jurisdiction according to the CAS protocol
prefixName = "BC"


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

##----------------------------------------
## PROCESS BC GOV VEGETATION INVENTORY
##----------------------------------------

myWrite(logFile, "CASFRI V.00.04 - EXPORT BC_GOV 4inv\n")
myWrite(logFile, "Executer: " + Executer + "\n")
myWrite(logFile, "Export script data: " + starttime + "\n")

timeStart = timeit.default_timer()
               
try:
    
    myWrite(logMain, "BC ... ")
    inFile = InputDir + "/" + gdbName + "/" + tblName

    ## Count object
    inputCount = str(arcpy.GetCount_management(inFile))
    ## List all Tilemap 
    MapList = [u'082B', u'082C', u'082E'] #, u'082F', u'082G', u'082J', u'082K', u'082L', u'082M', u'082N', u'082O', u'083C', u'083D', u'083E', u'092A', u'092B', u'092C', u'092E', u'092F', u'092G', u'092H', u'092I', u'092J', u'092K', u'092L', u'092M', u'092N', u'092O', u'092P', u'093A', u'093B', u'093C', u'093D', u'093E', u'093F', u'093G', u'093H', u'093I', u'093J', u'093K', u'093L', u'093M', u'093N', u'093O', u'093P', u'094A', u'094B', u'094C', u'094D', u'094E', u'094F', u'094G', u'094H', u'094I', u'094J', u'094K', u'094L', u'094M', u'094N', u'094O', u'094P', u'095A', u'095B', u'102I', u'102O', u'102P', u'103A', u'103B', u'103C', u'103F', u'103G', u'103H', u'103I', u'103J', u'103K', u'103O', u'103P', u'104A', u'104B', u'104C', u'104F', u'104G', u'104H', u'104I', u'104J', u'104K', u'104L', u'104M', u'104N', u'104O', u'104P', u'114I', u'114O', u'114P']

    ## Create a temporary filegeodatabase
    myWrite(logFile, "01 - Creating a gdb...") 
    arcpy.CreateFileGDB_management(tempOutputDir, "BC_GOV.gdb")
    myWrite(logFile, " Done\n")
    
    layer = "BC"
    inFile = InputDir + "/" + gdbName + "/" + tblName
    myWrite(logFile, "02 - Making a layer from " + inFile + "...") 
    arcpy.MakeFeatureLayer_management(inFile,layer)
    myWrite(logFile, " Done\n")
    
    ## Split the shp into mapsheet to allow the process
    myWrite(logFile, "03 - Copying tilemap from " + inFile + ":") 
    
    for Map in MapList:
        myWrite(logFile, str(Map) + ", ") 
        ## Faire une selection a partir du layer selon les elements contenu dans la list
        arcpy.SelectLayerByAttribute_management(layer,"NEW_SELECTION", " \"MAP" + "\"= '" + Map + "'")        
        outFile = tempOutputDir + "/BC_GOV.gdb/" + prefixName + "_" + str(Map).upper()
        arcpy.CopyFeatures_management(layer, outFile)
        arcpy.SelectLayerByAttribute_management(layer, "CLEAR_SELECTION")
    myWrite(logFile, " Done\n")
    
    sumExport = '0'
    arcpy.env.workspace = tempOutputDir
    datasetList = arcpy.ListWorkspaces("*", "FileGDB")
    for dataset in datasetList:
        arcpy.env.workspace = dataset
        fcList = arcpy.ListFeatureClasses()
        for fc in fcList:
    
            try:          
                ## Check geometry
                mapid = fc.rsplit("_")[1]
                inFile = tempOutputDir + "/BC_GOV.gdb/" + fc
                outFile = checkgeoOutputDir + "/" + fc + ".dbf"
                myWrite(logFile, "04 - Checking geometry of " + inFile + "...")
                arcpy.CheckGeometry_management(inFile, outFile)
                myWrite(logFile, " Done\n")

                ## Calculate number of rows to create only shp files and csv files when data exist
                inFile = checkgeoOutputDir + "/" + fc + ".dbf"
                count = str(arcpy.GetCount_management(inFile))
                myWrite(logFile, "05 - Repairing geometry for " + count + " polygons:  ")
                if count == '0':
                    arcpy.Delete_management(inFile)
                if count > '0':
                    inFile = tempOutputDir + "/BC_GOV.gdb/" + fc
                    arcpy.RepairGeometry_management(inFile,"KEEP_NULL")
                myWrite(logFile, count + " wrong geometry\n")
            
                ## Create AREA field and set its value
                inFile = tempOutputDir + "/BC_GOV.gdb/" + fc
                myWrite(logFile, "06 - Adding Field AREA to " + inFile + "...")
                arcpy.AddField_management(inFile, "GIS_AREA", "DOUBLE","14","4")
                arcpy.CalculateField_management(inFile, "GIS_AREA", "(!shape.area@hectares!)","PYTHON")
                myWrite(logFile, " Done\n")

                ## Create PERIMETER field and set its value
                myWrite(logFile, "07 - Adding Field PERIMETER to " + inFile + "...")    
                arcpy.AddField_management(inFile, "GIS_PERI", "DOUBLE","10","1")
                arcpy.CalculateField_management(inFile, "GIS_PERI", "(!shape.length@meters!)","PYTHON")
                myWrite(logFile, " Done\n")

                myWrite(logFile, "08 - Adding Field HEADER to " + inFile + "...")  
                arcpy.AddField_management(inFile, "HEADER_ID", "TEXT", 40)
                myWrite(logFile, " Done\n")    
        
                ## Export following standard
                inFile = tempOutputDir + "/BC_GOV.gdb/" + fc
                arcpy.MakeFeatureLayer_management(inFile, "fl_" + mapid)
                
                for Standard in StandardList:
                    myWrite(logFile, "-" + Standard + "\n")            
                    ## Create the HEADER_ID value based on the standard  
                    if Standard == "F":
                        HeaderId = HeaderId_F
                    elif Standard == "V":
                        HeaderId = HeaderId_V
                    elif Standard == "I": 
                        HeaderId = HeaderId_I
                    try:
                        ## Select features based on the standard         
                        myWrite(logFile, "09 - Selecting layer by attribute of" + inFile + "...")           
                        arcpy.SelectLayerByAttribute_management ( "fl_" + mapid, "NEW_SELECTION",  " \"INVENTORY_STANDARD_CD" + "\"= '" + Standard + "'")
                        arcpy.CalculateField_management( "fl_" + mapid, "HEADER_ID", HeaderId, "PYTHON")
                        arcpy.SelectLayerByAttribute_management( "fl_" + mapid, "CLEAR_SELECTION")
                        myWrite(logFile, " Done\n")
                        
                    except:
                        myWrite(logFile, " ERROR\n")
                        myWrite(logError, "Failed to process...\n")
                        myWrite(logError, "Error message: "  + arcpy.GetMessage(2) + "\n")

                       
                ## Create a CAS_ID field and derive its value
                myWrite(logFile, "10 - Adding CAS_ID to " + inFile + " and derive its value...")
                arcpy.AddField_management("fl_" + mapid, "CAS_ID", "TEXT", 40)
                #arcpy.CalculateField_management("fl_" + mapid, "CAS_ID", "'" + prefixName + "_' + str(!HEADER_ID!).rjust(4, '0') + '-" + tblName[:15].upper() + "-' + str(!MAP_ID!).upper().rjust(10,'x') + '-' + str(!SOURCE_OBJECTID!).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
                arcpy.CalculateField_management("fl_" + mapid, "CAS_ID", "'" + prefixName + "_' + str(!HEADER_ID!).rjust(4, '0') + '-" + tblName[:15].upper() + "-' + str(!MAP_ID!).upper().rjust(10,'x') + '-' + str(!OBJECTID!).rjust(10, '0') + '-' + str(!OBJECTID!).rjust(7,'0')", "PYTHON")
                myWrite(logFile, " Done\n")

                   
                ## First List include fields from the coverage
                ListsrcFields = []
                myWrite(logFile, "11 - Creating a field List of  " + inFile + "...")
                flist = arcpy.ListFields("fl_" + mapid)
                for f in flist:
                    if not (str(f.name) == "CAS_ID" or str(f.name) == "HEADER_ID" or str(f.name) == "GIS_AREA" or str(f.name) == "GIS_PERI" or str(f.name) == "OBJECTID" or str(f.name) =="Shape" or str(f.name) == "Shape_Area" or str(f.name) == "Shape_Length"):
                        ListsrcFields.append(str(f.name))           
                    ## Begin de string with field that you add       
                srcFields = "CAS_ID;HEADER_ID;GIS_AREA;GIS_PERI"
                for field in ListsrcFields:
                    srcFields = srcFields + ";" + str(field)                
                myWrite(logFile, " Done\n")              
                           
                ## Export selected features into csv
                myWrite(logFile, "12 - Exporting " + inFile + " to csv...")
                outFile = csvOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + mapid + ".csv"
                arcpy.ExportXYv_stats("fl_" + mapid, srcFields, "SEMI-COLON" , outFile, "ADD_FIELD_NAMES")
                myWrite(logFile, " Done\n")

                #Cannot delete required field Shape_Area  ## Delete all fields excpet CAS_ID 
                myWrite(logFile, "13 - Deleting fields except CAS_ID from " + inFile )                
                arcpy.DeleteField_management("fl_" + mapid, srcFields[7:])
                myWrite(logFile, " Done\n")

                outFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + mapid + ".shp"
                myWrite(logFile, "14 - Exporting geometries...")
                arcpy.Project_management("fl_" + mapid, outFile, projection)
                inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + mapid + ".shp"
                arcpy.DeleteField_management(inFile, "OBJECTID;Shape_Area;Shape_Leng")
                myWrite(logFile, " Done\n")
                exportCount = str(arcpy.GetCount_management(inFile))
                sumExport = str(int(sumExport) + int(exportCount))

                inFile = shpOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + mapid + ".shp"
                outFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + mapid + "_index.shp"
                myWrite(logFile, "15 - Dissolve " + inFile + "...")
                arcpy.Dissolve_management(inFile, outFile)
                myWrite(logFile, " Done\n")

                ## Create a filename field and derive its value
                inFile = shpidxOutputDir + "/" + prefixName + "_" + str(HeaderId).rjust(4, '0') + "_" + mapid + "_index.shp"
                myWrite(logFile, "16 - Adding Field AREA to " + inFile + "...")
                arcpy.AddField_management(inFile, "filename", "TEXT", 50)
                arcpy.CalculateField_management(inFile, "filename", "'" + prefixName + "_" + mapid + "'" ,"PYTHON")
                myWrite(logFile, " Done\n")
                
                ## Delete FeatureLayer 
                myWrite(logFile, "17 - Deleting " +  mapid + "...")
                arcpy.Delete_management("fl_" + mapid,"FeatureLayer")         
                myWrite(logFile, " Done\n\n\n")           
            
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

myWrite(logMain, "Done\n")                      
                
#shutil.rmtree(tempOutputDir)
