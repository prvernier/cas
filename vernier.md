# WORKFLOW TO TEST ONE INVENTORY

Updated by PV on 2020-01-09

We'll use the BC10 inventory as an example.


## STEP 1 - PULL LATEST REPOSITORIES (IF CHANGED)

Make sure you have the latest versions of the GitHub repositories:

  - pull CASFRI
  - pull PostgreSQL-Table-Translation-Framework


## STEP 2 - CONVERT INVENTORY TO POSTGRESQL

Make sure a conversion script exists and run it at the windows or bash command line:

  > load_bc10.bat
  > sh load_bc10.sh

Check that the table has been created in PostgreSQL.


## STEP 3 - UPDATE TT ENGINE (IF NEEDED)

Update engine:
  - DROP EXTENSION table_translation_framework CASCADE;
  - Copy the configSample.bat (or the configSample.sh) file to config.bat (or config.sh) and edit it to set the path to your version of PostgreSQL.
  - Open a shell and CD to this folder.
  - Run install.bat (or install.sh). This will install the framework as a PostgreSQL extension. (ONLY DO THIS ONCE)
  - In a postgreSQL query tool window do: CREATE EXTENSION table_translation_framework;

## STEP 4 - UPDATE HELPER FUNCTIONS (IF NEEDED)

The helper functions should be re-installed if the engine has been updated (step 3), even if the helper functions have not changed. Update CASFRI helper functions by opening and running the following scripts in a postgreSQL query tool window:
  
  -  helperFunctionsCasfriUninstall.sql
  -  helperFunctionsCasfri.sql
  -  helperFunctionsCasfriTest.sql


## STEP 5 - DROP AND LOAD TRANSLATION TABLES

Load and run the following SQL script:
  - drop_tables.sql

Run the following script:
  - load_tables.bat or load_tables.sh


## STEP 5 - CREATE AN INVENTORY-SPECIFIC WORKFLOW SCRIPT

Make a copy of an existing script (e.g., rename BC09.sql to BC10.sql) and modify for focal inventory.


## STEP 6 - LOAD AND RUN THE WORKFLOW SCRIPT

Load the script and run section at a time, making changes as necessary. Eventually, run the entire script in one shot.


## STEP 7 - RUN PRODUCTION SCRIPT TO UPDATE CAS

Open and run the scripts (located in "02_produceCASFRI") in a postgreSQL query tool window:

  - 01_hdr.sql
  - 02_cas.sql
  - 03_dst.sql
  - 04_eco.sql
  - 05_lyr.sql
  - 06_nfl.sql
  - 07_geo.sql


## STEP 8 - TEST CHANGES

Do this each time you've made a change in a table or script:

  - run load_test_tables.bat or load_test_tables.sh
  - (edit) and run testTranslation.sql
  - run dump_test_tables.bat or dump_test_tables.sh
  - view changes (differences) in GitHub Desktop (or GitKraken)
  

## STEP 9 - VIEW FRI AND CAS TABLES

Use R dfSummary on source and translated tables e.g.:
	* -9999 was assigned to stand_structure when it's a text attribute
	* there are 57 TRANSLATION_ERROR for stand_structure
	* there are 57 TRANSLATION_ERROR for num_of_layers. (Currently being revisited by Mark)
	* many NOT_IN_SET. Many of them should probably be added to the validation rules
	* dist_year_1,2,3 shows 0s and other very stange values
	* some strange 0% species_pct and crown_closure_upper
	* should not structure_per be a true percentage?
	* some overprecise height_upper and height_lower
