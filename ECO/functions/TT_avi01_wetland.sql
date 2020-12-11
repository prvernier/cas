-------------------------------------------------------------------------------
-- TT_avi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_avi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_avi01_wetland_code(
  moisture text,
  nonfor_veg text,
  nat_nonveg text,
  sp1 text,
  sp2 text,
  crownclose text,
  sp1_percnt text
)
RETURNS text AS $$
    SELECT CASE
		WHEN moisture='w' AND nonfor_veg!='NA' THEN NULL
		WHEN moisture='w' AND nonfor_veg IN('SO','SC') THEN 'SONS'
		WHEN moisture='w' AND nonfor_veg IN('HG','HF') THEN 'MONG'
		WHEN moisture='w' AND nonfor_veg='BR' THEN 'FONG'
		WHEN moisture='w' AND nat_nonveg='NWB' THEN 'SONS'
		WHEN moisture IN('a','d','m') AND (sp1='LT' OR sp2='LT') AND crownclose IN('A','B') THEN 'FTNN'
		WHEN moisture IN('a','d','m') AND (sp1='LT' OR sp2='LT') AND crownclose='C' THEN 'STNN'
		WHEN moisture IN('a','d','m') AND (sp1='LT' OR sp2='LT') AND crownclose='D' THEN 'SFNN'
		WHEN moisture IN('a','d','m') AND (sp1='SB' AND sp1_percnt='100') AND crownclose IN('A','B') THEN 'BTNN'
		WHEN moisture IN('a','d','m') AND (sp1='SB' AND sp1_percnt='100') AND crownclose='C' THEN 'STNN'
		WHEN moisture IN('a','d','m') AND (sp1='SB' AND sp1_percnt='100') AND crownclose='D' THEN 'SFNN'
		WHEN moisture IN('a','d','m') AND ((sp1='SB' OR sp1='FB') AND sp2!='LT') AND crownclose IN('A','B','C') THEN 'STNN'
		WHEN moisture IN('a','d','m') AND ((sp1='SB' OR sp1='FB') AND sp2!='LT') AND crownclose='D' THEN 'SFNN'
		WHEN moisture IN('a','d','m') AND sp1 IN('BW','PB') AND crownclose IN('A','B','C') THEN 'STNN'
		WHEN moisture IN('a','d','m') AND sp1 IN('BW','PB') AND crownclose='D' THEN 'SFNN'
        ELSE NULL
    END;

$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_avi01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_avi01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_avi01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_avi01_wetland_validation(
  moisture text,
  nonfor_veg text,
  nat_nonveg text,
  sp1 text,
  sp2 text,
  crownclose text,
  sp1_percnt text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_avi01_wetland_code(moisture, nonfor_veg, nat_nonveg, sp1, sp2, crownclose, sp1_percnt) IN('SONS', 'MONG', 'FONG', 'FTNN', 'STNN', 'SFNN', 'BTNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_avi01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_avi01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_avi01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_avi01_wetland_translation(
  moisture text,
  nonfor_veg text,
  nat_nonveg text,
  sp1 text,
  sp2 text,
  crownclose text,
  sp1_percnt text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_avi01_wetland_code(moisture, nonfor_veg, nat_nonveg, sp1, sp2, crownclose, sp1_percnt);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
