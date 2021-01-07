-------------------------------------------------------------------------------
-- TT_fvi01_wetland_code(text, text, text, text, text, text, text, text, text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fvi01_wetland_code(text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_fvi01_wetland_code(
	landpos text;
	structur text;
	moisture text;
	typeclas text;
	mintypeclas text;
	sp1 text;
	sp2 text;
	sp1_per text;
	crownclos text;
	height text;
	wetland text
)
RETURNS text AS $$
	SELECT CASE
		WHEN landpos='W' THEN 'W'
		-- NON-FORESTED POLYGONS
		WHEN structur='S' AND (moisture='SD' OR moisture='HD') AND (typeclas='ST' OR typeclas='SL') THEN 'SONS'
		WHEN structur='S' AND (moisture='SD' OR moisture='HD') AND typeclas IN ('HG', 'HF', 'HE') THEN 'MONG'
		WHEN structur='S' AND (moisture='SD' OR moisture='HD') AND typeclas='BM' THEN 'FONG'
		WHEN structur='S' AND (moisture='SD' OR moisture='HD') AND (typeclas='BL' OR typeclas='BY') THEN 'BOXC'
		WHEN structur='H' AND moisture='SD' AND (typeclas IN ('SL', 'HG') OR mintypeclas IN ('SL', 'HG')) THEN 'BOXC'
		WHEN structur='H' AND moisture='HD' AND (typeclas='HG' OR mintypeclas='HG') THEN 'MONG'
		WHEN structur='M' AND (moisture='SD' OR moisture='HD') AND (typeclas='ST' OR typeclas='SL') THEN 'FONS'
		-- FOREST LAND
		WHEN structur IN ('M', 'C', 'H') AND mintypeclas='SL' AND moisture='SD' AND (((sp1='SB' OR sp1='PJ') AND sp1_per='100') OR ((sp1='SB' OR sp1='PJ') AND (sp2='SB' OR sp2='PJ'))) AND crownclos<'50' AND height<'8' THEN 'BTXC'
		WHEN structur='S' AND (moisture='SD' OR moisture='HD') AND ((sp1='SB' OR sp1='LT') AND  sp1_per='100') AND (crownclos>'50' AND crownclos<'70') THEN 'STNN'
		WHEN (moisture='SD' OR moisture='HD') AND (sp1='SB' OR sp1='LT') AND crownclos>'70' THEN 'SFNN'
		WHEN (moisture='SD' OR moisture='HD') AND ((sp1='SB' OR sp1='LT') AND (sp2='SB' OR sp2='LT')) AND height<'12' THEN 'FTNN'
		WHEN (moisture='SD' OR moisture='HD') AND ((sp1='SB' OR sp1='LT') AND (sp2='SB' OR sp2='LT')) AND height>='12' THEN 'STNN'; 
		WHEN moisture='HD' AND ((sp1='SB' OR sp1='LT') AND  sp1_per='100') AND crownclos<'50' THEN 'FTNN'
		WHEN (moisture='SD' OR moisture='HD') AND (sp1 IN ('SB', 'LT', 'BW', 'SW') AND sp2 IN ('SB', 'LT', 'BW', 'SW')) AND crownclos>'50' THEN 'FTNN'
		WHEN (moisture='SD' OR moisture='HD') AND (sp1='BW' OR sp1='PO') THEN 'STNN'
		-- WETLAND CLASS
		WHEN wetland='WE' THEN 'W'
		WHEN wetland='SO' THEN 'OONN'
		WHEN wetland='MA' THEN 'MONG'
		WHEN wetland='SW' AND sp1!="" THEN 'STNN' -- is this correct to mean sp1 is populated???
		WHEN wetland='SW' AND (typeclas='SL' OR typeclas='ST') THEN 'SONS'
		WHEN wetland='FE' AND sp1!="" THEN 'FTNN' -- is this correct to mean sp1 is populated???
		WHEN wetland='FE' AND typeclas='HG' THEN 'FONG'
		WHEN wetland='FE' AND (typeclas='SL' OR typeclas='ST') THEN 'FONS'
		WHEN wetland='BO' AND sp1!="" THEN 'BTXC' -- is this correct to mean sp1 is populated???
		WHEN wetland='BO' AND (typeclas IN ('BY', 'BL', 'BM') THEN 'BOXC'
		ELSE NULL
    END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_fvi01_wetland_validation(text, text, text, text, text, text, text, text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_fvi01_wetland_validation(landpos, structur, moisture, typeclas, mintypeclas, sp1, sp2, sp1_per, crownclos, height, wetland, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fvi01_wetland_validation(text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_fvi01_wetland_validation(
	landpos text;
	structur text;
	moisture text;
	typeclas text;
	mintypeclas text;
	sp1 text;
	sp2 text;
	sp1_per text;
	crownclos text;
	height text;
	wetland text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_fvi01_wetland_code(landpos, structur, moisture, typeclas, mintypeclas, sp1, sp2, sp1_per, crownclos, height, wetland) IN('W','SFNN','OONN','MONG','STNN','SONS','FTNN','FONG','FONS','BTXC','BOXC') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nbi01_wetland_translation(text, text, text, text, text, text, text, text, text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nbi01_wetland_translation(landpos, structur, moisture, typeclas, mintypeclas, sp1, sp2, sp1_per, crownclos, height, wetland, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nbi01_wetland_translation(text, text, text, text, text, text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nbi01_wetland_translation(
	landpos text;
	structur text;
	moisture text;
	typeclas text;
	mintypeclas text;
	sp1 text;
	sp2 text;
	sp1_per text;
	crownclos text;
	height text;
	wetland text;
  ret_char text
)
RETURNS text AS $$
  DECLARE
	_wetland_code text;
    result text;
  BEGIN
    _wetland_code = TT_nbi01_wetland_code(landpos, structur, moisture, typeclas, mintypeclas, sp1, sp2, sp1_per, crownclos, height, wetland);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
