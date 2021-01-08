-------------------------------------------------------------------------------
-- TT_utm01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_utm01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_utm01_wetland_code(
  drain text,
  sp10 text,
  sp11 text,
  species_per_1 text,
  d text,
  np text
)
RETURNS text AS $$
  SELECT CASE
           -- Productive Forest Land
           WHEN (drain='PVP' AND text='O') OR (drain='PD' AND text='O') AND sp10='bS' AND species_per_1='100' AND (d='C' OR d='D') THEN 'STNN'
           WHEN (drain='PVP' AND text='O') OR (drain='PD' AND text='O') AND sp10='bS' AND species_per_1='100' AND (d='A' OR d='B') THEN 'BTNN'
           WHEN (drain='PVP' AND text='O') OR (drain='PD' AND text='O') AND sp10 IN ('bS', 'tL', 'wB', 'mM') AND sp11 IN ('bS', 'tL', 'wB', 'mM')  THEN 'STNN'
		   -- Non Productive Lands
           WHEN np='3100' THEN 'WT--'
           WHEN np='3300' THEN 'WO--'
           WHEN np='3500' THEN 'SONS'
           WHEN np='3600' OR np='5100' THEN 'MONG'
           ELSE NULL
         END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_utm01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_utm01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_utm01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_utm01_wetland_validation(
  drain text,
  sp10 text,
  sp11 text,
  species_per_1 text,
  d text,
  np text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_utm01_wetland_code(drain, sp10, sp11, species_per_1, d, np) IN('STNN','BTNN','WT--','WO--','SONS','MONG') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_utm01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_utm01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_utm01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_utm01_wetland_translation(
  drain text,
  sp10 text,
  sp11 text,
  species_per_1 text,
  d text,
  np text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_utm01_wetland_code(drain, sp10, sp11, species_per_1, d, np);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
