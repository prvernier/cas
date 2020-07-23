:: Create database, import inventories from AB, BC, and NB
:: PV 2019-11-15

:: Set the environment and start PostgreSQL 96
::c:\bigsql\pg96\pg96-env.bat
::c:\bigsql\pgc start pg96

:: Start psql
::psql -U postgres -d cas -h localhost

:: Create database, extension, and schema
::createdb -h localhost -U postgres cas
::psql -h localhost -U postgres -d cas -c "create extension postgis"
::psql -h localhost -U postgres -d cas -c "create schema rawfri"

SET path=C:\Program Files\PostgreSQL\11\bin
SET PGPASSWORD=1postgres

:: Uninstall, install and test translation engine and helper functions
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\engineUninstall.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\helperFunctionsUninstall.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\helperFunctionsGISUninstall.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\engine.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\helperFunctions.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\helperFunctionsGIS.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\engineTest.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\helperFunctionsTest.sql
psql -U postgres -d casfri50_pierrev -f .\..\..\PostgreSQL-Table-Translation-Framework\helperFunctionsGISTest.sql
psql -U postgres -d casfri50_pierrev -f ..\helperfunctions\helperFunctionsCasfriUninstall.sql
psql -U postgres -d casfri50_pierrev -f ..\helperfunctions\helperFunctionsCASFRI.sql
psql -U postgres -d casfri50_pierrev -f ..\helperfunctions\helperFunctionsCASFRITest.sql

:: Drop and load tables
psql -U postgres -d casfri50_pierrev -f ..\translation\drop_tables.sql
..\translation\load_tables.bat

:: Run sql file and save output
::psql -U postgres -d cas -f ..\workflow\01_test\NT01.sql > temp\NT01.txt
::psql -U postgres -d cas -f ..\workflow\01_test\NT02.sql > temp\NT02.txt
