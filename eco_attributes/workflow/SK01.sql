-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create test translation tables
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Display translation tables
SELECT * FROM translation.sk_utm01_eco; 

-- Create subsets of translation tables if necessary
DROP TABLE IF EXISTS translation_devel.sk01_utm01_eco_devel;
CREATE TABLE translation_devel.sk01_utm01_eco_devel AS
SELECT * FROM translation.sk_utm01_eco;
--WHERE rule_id::int = 1;

-- display
SELECT * FROM translation_devel.sk01_utm01_eco_devel;

-- Create translation functions
SELECT TT_Prepare('translation_devel', 'sk01_utm01_eco_devel', '_sk01_eco_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'sk01', 1, 'sk_utm', 1, 200);

SELECT * FROM TT_Translate_sk01_eco_devel('rawfri', 'sk01_l1_to_sk_utm_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'sk01_utm01_eco_devel');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
