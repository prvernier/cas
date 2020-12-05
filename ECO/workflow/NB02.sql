-- No not display debug messages.
SET tt.debug TO TRUE;
SET tt.debug TO FALSE;

-- Translate the samples (reusing NB01 translation functions prepared by NB01.sql)
SELECT TT_CreateMappingView('rawfri', 'nb02', 1, 'nb', 1, 200);
SELECT * FROM TT_Translate_nb01_eco_devel('rawfri', 'nb02_l1_to_nb_l1_map_200', 'ogc_fid'); -- 2 s.
SELECT * FROM TT_ShowLastLog('translation_devel', 'nb01_nbi01_eco_devel');

-- Delete log files
SELECT TT_DeleteAllLogs('translation_devel');
