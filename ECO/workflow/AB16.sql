-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create test translation tables
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Display translation tables
SELECT * FROM translation.ab_avi01_eco; 

-- Create subsets of translation tables if necessary
DROP TABLE IF EXISTS translation_devel.ab16_avi01_eco_devel;
CREATE TABLE translation_devel.ab16_avi01_eco_devel AS
SELECT * FROM translation.ab_avi01_eco;
--WHERE rule_id::int = 1;

-- display
SELECT * FROM translation_devel.ab16_avi01_eco_devel;

-- Create translation functions
SELECT TT_Prepare('translation_devel', 'ab16_avi01_eco_devel', '_ab16_eco_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'ab16', 1, 'ab', 1, 200);
SELECT * FROM TT_Translate_ab16_eco_devel('rawfri', 'ab16_l1_to_ab_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ab16_avi01_eco_devel', 'ab16_l1_to_ab_l1_map_200');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
