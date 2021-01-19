-------------------------------------------------------------------------------
-- TT_fri01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fri01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fri01_wetland_code(
  productivity text,
  subtype text
)
RETURNS text AS $$
  SELECT CASE
           -- Non Productive
           WHEN productivity='701' THEN 'BTNN'
           WHEN productivity='702' THEN 'FTNN'
           WHEN productivity='703' THEN 'STNN'
           WHEN productivity IN ('721','722','723') THEN 'SONS'
           -- Productive
           WHEN subtype IN ('16','17','30','31','32','36','37','56','57','70','71','72','76','77') THEN 'STNN'
           WHEN subtype='9E' THEN 'SONS'
           ELSE NULL
         END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_fri01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_fri01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fri01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fri01_wetland_validation(
  productivity text,
  subtype text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_mb_fri01_wetland_code(productivity, subtype) IN('BTNN', 'FTNN', 'STNN', 'SONS') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_fri01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_fri01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fri01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_mb_fri01_wetland_translation(
  productivity text,
  subtype text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_mb_fri01_wetland_code(productivity, subtype);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
