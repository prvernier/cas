-------------------------------------------------------------------------------
-- TT_nsi01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nsi01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_nsi01_wetland_code(
  fornon int,
  species text,
  crncl int,
  height int
)
RETURNS text AS $$

    -- Original cases
    SELECT CASE
        WHEN fornon=70 THEN 'W---'
        WHEN fornon=71 THEN 'MONG'
        WHEN fornon=72 THEN 'BONN'
        WHEN fornon=73 THEN 'BTNN'
        WHEN fornon=74 THEN 'ECNN'
        WHEN fornon=75 THEN 'MONG'
        ELSE NULL
    END;

	-- These were added on 2012-09-17
	IF fornon IN(33, 38, 39) AND species IN('BS10', 'TL10', 'EC10', 'WB10', 'YB10', 'AS10') THEN
        RETURN 'SONS'
    END

	IF (fornon=0 AND (species='TL10' OR (species =~ m/TL/ AND species =~ m/WB/ ) AND crncl <=50 AND height <=12) THEN
	    RETURN 'FTNN'
    END

	IF (fornon=0 AND (species='TL10' OR (species =~ m/TL/ AND species =~ m/WB/ ) AND crncl >50) ) THEN
	    RETURN 'STNN'
	END

	IF (fornon=0 AND (species='EC10' OR (species =~ m/EC/ AND species =~ m/TL/ )  OR (species =~ m/EC/ AND species =~ m/BS/ )  OR (species =~ m/EC/ AND species =~ m/WB/ ) )) THEN
	    RETURN 'STNN'

	IF (fornon=0 AND (species='AS10' OR (species =~ m/AS/ AND species =~ m/BS/ )  OR (species =~ m/AS/ AND species =~ m/TL/ ))) THEN
	    RETURN 'STNN'
	END

	IF (fornon=0 AND (species =~ m/BS/ AND species =~ m/LT/ )) THEN
	    RETURN 'STNN'
    END

$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nsi01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_nsi01_wetland_validation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nsi01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nsi01_wetland_validation(
  fornon int,
  species text,
  crncl int,
  height int,
	ret_char_pos text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nsi01_wetland_validation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	  wetland_code = TT_nsi01_wetland_code(fornon, species, crncl, height);

    -- return true or false
    IF wetland_code IS NULL OR substring(wetland_code from ret_char_pos::int for 1) = '-' THEN
      RETURN FALSE;
		END IF;
    RETURN TRUE;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_nsi01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_nsi01_wetland_translation(landtype, per1, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_nsi01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_nsi01_wetland_translation(
  fornon int,
  species text,
  crncl int,
  height int,
  ret_char_pos text
)
RETURNS text AS $$
  DECLARE
	wetland_code text;
    result text;
  BEGIN
    PERFORM TT_ValidateParams('TT_nsi01_wetland_translation',
                              ARRAY['ret_char_pos', ret_char_pos, 'int']);
	  wetland_code = TT_nsi01_wetland_code(fornon, species, crncl, height);

    RETURN TT_wetland_code_translation(wetland_code, ret_char_pos);
    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
