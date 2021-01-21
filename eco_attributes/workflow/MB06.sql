SELECT * FROM translation.mb_fli01_eco; 
DROP TABLE IF EXISTS translation_devel.mb06_fli01_eco_devel;
CREATE TABLE translation_devel.mb06_fli01_eco_devel AS SELECT * FROM translation.mb_fli01_eco;
SELECT * FROM translation_devel.mb06_fli01_eco_devel;
SELECT TT_Prepare('translation_devel', 'mb06_fli01_eco_devel', '_mb06_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'mb06', 1, 'mb_fli', 1, 200);
SELECT * FROM TT_Translate_mb06_eco_devel('rawfri', 'mb06_l1_to_mb_fli_l1_map_200', 'ogc_fid');
