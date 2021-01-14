-------------------------------------------------------------------------------
-- TT_sfv01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_sfv01_wetland_code(text, text, text);
  soil_moist_reg text, -- smr for SK02-SK05; moist for SK06
  species_1 text, -- l1_sp1 for SK02-SK05; sp1_1 for SK06
  species_2 text, -- l1_sp2 for SK02-SK05; sp1_2 for SK06
  species_per_1 text, -- l1_sp1_cover for SK02-SK05; per1_1 for SK06
  crown_closure text, -- l1_crown_closure for SK02-SK05; crown_1 for SK06
  height text, -- l1_height for SK02-SK05; height_1 for SK06
  non_for_veg text, -- NFL CAS attribute
  crown_closure_upper text -- NFL CAS attribute

)
RETURNS text AS $$
    SELECT CASE
		-- Forested Land
		WHEN soil_moist_reg='MW' AND species_1='bS' AND species_per_1='100' AND crown_closure<='50' AND height<'12' THEN 'BTNN'
		WHEN soil_moist_reg='MW' AND species_1 !='' AND crown_closure>'50' THEN 'STNN'
		WHEN soil_moist_reg='MW' AND species_1='bS' AND species_per_1='100' AND crown_closure<='50' AND height>='12' THEN 'STNN'
		WHEN soil_moist_reg='MW' AND species_1 !='' AND crown_closure>='70' THEN 'SFNN'
		WHEN soil_moist_reg='W' AND species_1='bS' AND species_per_1='100' AND crown_closure<='50' AND height<'12' THEN 'BTNN'
		WHEN soil_moist_reg='W' AND species_1='bS' AND species_per_1='100' AND crown_closure<='50' AND height>='12' THEN 'STNN'
		WHEN soil_moist_reg='W' AND species_1='bS' AND species_per_1='100' AND (crown_closure>'50' AND crown_closure<'70') AND height>='12' THEN 'STNN'
		WHEN soil_moist_reg='W' AND species_1='bS' AND species_per_1='100' AND crown_closure>='70' AND height>='12' THEN 'SFNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1 IN('bS', 'wB', 'bP', 'mM') AND species_2 IN ('tL', 'bS', 'wB', 'bP', 'mM') AND (crown_closure>='50' AND crown_closure<'70') AND height>='12' THEN 'STNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1 IN('bS', 'wB', 'bP', 'mM') AND species_2 IN ('tL', 'bS', 'wB', 'bP', 'mM') AND crown_closure>='70' THEN 'SFNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1 IN('bS', 'tL') AND species_2 IN ('bS', 'tL') AND crown_closure<'50' AND height<'12' THEN 'FTNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1='tL' AND species_per_1='100' AND (crown_closure>'50' AND crown_closure<'70') AND height>='12' THEN 'STNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1='tL' AND species_per_1='100' AND crown_closure>='70' THEN 'STNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1='tL' AND species_per_1='100' AND crown_closure<='50' AND height>0 THEN 'FTNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1 IN('wB', 'mM', 'gA', 'wE') AND species_per_1='100' AND crown_closure<'70' THEN 'STNN'
		WHEN soil_moist_reg IN ('W', 'VW') AND species_1 IN('wB', 'mM', 'gA', 'wE') AND species_per_1='100' AND crown_closure>='70' THEN 'SFNN'
		-- Non Forest Land
		WHEN soil_moist_reg IN ('MW', 'W', 'VW') AND non_for_veg IN ('HE','GR') THEN 'MONG'
		WHEN soil_moist_reg IN ('MW', 'W', 'VW') AND non_for_veg='MO' THEN 'FONN'
		WHEN soil_moist_reg IN ('MW', 'W', 'VW') AND non_for_veg='AV' THEN 'OONN'
		WHEN soil_moist_reg IN ('MW', 'W', 'VW') AND non_for_veg IN ('TS', 'LS' AND crown_closure_upper>'25' THEN 'SONS'
        ELSE NULL
    END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_sfv01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_sfv01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_sfv01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_sfv01_wetland_validation(
  soil_moist_reg text,
  species_1 text,
  species_2 text,
  species_per_1 text,
  crown_closure text,
  height text,
  non_for_veg text,
  crown_closure_upper text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_sfv01_wetland_code(soil_moist_reg, species_1, species_2, species_per_1, crown_closure, height, non_for_veg, crown_closure_upper) IN('BTNN', 'STNN', 'SFNN', 'MONG', 'FONN', 'OONN', 'SONS') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_sfv01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_sfv01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_sfv01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_sfv01_wetland_translation(
  soil_moist_reg text,
  species_1 text,
  species_2 text,
  species_per_1 text,
  crown_closure text,
  height text,
  non_for_veg text,
  crown_closure_upper text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_sfv01_wetland_code(soil_moist_reg, species_1, species_2, species_per_1, crown_closure, height, non_for_veg, crown_closure_upper);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
