-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create test translation tables
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Display translation tables
SELECT * FROM translation.qc_ini03_eco; 

-- Create subsets of translation tables if necessary
DROP TABLE IF EXISTS translation_devel.qc03_ini03_eco_devel;
CREATE TABLE translation_devel.qc03_ini03_eco_devel AS
SELECT * FROM translation.qc_ini03_eco;
--WHERE rule_id::int = 1;

-- display
SELECT * FROM translation_devel.qc03_ini03_eco_devel;

-- Create translation functions
SELECT TT_Prepare('translation_devel', 'qc03_ini03_eco_devel', '_qc03_eco_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'qc03', 1, 'qc_ini03', 1, 200);
SELECT * FROM TT_Translate_qc03_eco_devel('rawfri', 'qc03_l1_to_qc_ini03_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'qc03_ini03_eco_devel', 'qc03_l1_to_qc_ini03_l1_map_200');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
