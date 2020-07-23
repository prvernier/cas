--SET tt.debug TO TRUE;
SET tt.debug TO FALSE;
--SELECT * FROM rawfri.bc08 LIMIT 10;
--SELECT count(*) FROM rawfri.bc08;

DROP TABLE If EXISTS translation.bc08_vri01_dst;
CREATE TABLE translation.bc08_vri01_dst (
    rule_id serial primary key,
    targetattribute varchar,
    targetattributetype varchar,
    validationrules varchar,
    translationrules varchar,
    description varchar,
    descuptodatewithrules varchar
);
COPY translation.bc08_vri01_dst (rule_id, targetattribute, targetattributetype, validationrules, translationrules, description, descuptodatewithrules)
    FROM 'C:\Users\PIVER37\Documents\github\casfri\translation\tables\bc08_vri01_dst.csv' DELIMITER ',' CSV HEADER;
--SELECT * FROM translation.bc08_vri01_dst;

DROP TABLE If EXISTS translation.bc_vri01_dst;
CREATE TABLE translation.bc_vri01_dst (
    source_val varchar,
    dst varchar
);

-- Create a smaller test inventory table
DROP TABLE IF EXISTS rawfri.bc08_test;
CREATE TABLE rawfri.bc08_test AS SELECT * FROM rawfri.bc08 LIMIT 200; --WHERE ogc_fid = 2
--SELECT * FROM rawfri.bc08_test LIMIT 20;

-- Work on translation file; Display the translation table of interest
--SELECT * FROM translation.bc08_vri01_lyr; 

-- Create a subset translation table if necessary
DROP TABLE IF EXISTS translation.bc08_vri01_dst_test;
CREATE TABLE translation.bc08_vri01_dst_test AS SELECT * FROM translation.bc08_vri01_dst WHERE rule_id>0;
--SELECT * FROM translation.bc08_vri01_dst_test;

-- Translate the sample table! Create translation function
SELECT TT_Prepare('translation', 'bc08_vri01_dst_test', '_bc08');

-- Translate the sample!
SELECT * FROM TT_Translate_bc08('rawfri', 'bc08_test', 'translation', 'bc08_vri01_dst_test');

-- Display original values and translated values side-by-side to compare and debug the translation table
--SELECT src_filename, map_id, feature_id, ogc_fid, cas_id, soil_moisture_regime_1, soil_moist_reg, structure_per,
--    layer, layer_rank, crown_closure, crown_closure_lower, crown_closure_upper, proj_height_1, height_upper, height_lower, 
--    productive_for, species_cd_1, species_pct_1, species_pct_1, species_per_1, proj_age_1, origin_lower, origin_upper, site_class --, site_index
--    FROM TT_Translate_bc08('rawfri', 'bc08_test', 'translation', 'bc08_vri01_lyr_test'), rawfri.bc08_test
--    WHERE feature_id = substr(cas_id, 33, 10)::int;

-- Translate complete table!
--DROP TABLE IF EXISTS casfri50.bc08;
--CREATE TABLE casfri50.bc08 AS SELECT * FROM TT_Translate_bc08('rawfri', 'bc08', 'translation', 'bc08_vri01_lyr_test');
--SELECT * FROM casfri50.bc08 LIMIT 10;
