-------------------------------------------------------------------------------
-- TT_fli01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fli01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fli01_wetland_code(
  landmod text,
  weteco1 text,
  im text
)
RETURNS text AS $$
  SELECT CASE
           -- General Wetlands
           WHEN landmod IN ('O','W') THEN 'W---'
           -- Non-treed Wetlands
           WHEN weteco1='1' THEN 'BONS'
           WHEN weteco1 IN ('2','5') THEN 'FONS'
           WHEN weteco1='3' THEN 'FONG'
           WHEN weteco1='4' THEN 'FONS'
           WHEN weteco1 IN ('6','7','8','9','10') THEN 'MONG'
		   -- Treed Wetlands

           ELSE NULL
         END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_fli01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_fli01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fli01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fli01_wetland_validation(
  landmod text,
  weteco1 text,
  im text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_mb_fli01_wetland_code(landmod, weteco1, im) IN('W---', 'BONS', 'FONS', 'FONG', 'MONG') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_fli01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_fli01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fli01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fli01_wetland_translation(
  landmod text,
  weteco1 text,
  im text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_mb_fli01_wetland_code(landmod, weteco1, im);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
