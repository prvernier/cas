-------------------------------------------------------------------------------
-- TT_yvi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_yvi01_wetland_code(
  smr text,
  cc text,
  non_for_veg text, -- this is a CAS attribute
  sp1 text,
  sp2 text,
  sp1_per text,
  avg_ht text
)
RETURNS text AS $$
  -- See WetlandsCode function in Perl code; there are some extra lines prior to the following that need to be considered
  -- This code depends on non_for_veg having already been translated; is this necessary/possible?
  SELECT CASE
	WHEN smr='A' THEN 'MONG'
	WHEN smr='W' AND non_for_veg='S' THEN 'SONS' 
	WHEN smr='W' AND non_for_veg='H' THEN 'MONG' 
	WHEN smr='W' AND non_for_veg='M' THEN 'SONS' 
	WHEN smr='W' AND non_for_veg='C' THEN 'FONS' 
	WHEN smr='W' THEN 'W---'
    WHEN smr='W' AND (sp1='SB' AND sp1_per='100') AND cc<'50' AND avg_ht<'12' THEN 'BTNN'
	WHEN smr='W' AND (sp1='SB' AND sp1_per== 100) AND (cc >= 50  AND  cc < 70)  AND avg_ht >= 12 THEN 'STNN'
	WHEN smr='W' AND (sp1='SB' AND sp1_per== 100) AND (cc >= 70)  AND avg_ht >= 12 THEN 'SFNN'
	WHEN smr='W' AND (sp1='SB' OR sp1 eq 'L') AND  (sp2 eq 'SB' OR sp2 eq 'L') AND cc <= 50  AND avg_ht < 12 THEN 'FTNN'
	WHEN smr='W' AND (sp1='SB' OR sp1 eq 'L' OR sp1 eq 'W') AND  (sp2 eq 'SB' OR sp2 eq 'L' OR sp2 eq 'W') AND cc > 50  AND avg_ht > 12 THEN 'STNN'
	WHEN smr='W' AND (sp1='L' AND sp1_per== 100) AND cc <= 50 'FTNN'
	WHEN smr='W' AND (sp1='L' OR sp1 eq 'W') AND sp1_per== 100 AND (cc > 50  AND  cc < 70) THEN 'STNN'
    WHEN smr='W' AND (sp1='L' OR sp1 eq 'W') AND sp1_per== 100 AND (cc > 70) THEN 'SFNN'
    ELSE NULL
  END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nbi01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_validation(
  smr text,
  cc text,
  non_for_veg text, -- this is a CAS attribute
  sp1 text,
  sp2 text,
  sp1_per text,
  avg_ht text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_yvi01_wetland_code(smr, cc, non_for_veg, sp1, sp2, sp1_per, avg_ht) IN('MONG', 'SONS', 'FONS', 'W---', 'BTNN', 'STNN', 'SFNN', 'FTNN') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nbi01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_translation(
  smr text,
  cc text,
  non_for_veg text, -- this is a CAS attribute
  sp1 text,
  sp2 text,
  sp1_per text,
  avg_ht text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_yvi01_wetland_code(smr, cc, non_for_veg, sp1, sp2, sp1_per, avg_ht);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
