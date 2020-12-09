-------------------------------------------------------------------------------
-- TT_pei01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_pei01_wetland_code(text, int);
CREATE OR REPLACE FUNCTION TT_pei01_wetland_code(
  landtype text,
  per1 text
)
RETURNS text AS $$
  SELECT CASE
           WHEN landtype='BO' AND NOT per1='0' THEN 'BFXX'
		   WHEN landtype='BO' AND per1='0' THEN 'BOXX'
           WHEN landtype='SO' THEN 'SOXX'
           WHEN landtype='SW' AND NOT per1='0' THEN 'STXX'
           WHEN landtype='SW' AND per1='0' THEN 'SOXX'
           ELSE NULL
         END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_pei01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_pei01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_pei01_wetland_validation(text, int, text);
CREATE OR REPLACE FUNCTION TT_pei01_wetland_validation(
  landtype text,
  per1 text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_pei01_wetland_code(landtype, per1) IN('BFXX', 'BOXX', 'SOXX', 'STXX', 'SOXX') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_pei01_wetland_translation(text, int, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_pei01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_pei01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_pei01_wetland_translation(
  landtype text,
  per1 text,
  ret_char_pos text
)
RETURNS text AS $$
  DECLARE
	wetland_code text;
    result text;
  BEGIN
    PERFORM TT_ValidateParams('TT_pei01_wetland_translation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	  wetland_code = TT_pei01_wetland_code(landtype, per1);

    RETURN TT_wetland_code_translation(wetland_code, ret_char_pos);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
