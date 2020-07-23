--SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--SELECT * FROM rawfri.ab06 LIMIT 10;
--SELECT count(*) FROM rawfri.ab06;

DROP TABLE If EXISTS translation.ab06_avi01_lyr;
CREATE TABLE translation.ab06_avi01_lyr (
    rule_id serial primary key,
    targetattribute varchar,
    targetattributetype varchar,
    validationrules varchar,
    translationrules varchar,
    description varchar,
    descuptodatewithrules varchar
);

COPY translation.ab06_avi01_lyr (rule_id, targetattribute, targetattributetype, validationrules, translationrules, description, descuptodatewithrules)
    FROM 'C:\Users\PIVER37\Documents\github\casfri\translation\tables\ab06_avi01_lyr.csv' DELIMITER ',' CSV HEADER;
--SELECT * FROM translation.ab06_avi01_lyr;

-- Create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.ab06_test;
CREATE TABLE rawfri.ab06_test AS SELECT * FROM rawfri.ab06 LIMIT 200; --WHERE ogc_fid = 2;
--SELECT src_filename, trm_1, poly_num, ogc_fid, density, height, sp1, sp1_per FROM rawfri.ab06_test;

-- Work on translation file; Display the translation table of interest
--SELECT * FROM translation.ab06_avi01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.ab06_avi01_lyr_test;
CREATE TABLE translation.ab06_avi01_lyr_test AS SELECT * FROM translation.ab06_avi01_lyr WHERE rule_id>0;
--SELECT * FROM translation.ab06_avi01_lyr_test;

-- Translate the sample table! Create translation function
SELECT TT_Prepare('translation', 'ab06_avi01_lyr_test', '_ab06');

-- Translate the sample!
SELECT * FROM TT_Translate_ab06('rawfri', 'ab06_test', 'translation', 'ab06_avi01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
--SELECT src_filename, trm_1, poly_num, ogc_fid, cas_id, moist_reg, soil_moist_reg, struc_val, structure_per,
--    layer, layer_rank, density, crown_closure_lower, crown_closure_upper, height, height_upper, height_lower, 
--    productive_for, sp1, species_1, sp1_per, species_per_1, origin, origin_lower, origin_upper, tpr, site_class, site_index
--    INTO TEMP ab06_tmp
--    FROM TT_Translate_ab06('rawfri', 'ab06_test', 'translation', 'ab06_avi01_lyr_test'), rawfri.ab06_test
--    WHERE poly_num = substr(cas_id, 33, 10)::int;

--COPY ab06_tmp TO 'C:\Users\PIVER37\Documents\github\casfri\vernier\output\ab06\test_ab06.csv' DELIMITER ',' CSV HEADER;


-- Create translation function
--SELECT TT_Prepare('translation', 'ab06_avi01_lyr', '_ab06');

-- Translate complete table!
--DROP TABLE IF EXISTS casfri50.ab06;
--CREATE TABLE casfri50.ab06 AS SELECT * FROM TT_Translate_ab06('rawfri', 'ab06', 'translation', 'ab06_avi01_lyr');
--SELECT * FROM casfri50.ab06 LIMIT 10;

--COPY casfri50.ab06 TO 'C:\Users\PIVER37\Documents\github\casfri\vernier\output\casfri50_ab06.csv' DELIMITER ',' CSV HEADER;
