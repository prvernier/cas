-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create test translation tables
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Display translation tables
SELECT * FROM translation.bc_vri01_eco; 

-- Create subsets of translation tables if necessary
DROP TABLE IF EXISTS translation_devel.bc08_vri01_eco_devel;
CREATE TABLE translation_devel.bc08_vri01_eco_devel AS
SELECT * FROM translation.bc_vri01_eco;
--WHERE rule_id::int = 1;

-- display
SELECT * FROM translation_devel.bc08_vri01_eco_devel;

-- Create translation functions
SELECT TT_Prepare('translation_devel', 'bc08_vri01_eco_devel', '_bc08_eco_devel');

-- Translate the samples
SELECT TT_CreateMappingView('rawfri', 'bc08', 1, 'bc', 1, 200);
SELECT * FROM TT_Translate_qc03_eco_devel('rawfri', 'bc08_l1_to_bc_vri01_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'bc08_vri01_eco_devel', 'bc08_l1_to_bc_vri01_l1_map_200');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
