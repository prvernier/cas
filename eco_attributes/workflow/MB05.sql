SELECT * FROM translation.mb_fri01_eco; 
DROP TABLE IF EXISTS translation_devel.mb05_fri01_eco_devel;
CREATE TABLE translation_devel.mb05_fri01_eco_devel AS SELECT * FROM translation.mb_fri01_eco;
SELECT * FROM translation_devel.mb05_fri01_eco_devel;
SELECT TT_Prepare('translation_devel', 'mb05_fri01_eco_devel', '_mb05_eco_devel');
SELECT TT_CreateMappingView('rawfri', 'mb05', 1, 'mb_fri', 1, 200);
SELECT * FROM TT_Translate_mb05_eco_devel('rawfri', 'mb05_l1_to_mb_fri_l1_map_200', 'ogc_fid');
