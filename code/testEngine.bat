:: Create database, import inventories from AB, BC, and NB
:: PV 2019-04-30

:: Set the environment and start PostgreSQL 96
c:\bigsql\pg96\pg96-env.bat
::c:\bigsql\pgc start pg96

:: Start psql
::psql -U postgres -d cas -h localhost

:: Create database, extension, and schema
::createdb -h localhost -U postgres cas
::psql -h localhost -U postgres -d cas -c "create extension postgis"
::psql -h localhost -U postgres -d cas -c "create schema rawfri"

:: Convert sql files to get rid of strange characters
PowerShell -Command "Get-Content .\..\..\postTranslationEngine\engine.sql | Set-Content -Encoding String tt_engine\engine.sql"
PowerShell -Command "Get-Content .\..\..\postTranslationEngine\engineTest.sql | Set-Content -Encoding String tt_engine\engineTest.sql"
PowerShell -Command "Get-Content .\..\..\postTranslationEngine\engineUninstall.sql | Set-Content -Encoding String tt_engine\engineUninstall.sql"
PowerShell -Command "Get-Content .\..\..\postTranslationEngine\helperFunctions.sql | Set-Content -Encoding String tt_engine\helperFunctions.sql"
PowerShell -Command "Get-Content .\..\..\postTranslationEngine\helperFunctionsTest.sql | Set-Content -Encoding String tt_engine\helperFunctionsTest.sql"
PowerShell -Command "Get-Content .\..\..\postTranslationEngine\helperFunctionsUninstall.sql | Set-Content -Encoding String tt_engine\helperFunctionsUninstall.sql"

:: Re-install and test translation engine and helper functions
psql -U postgres -d cas -f tt_engine\engineUninstall.sql
psql -U postgres -d cas -f tt_engine\engine.sql
psql -U postgres -d cas -f tt_engine\helperFunctionsUninstall.sql
psql -U postgres -d cas -f tt_engine\helperFunctions.sql
psql -U postgres -d cas -f tt_engine\helperFunctionsTest.sql
psql -U postgres -d cas -f tt_engine\engineTest.sql

:: Run sql file and save output e.g., ab_0006
::psql -U postgres -d cas -f test_ab06.sql > output\test_ab06.txt
::psql -U postgres -d cas -f test_ab16.sql > output\test_ab16.txt
psql -U postgres -d cas -f bc08\test_bc08_cas.sql > bc08\test_bc08_cas.txt
psql -U postgres -d cas -f bc08\test_bc08_lyr.sql > bc08\test_bc08_lyr.txt
psql -U postgres -d cas -f bc08\test_bc08_nfl.sql > bc08\test_bc08_nfl.txt
psql -U postgres -d cas -f bc08\test_bc08_dst.sql > bc08\test_bc08_dst.txt
psql -U postgres -d cas -f bc08\test_bc08_eco.sql > bc08\test_bc08_eco.txt
::psql -U postgres -d cas -f test_nb01.sql > output\test_nb01.txt
