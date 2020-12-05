-------------------------------------------------------------------------------
-- TT_nli01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nli01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nli01_wetland_code(
  stand_id int,
  site text,
  species_comp text
)
RETURNS text AS $$

	IF stand_id=920 THEN  
	    RETURN 'BONS'
	IF stand_id=925 THEN
	    RETURN 'BTNN'
	IF stand_id=930 THEN
	    RETURN 'MONG'
	IF stand_id=900 AND site='W' THEN
	    RETURN 'STNN'
	IF stand_id=910 AND site='W' THEN
	    RETURN 'STNN'
	IF species_comp IN('BSTL', 'BSTLBF', 'BSTLWB' ) THEN
	    RETURN 'STNN'
	IF species_comp IN('TL', 'TLBF','TLWB', 'TLBS', 'TLBSBF', 'TLBSWB') THEN
	    RETURN 'STNN'
	IF species_comp IN('WBTL', 'WBTLBS', 'WBBSTL') THEN
	    RETURN 'STNN'
    END

$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nli01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nli01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nli01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nli01_wetland_validation(
  stand_id int,
  site text,
  species_comp text,
	ret_char_pos text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nli01_wetland_validation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	  wetland_code = TT_nli01_wetland_code(stand_id, site, species_comp);

    -- return true or false
    IF wetland_code IS NULL OR substring(wetland_code from ret_char_pos::int for 1) = '-' THEN
      RETURN FALSE;
		END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nli01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nli01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nli01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nli01_wetland_translation(
  stand_id int,
  site text,
  species_comp text,
  ret_char_pos text
)
RETURNS text AS $$
  DECLARE
	wetland_code text;
    result text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nli01_wetland_translation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	  wetland_code = TT_nli01_wetland_code(stand_id, site, species_comp);

    RETURN TT_wetland_code_translation(wetland_code, ret_char_pos);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
