-------------------------------------------------------------------------------
-- TT_fim01_wetland_code(text, text, text)
-------------------------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fim01_wetland_code(text, text, text);
CREATE OR REPLACE FUNCTION TT_fim01_wetland_code(
  polytype text,  -- $UnProd
  species_1 text, -- $Species1
  species_2 text, -- $Species2
  species_3 text, -- $Species3
  species_per_1 text, -- $SpeciesPerc;
  -- $Ecosite
  -- $Wetland = ""
  -- $MNRCode
)
RETURNS text AS $$
	SELECT CASE
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ($MNRCode eq "310" || $UnProd eq "TMS") {  $Wetland="F,T,N,N,"; } 
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ($MNRCode eq "311" || ($UnProd eq "OMS")|| ($UnProd eq "OM")) {  $Wetland="F,O,N,S,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ($MNRCode eq "312" || ($UnProd eq "BSH")|| ($UnProd eq "BA")) {  $Wetland="S,O,N,S,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( ($Species1 eq "SB" && $Species2 eq "L") || ($Species1 eq "L" && $Species2 eq "SB") )  { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( $Species1 eq "L" && $Species2 eq "SB" && $Species3 eq "CE" ) { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( $Species1 eq "SB" && $Species2 eq "L" && $Species3 eq "CE" ) { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( ($Species1 eq "CE" && $Species2 eq "L") || ($Species1 eq "L" && $Species2 eq "CE") ){ $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( $Species1 eq "CE" && $Species2 eq "L" && $Species3 eq "SB" ) { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( $Species1 eq "CE" && $Species2 eq "SB" && $Species3 eq "L" ) { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( ($Species1 eq "L" || $Species1 eq "AB" )&&  $SpeciesPerc ==100)    { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( $Species1 eq "BW" && ($Species2 eq "L" || $Species2 eq "CE")) { $Wetland = "S,T,N,N,"; }
		WHEN (isempty($Ecosite) || $Ecosite eq "0") AND ( ($Species1 eq "L" || $Species1 eq "CE") && $Species2 eq "BW") { $Wetland = "S,T,N,N,"; }       
		WHEN (isempty($Ecosite) || $Ecosite eq "0") {$Wetland = MISSCODE;} 		
		WHEN ($Ecosite eq "ES34")                                                                      {  $Wetland="B,T,N,N,"; }
		WHEN ($Ecosite eq "ES35" || $Ecosite eq "ES36" || $Ecosite eq "ES37" || $Ecosite eq "ES38") {  $Wetland="S,T,N,N,"; }  
		WHEN ($Ecosite eq "ES40")                                                                   {  $Wetland="F,T,N,N,"; }
		WHEN ($Ecosite eq "ES41" || $Ecosite eq "ES42" )                                            {  $Wetland="F,O,N,S,"; }  
		WHEN ($Ecosite eq "ES43" || $Ecosite eq "ES45" )                                            {  $Wetland="F,O,N,G,"; }  
		WHEN ($Ecosite eq "ES44") {  $Wetland="S,O,N,S,"; }
		WHEN ($Ecosite eq "ES46" || $Ecosite eq "ES47" || $Ecosite eq "ES48" || $Ecosite eq "ES49" || $Ecosite eq "ES50") {  $Wetland="M,O,N,G,"; } 
		WHEN ($Ecosite eq "ES51" || $Ecosite eq "ES52" || $Ecosite eq "ES53")                       {  $Wetland="O,O,N,N,"; } 
		WHEN ($Ecosite eq "ES54" || $Ecosite eq "ES55" || $Ecosite eq "ES56")                       {  $Wetland="O,O,N,N,"; } 
		WHEN ($Ecosite eq "NW34")                                                                   {  $Wetland="B,T,N,N,"; }
		WHEN ($Ecosite eq "NW35" || $Ecosite eq "NW36" || $Ecosite eq "NW37" || $Ecosite eq "NW38") {  $Wetland="S,T,N,N,"; }  
		WHEN ($Ecosite eq "NW40")                                                                   {  $Wetland="F,T,N,N,"; }
		WHEN ($Ecosite eq "NW41" || $Ecosite eq "NW42"  )                                           {  $Wetland="F,O,N,S,"; }  
		WHEN ($Ecosite eq "NW43" || $Ecosite eq "NW45" )                                            {  $Wetland="F,O,N,G,"; }  
		WHEN ($Ecosite eq "NW44") {  $Wetland="S,O,N,S,"; }
		WHEN ($Ecosite eq "NW46" || $Ecosite eq "NW47" || $Ecosite eq "NW48" || $Ecosite eq "NW49" || $Ecosite eq "NW50") {  $Wetland="M,O,N,G,"; } 
		WHEN ($Ecosite eq "NW51" || $Ecosite eq "NW52" || $Ecosite eq "NW53")                       {  $Wetland="O,O,N,N,"; } 
		WHEN ($Ecosite eq "NW54" || $Ecosite eq "NW55" || $Ecosite eq "NW56")                       {  $Wetland="O,O,N,N,"; } 
		WHEN ($Ecosite eq "ES11" || $Ecosite eq "ES14"  )                                           {  $Wetland="B,T,N,N,"; }  
		WHEN ($Ecosite eq "ES13P") {  $Wetland="F,T,N,N,"; }
		WHEN ($Ecosite eq "ES12" || $Ecosite eq "ES13R")                                            {  $Wetland="S,T,N,N,"; }
		WHEN ($Ecosite eq "NE9P" || $Ecosite eq "NE11" || $Ecosite eq "NE12" || $Ecosite eq "NE13P" ) {  $Wetland="B,F,-,-,"; } 
		WHEN ($Ecosite eq "NE14")                                                                   {  $Wetland="B,T,-,-,"; }
		WHEN ($Ecosite eq "ES31")                                                                   {  $Wetland="F,T,N,N,"; }
		WHEN ($Ecosite eq "ES32" ||$Ecosite eq "ES33" ||$Ecosite eq "ES34")                         {  $Wetland="S,T,N,N,"; }
		WHEN ($Ecosite eq "CE31" ||$Ecosite eq "CE32" ||$Ecosite eq "CE33")                         {  $Wetland="B,F,-,-,"; }
		WHEN ($Ecosite eq "CR31" ||$Ecosite eq "CR32" ||$Ecosite eq "CR33")                         {  $Wetland="B,F,-,-,"; }
        ELSE NULL
	END;
END;
$$ LANGUAGE sql IMMUTABLE;
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
-- TT_fim01_wetland_validation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return true if the requested character (1-4)
-- is not null and not -.
--
-- e.g. TT_fim01_wetland_validation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fim01_wetland_validation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_fim01_wetland_validation(
  wc text,
  vt text,
  im text
)
RETURNS boolean AS $$
  DECLARE
		wetland_code text;
  BEGIN
    IF TT_fim01_wetland_code(wc, vt, im) IN('OONN', 'BTNN', 'BONS', 'FTNN', 'FONS', 'MONG', 'STNN', 'OONN', 'SONS', 'MCNG', 'TMNN', 'BO-B', 'FO-B', 'BO--', 'BT-B', 'OO-B', 'FO--', 'OO--', 'O---', 'BT--', 'W---') THEN
      RETURN TRUE;
    ELSE
	  RETURN FALSE;
	END IF;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_fim01_wetland_translation(text, text, text, text)
--
-- Assign 4 letter wetland character code, then return the requested character (1-4)
--
-- e.g. TT_fim01_wetland_translation(wt, vt, im, '1')
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_fim01_wetland_translation(text, text, text, text);
CREATE OR REPLACE FUNCTION TT_fim01_wetland_translation(
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
    _wetland_code = TT_fim01_wetland_code(wc, vt, im);
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
