-------------------------------------------------------------------------------
-- TT_vri01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_wetland_code(
  inventory_standard_cd text,
  species_cd_1 text,
  species_pct_1 text,
  species_cd_2 text,
  non_productive_descriptor_cd text,
  non_forest_descriptor text,
  land_cover_class_cd_1 text,
  soil_moisture_regime_1 text,
  crown_closure text,
  proj_height_1 text
)
RETURNS text AS $$
    SELECT CASE
		WHEN inventory_standard_cd='F' AND species_cd_1 IN('SF','CW','YC') AND non_productive_descriptor_cd='S' THEN 'STNN'
		WHEN inventory_standard_cd='F' AND species_cd_1 IN('SF','CW','YC') AND non_productive_descriptor_cd='NP' THEN 'STNN'
		WHEN inventory_standard_cd='F' AND non_forest_descriptor='NPBR' THEN 'STNN'
		WHEN inventory_standard_cd='F' AND non_forest_descriptor='S' THEN 'SONS'
		WHEN inventory_standard_cd='F' AND non_forest_descriptor='MUSKEG' THEN 'STNN'
		WHEN inventory_standard_cd IN('V','I') AND land_cover_class_cd_1='W' THEN 'W---'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND species_cd_1='SB' AND species_pct_1='100' AND crown_closure='50' AND proj_height_1='12' THEN 'BTNN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND species_cd_1 IN('SB','LT') AND species_pct_1='100' AND crown_closure>='50' AND proj_height_1>='12' THEN 'STNN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND species_cd_1 IN('SB','LT') AND species_cd_2 IN('SB','LT') AND crown_closure>='50' AND proj_height_1>='12' THEN 'STNN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND species_cd_1 IN('EP','EA','CW','YR','PI') THEN 'STNN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND species_cd_1 IN('SB','LT') AND species_cd_2 IN('SB','LT') AND crown_closure<'50' THEN 'FTNN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND species_cd_1='LT' AND species_pct_1='100' AND proj_height_1<'12' THEN 'FTNN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND land_cover_class_cd_1 IN('ST','SL') THEN 'SONS'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND land_cover_class_cd_1 IN('HE','HF','HG') THEN 'MONG'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND land_cover_class_cd_1 IN('BY','BM') THEN 'FONN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND land_cover_class_cd_1='BL' THEN 'BONN'
		WHEN inventory_standard_cd IN('V','I') AND soil_moisture_regime_1 IN('7','8') AND land_cover_class_cd_1='MU' THEN 'TMNN'
        ELSE NULL
    END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_vri01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_wetland_validation(
  inventory_standard_cd text,
  species_cd_1 text,
  species_pct_1 text,
  species_cd_2 text,
  non_productive_descriptor_cd text,
  non_forest_descriptor text,
  land_cover_class_cd_1 text,
  soil_moisture_regime_1 text,
  crown_closure text,
  proj_height_1 text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_vri01_wetland_code(inventory_standard_cd, species_cd_1, species_pct_1, species_cd_2, non_productive_descriptor_cd, non_forest_descriptor, land_cover_class_cd_1, soil_moisture_regime_1, crown_closure, proj_height_1) IN('STNN', 'SONS', 'W---', 'BTNN', 'FTNN', 'MONG', 'FONN', 'BONN', 'TMNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_vri01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_vri01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_vri01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_vri01_wetland_translation(
  inventory_standard_cd text,
  species_cd_1 text,
  species_pct_1 text,
  species_cd_2 text,
  non_productive_descriptor_cd text,
  non_forest_descriptor text,
  land_cover_class_cd_1 text,
  soil_moisture_regime_1 text,
  crown_closure text,
  proj_height_1 text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_vri01_wetland_code(inventory_standard_cd, species_cd_1, species_pct_1, species_cd_2, non_productive_descriptor_cd, non_forest_descriptor, land_cover_class_cd_1, soil_moisture_regime_1, crown_closure, proj_height_1);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
