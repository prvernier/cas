-------------------------------------------------------------------------------
-- TT_fli01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fli01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fli01_wetland_code(
  landmod text,
  weteco1 text,
  sp1 text,
  sp2 text,
  sp1per text,
  cc text,
  ht text
)
RETURNS text AS $$
  SELECT CASE
           -- General Wetlands: uncomment if only a general wetland class is desired
           --WHEN landmod IN ('O','W') THEN 'W---'
           -- Non-treed Wetlands
           WHEN weteco1='1' THEN 'BONS'
           WHEN weteco1 IN ('2','5') THEN 'FONS'
           WHEN weteco1='3' THEN 'FONG'
           WHEN weteco1='4' THEN 'FONS'
           WHEN weteco1 IN ('6','7','8','9','10') THEN 'MONG'
		   -- Treed Wetlands
		   WHEN sp1='BS' AND sp1per='100' AND cc<'50' AND HT<'12' THEN 'BTNN'
		   WHEN sp1 IN ('BS','TL') AND sp1per='100' AND cc>='50' AND HT>='12' THEN 'STNN'
		   WHEN sp1 IN ('BS','TL') AND sp2 IN ('TL','BS') AND cc>='50' AND HT>='12' THEN 'STNN'
		   WHEN sp1 IN ('WB','MM','EC','BA') THEN 'STNN'
		   WHEN sp1 IN ('BS','TL') AND sp2 IN ('TL','BS') AND cc<'50' THEN 'FTNN'
		   WHEN sp1='TL' AND sp1per='100' AND cc>'0' AND HT <'12' THEN 'FTNN'
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
  sp1 text,
  sp2 text,
  sp1per text,
  cc text,
  ht text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_mb_fli01_wetland_code(landmod, weteco1, sp1, sp2, sp1per, cc, ht) IN('W---', 'BONS', 'FONS', 'FONG', 'MONG', 'BTNN', 'STNN', 'FTNN') THEN
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
  sp1 text,
  sp2 text,
  sp1per text,
  cc text,
  ht text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_mb_fli01_wetland_code(landmod, weteco1, sp1, sp2, sp1per, cc, ht);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
