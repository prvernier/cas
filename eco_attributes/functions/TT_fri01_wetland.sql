-------------------------------------------------------------------------------
-- TT_nbi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_code(
  wc text,
  vt text,
  im text
)
RETURNS text AS $$
  SELECT CASE
           -- These are from Cosco specs:
           WHEN wc='AB' THEN 'OONN'
		   WHEN wc='BO' AND vt='FS' THEN 'BTNN'
           WHEN wc='BO' AND vt='SV' THEN 'BONS'
           WHEN wc='FE' AND vt IN ('FH', 'FS') THEN 'FTNN'
           WHEN wc='FE' AND vt IN ('AW', 'SV') THEN 'FONS'
           WHEN wc='FM' THEN 'MONG'
           WHEN wc='FW' THEN 'STNN'
           -- WHEN wc='FW' AND im='BP' THEN 'OF-B' -- from Perl code but incorrect in Cosco
           WHEN wc='FW' AND im='BP' THEN 'OONN' -- correct in Cosco
           WHEN wc='SB' THEN 'SONS'
           WHEN wc='CM' THEN 'MCNG'
           WHEN wc='TF' THEN 'TMNN'
		   -- These are only found in Perl code:
           WHEN wc='BO' AND vt='EV' AND im='BP' THEN 'BO-B'
           WHEN wc='FE' AND vt='EV' AND im='BP' THEN 'FO-B'
           WHEN wc='BO' AND vt='EV' AND im='DI' THEN 'BO--'
           WHEN wc='BO' AND vt='AW' AND im='BP' THEN 'BT-B'
           WHEN wc='BO' AND vt='OV' AND im='BP' THEN 'OO-B'
           WHEN wc='FE' AND vt='EV' AND im IN ('MI', 'DI') THEN 'FO--'
           WHEN wc='FE' AND vt='OV' AND im='MI' THEN 'OO--'
           WHEN wc='FE' AND vt='EV' THEN 'FO--'
           WHEN wc IN ('FE', 'BO') AND vt='OV' THEN 'OO--'
           WHEN wc IN ('FE', 'BO') AND vt='OW' THEN 'O---'
           WHEN wc='BO' AND vt='EV' THEN 'BO--'
           WHEN wc='BO' AND vt='AW' THEN 'BT--'
           WHEN wc IN ('NP', 'WL') THEN 'W---'
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
  wc text,
  vt text,
  im text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_nbi01_wetland_code(wc, vt, im) IN('OONN', 'BTNN', 'BONS', 'FTNN', 'FONS', 'MONG', 'STNN', 'OONN', 'SONS', 'MCNG', 'TMNN', 'BO-B', 'FO-B', 'BO--', 'BT-B', 'OO-B', 'FO--', 'OO--', 'O---', 'BT--', 'W---') THEN
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
  wc text,
  vt text,
  im text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_nbi01_wetland_code(wc, vt, im);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
