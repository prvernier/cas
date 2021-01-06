-------------------------------------------------------------------------------
-- TT_wetland_code_translation(text, text)
--
-- Take the 4 letter wetland code and translate the requested character
--
-- e.g. TT_wetland_code_translation('BTNN', '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_wetland_code_translation(text, text);
CREATE OR REPLACE FUNCTION TT_wetland_code_translation(
  wetland_code text,
  ret_char_pos text
)
RETURNS text AS $$
  DECLARE
    _wetland_char text;
  BEGIN

    IF wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    
    _wetland_char = substring(wetland_code from ret_char_pos::int for 1);
    
    IF _wetland_char = '-' THEN
      RETURN NULL;
    END IF;
	  
    CASE WHEN ret_char_pos = '1' THEN -- WETLAND_TYPE
	         RETURN TT_MapText(_wetland_char, '{''B'', ''F'', ''S'', ''M'', ''O'', ''T'', ''E'', ''W'', ''Z''}', '{''BOG'', ''FEN'', ''SWAMP'', ''MARSH'', ''SHALLOW_WATER'', ''TIDAL_FLATS'', ''ESTUARY'', ''WETLAND'', ''NOT_WETLAND''}');
	       WHEN ret_char_pos = '2' THEN -- WET_VEG_COVER
	         RETURN TT_MapText(_wetland_char, '{''F'', ''T'', ''O'', ''C'', ''M''}', '{''FORESTED'', ''WOODED'', ''OPEN_NON_TREED_FRESHWATER'', ''OPEN_NON_TREED_COASTAL'', ''MUD''}');
	       WHEN ret_char_pos = '3' THEN -- WET_LANDFORM_MOD
	         RETURN TT_MapText(_wetland_char, '{''X'', ''P'', ''N'', ''A''}', '{''PERMAFROST_PRESENT'', ''PATTERNING_PRESENT'', ''NO_PERMAFROST_PATTERNING'', ''SALINE_ALKALINE''}');
	       WHEN ret_char_pos = '4' THEN -- WET_LOCAL_MOD
	         RETURN TT_MapText(_wetland_char, '{''C'', ''R'', ''I'', ''N'', ''S'', ''G''}', '{''INT_LAWN_SCAR'', ''INT_LAWN_ISLAND'', ''INT_LAWN'', ''NO_LAWN'', ''SHRUB_COVER'', ''GRAMINOIDS''}');
	  END CASE;    
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
