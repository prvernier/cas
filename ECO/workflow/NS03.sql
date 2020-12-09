-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Create test translation tables
CREATE SCHEMA IF NOT EXISTS translation_devel;

-- Display translation tables
SELECT * FROM translation.ns_nsi01_eco; 

-- Create subsets of translation tables if necessary
DROP TABLE IF EXISTS translation_devel.ns03_nsi01_eco_devel;
CREATE TABLE translation_devel.ns03_nsi01_eco_devel AS
SELECT * FROM translation.ns_nsi01_eco;
--WHERE rule_id::int = 1;

-- display
SELECT * FROM translation_devel.ns03_nsi01_eco_devel;

-- Create translation functions
SELECT TT_Prepare('translation_devel', 'ns03_nsi01_eco_devel', '_ns03_eco_devel');

-- Translate the samples ns03_l1_to_ns_nsi_l1_map_200
SELECT TT_CreateMappingView('rawfri', 'ns03', 1, 'ns_nsi', 1, 200);
SELECT * FROM TT_Translate_ns03_eco_devel('rawfri', 'ns03_l1_to_ns_nsi_l1_map_200', 'ogc_fid'); -- 7 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'ns03_eco_devel', 'ns03_l1_to_ns_nsi_l1_map_200');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
