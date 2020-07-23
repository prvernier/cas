--SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--SELECT * FROM rawfri.ab16 LIMIT 10;
--SELECT count(*) FROM rawfri.ab16;

DROP TABLE If EXISTS translation.ab16_avi01_lyr;
CREATE TABLE translation.ab16_avi01_lyr (
    rule_id serial primary key,
    targetattribute varchar,
    targetattributetype varchar,
    validationrules varchar,
    translationrules varchar,
    description varchar,
    descuptodatewithrules varchar
);
COPY translation.ab16_avi01_lyr (rule_id, targetattribute, targetattributetype, validationrules, translationrules, description, descuptodatewithrules)
    FROM 'C:\Users\PIVER37\Documents\github\casfri\translation\tables\ab16_avi01_lyr.csv' DELIMITER ',' CSV HEADER;
--SELECT * FROM translation.ab16_avi01_lyr;

-- Create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.ab16_test;
CREATE TABLE rawfri.ab16_test AS SELECT * FROM rawfri.ab16 LIMIT 200; --WHERE ogc_fid = 2
--SELECT crownclose, height, sp1, sp1_percnt FROM rawfri.ab16_test;

-- Work on translation file; Display the translation table of interest
--SELECT * FROM translation.ab16_avi01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.ab16_avi01_lyr_test;
CREATE TABLE translation.ab16_avi01_lyr_test AS SELECT * FROM translation.ab16_avi01_lyr WHERE rule_id>0;
--SELECT * FROM translation.ab16_avi01_lyr_test;

-- Translate the sample table! Create translation function
SELECT TT_Prepare('translation', 'ab16_avi01_lyr_test', '_ab16');

-- Translate the sample!
SELECT * FROM TT_Translate_ab16('rawfri', 'ab16_test', 'translation', 'ab16_avi01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
--SELECT src_filename, forest_id_2, ogc_fid, cas_id, moisture, soil_moist_reg, std_struct, structure_per,
--    layer, layer_rank, crownclose, crown_closure_lower, crown_closure_upper, height, height_upper, height_lower, 
--    productive_for, sp1, species_1, sp1_percnt, species_per_1, origin, origin_lower, origin_upper, tpr, site_class, site_index
--    FROM TT_Translate_ab16('rawfri', 'ab16_test', 'translation', 'ab16_avi01_lyr_test'), rawfri.ab16_test;
--    --WHERE poly_num = substr(cas_id, 33, 10)::int;

-- Translate complete table!
--DROP TABLE IF EXISTS casfri50.ab16;
--CREATE TABLE casfri50.ab16 AS SELECT * FROM TT_Translate_ab16('rawfri', 'ab16', 'translation', 'ab16_avi01_lyr_test');
--SELECT * FROM casfri50.ab16 LIMIT 10;
