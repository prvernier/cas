-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create test translation tables
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Display translation tables
SELECT * FROM translation.nl_nli01_eco; 

-- Create subsets of translation tables if necessary
DROP TABLE IF EXISTS translation_devel.nl01_nli01_eco_devel;
CREATE TABLE translation_devel.nl01_nli01_eco_devel AS
SELECT * FROM translation.nl_nli01_eco;
--WHERE rule_id::int = 1;

-- display
SELECT * FROM translation_devel.nl01_nli01_eco_devel;

-- Create translation functions
SELECT TT_Prepare('translation_devel', 'nl01_nli01_eco_devel', '_nl01_eco_devel');

-- Translate the samples nl01_l1_to_nl_nli_l1_map_200
SELECT TT_CreateMappingView('rawfri', 'nl01', 1, 'nl_nli', 1, 200);
SELECT * FROM TT_Translate_nl01_eco_devel('rawfri', 'nl01_l1_to_nl_nli_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nl01_eco_devel', 'nl01_l1_to_nl_nli_l1_map_200');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
