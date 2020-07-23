c:\bigsql\pg96\pg96-env.bat
pg_dump -U postgres cas > dbexport.pgsql
psql -U postgres cas < dbexport.pgsql
