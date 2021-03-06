SELECT * FROM translation.sk_sfv01_eco; 
DROP TABLE IF EXISTS translation_devel.sk03_sfv01_eco_devel;
CREATE TABLE translation_devel.sk03_sfv01_eco_devel AS SELECT * FROM translation.sk_sfv01_eco;
SELECT * FROM translation_devel.sk03_sfv01_eco_devel;
SELECT TT_Prepare('translation_devel', 'sk03_sfv01_eco_devel', '_sk03_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'sk03', 1, 'sk_sfv', 1, 200);
SELECT * FROM TT_Translate_sk03_eco_devel('rawfri', 'sk03_l1_to_sk_sfv_l1_map_200', 'ogc_fid');
-- SELECT * FROM TT_ShowLastLog('translation_devel', 'sk03_sfv01_eco_devel');
