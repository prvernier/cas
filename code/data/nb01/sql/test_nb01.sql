--SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--SELECT * FROM rawfri.nb01 LIMIT 10;
--SELECT count(*) FROM rawfri.nbi01;

DROP TABLE If EXISTS translation.nb01_nbi01_lyr;
CREATE TABLE translation.nb01_nbi01_lyr (
    rule_id serial primary key,
    targetattribute varchar,
    targetattributetype varchar,
    validationrules varchar,
    translationrules varchar,
    description varchar,
    descuptodatewithrules varchar
);
COPY translation.nb01_nbi01_lyr (rule_id, targetattribute, targetattributetype, validationrules, translationrules, description, descuptodatewithrules)
    FROM 'C:\Users\PIVER37\Documents\github\casfri\translation\tables\nb01_nbi01_lyr.csv' DELIMITER ',' CSV HEADER;
--SELECT * FROM translation.nb01_nbi01_lyr;

-- Create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.nb01_test;
CREATE TABLE rawfri.nb01_test AS SELECT * FROM rawfri.nb01 LIMIT 200; --WHERE ogc_fid = 2
--SELECT * FROM rawfri.nb01_test;

-- Work on translation file; Display the translation table of interest
--SELECT * FROM translation.nb01_nbi01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.nb01_nbi01_lyr_test;
CREATE TABLE translation.nb01_nbi01_lyr_test AS SELECT * FROM translation.nb01_nbi01_lyr WHERE rule_id>0;
--SELECT * FROM translation.nb01_nbi01_lyr_test;

-- Translate the sample table! Create translation function
SELECT TT_Prepare('translation', 'nb01_nbi01_lyr_test', '_nbi01');

-- Translate the sample!
SELECT * FROM TT_Translate_nbi01('rawfri', 'nb01_test', 'translation', 'nb01_nbi01_lyr_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
--SELECT src_filename, stdlab, ogc_fid, cas_id, l1cc, crown_closure_lower, crown_closure_upper, 
--       l1ht, height_upper, height_lower, l1s1, species_1, l1pr1, species_per_1
--    FROM TT_Translate_nbi01('rawfri', 'nb01_test', 'translation', 'nb01_nbi01_lyr_test'), rawfri.nb01_test
--    WHERE ogc_fid = substr(cas_id, 7)::int;

-- Translate complete table!
--DROP TABLE IF EXISTS casfri50.nb01;
--CREATE TABLE casfri50.nb01 AS SELECT * FROM TT_Translate_nbi01('rawfri', 'nb01', 'translation', 'nb01_nbi01_lyr_test');
--SELECT * FROM casfri50.nb01 LIMIT 10;
