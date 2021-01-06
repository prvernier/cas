-------------------------------------------------------------------------------
-- TT_qc_wetland_code(text, text, text, text, text, text)
--
-- CO_TER
-- CL_DRAIN
-- gr_ess
-- cl_dens
-- cl_haut
-- TYPE_ECO
--
-- Return 4 character wetland code based on the logic defined in the issue.
-- Species values change depending on inventory. QC03 species are different
-- than QC04éQC05 species.
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_wetland_code(text, text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_wetland_code(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_den text,
  cl_haut text,
  TYPE_ECO text,
  inventory_id text
)
RETURNS text AS $$
  DECLARE
    _bad_drainage text[] := ARRAY['50', '51', '52', '53', '54', '60', '61', '62', '63', '64'];
    _cl_den double precision;
    _cl_haut double precision;
  BEGIN
    
    -- set density and height to zero if they are null so that logic tests dont throw error. In prg3 and 4 convert density and height codes to a valuewithin the range of lower to upper
    IF cl_den IS NULL THEN
      _cl_den = 0;
    ELSE
      _cl_den = tt_mapInt(cl_den, '{''A'', ''B'', ''C'', ''D''}', '{90, 70, 50, 30}');
    END IF;
    
    IF cl_haut IS NULL THEN
      _cl_haut = 0;
    ELSE
      _cl_haut = tt_mapDouble(cl_haut, '{''1'',''2'',''3'',''4'',''5'',''6'',''7''}', '{30, 19, 14, 9, 5, 2.5, 0.5}');
    END IF;
    
    -- SONS: swamp, no trees, no permafrost, shrub 25%
    -- denude humide
    IF CO_TER = 'DH' THEN
      RETURN 'SONS';
    END IF;
    
    -- alder with bad drainage
    IF CL_DRAIN = any(_bad_drainage) AND CO_TER = 'AL' THEN
      RETURN 'SONS';
    END IF;
    
    -- BTNN: bog, treed, no permafrost, lawns not present
    -- bad drainage, species is EE (prg 3) or EPEP (prg 4/5) with density 25-40% and height >12m
    IF CL_DRAIN = any(_bad_drainage) AND _cl_den > 25 AND _cl_den < 40 AND _cl_haut <12 THEN
      IF (inventory_id = 'QC03' AND gr_ess = 'EE') OR 
      (inventory_id IN('QC04', 'QC05') AND gr_ess = 'EPEP') THEN 
        RETURN 'BTNN';
      END IF;
    END IF;
    
    -- bog types
    IF TYPE_ECO IN('RE39', 'TOB9D', 'TOB9L', 'TOB9N', 'TOB9U') THEN
      RETURN 'BTNN';
    END IF;
    
    -- FTNN: fen, treed, no permafrost, lawns not present
    -- bad drainage, species are EME or MEE (prg 3) or EPML or MLEP (prg 4/5) with density 25-40%
    IF CL_DRAIN = any(_bad_drainage) AND _cl_den > 25 AND _cl_den < 40 THEN
      IF (inventory_id = 'QC03' AND gr_ess IN('EME', 'MEE')) OR
      (inventory_id IN('QC04', 'QC05') AND gr_ess IN('EPML', 'MLEP')) THEN
        RETURN 'FTNN';
      END IF;
    END IF;
    
    -- bad drainage, species is MEME (prg 3) or MLML, ML (prg 4/5) with height less than 12
    IF CL_DRAIN = any(_bad_drainage) AND _cl_haut < 12 THEN
      IF (inventory_id = 'QC03' AND gr_ess = 'MEME') OR
      (inventory_id IN('QC04', 'QC05') AND gr_ess IN('MLML', 'ML')) THEN
        RETURN 'FTNN';
      END IF;
    END IF;
    
    -- Fen type
    IF TYPE_ECO IN('RE38', 'RS38', 'TOF8L', 'TOF8N', 'TOF8U') THEN
      RETURN 'FTNN';
    END IF;
    
    IF TYPE_ECO IN('TOF8A') THEN
      RETURN 'FONS';
    END IF;

    IF TYPE_ECO IN('TO18') THEN
      RETURN 'BONS';
    END IF;
    
    -- STNN: swamp, treed, no permafrost, lawns not present
    -- bad drainage and specific swamp species or types
    IF CL_DRAIN = any(_bad_drainage) THEN
      IF TYPE_ECO IN('FE10', 'FE20', 'FE30', 'FE50', 'FE60', 'FC10', 'MJ10', 'MS10', 'MS20', 'MS40', 'MS60', 'MS70', 'RB50', 'RP10', 'RS20', 'RS20S', 'RS40', 'RS50', 'RS70', 'RT10', 'RE20', 'RE40', 'RE70') THEN
        RETURN 'STNN';
      END IF;
      
      IF _cl_den > 40 THEN
        IF _cl_haut > 12 THEN
          IF (inventory_id = 'QC03' AND gr_ess IN('EC', 'EPU', 'EME', 'RME', 'SE', 'ES', 'RE', 'MEE', 'MEC')) OR
          (inventory_id IN('QC04', 'QC05') AND gr_ess IN('EPTO', 'EPPU', 'EPML', 'RXML', 'SBEP', 'EPSE', 'RXEP', 'MLEP', 'MLTO')) THEN
            RETURN 'STNN';
          END IF;
        END IF;
        
        IF (inventory_id = 'QC03' AND gr_ess IN('EE', 'MEME')) OR
        (inventory_id IN('QC04', 'QC05') AND gr_ess IN('EPEP','MLML','ML')) THEN
          RETURN 'STNN';
        END IF;
      END IF;
      
      IF (inventory_id = 'QC03' AND gr_ess IN('FNC', 'BJ', 'FH', 'FT', 'BB', 'BB1', 'PE', 'PE1', 'FI', 'CC', 'CPU', 'CE', 'CME', 'RC', 'SC', 'CS', 'PUC', 'BBBB', 'EBB', 'BBBBE', 'BBE', 'BB1E')) OR
      (inventory_id IN('QC04', 'QC05') AND gr_ess IN('FNFN', 'BJ', 'BJBJ', 'FHFH', 'FTFT', 'BPFX', 'PEPE', 'PEFX', 'FIFI', 'TOTO', 'TOPU', 'TOEP', 'TOML', 'RXTO', 'SBTO', 'TOSE', 'PUTO', 'BPBP', 'BPEP', 'BPBPEP')) THEN
        RETURN 'STNN';
      END IF;
    END IF;
      
    -- swamp types
    IF TYPE_ECO IN('RS37', 'RS39', 'RS18', 'RE37', 'RC38', 'MJ18', 'MF18', 'FO18', 'MS18', 'MS18P', 'MS28', 'MS68') THEN
      RETURN 'STNN';
    END IF;
    
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_qc_prg3_wetland_validation(text, text, text, text, text, text)
--
-- CO_TER text,
-- CL_DRAIN text,
-- gr_ess text,
-- cl_dens text,
-- cl_haut text,
-- TYPE_ECO text
--
-- Get the wetland code and check it matches one of the expected values
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_prg3_wetland_validation(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_prg3_wetland_validation(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_den text,
  cl_haut text,
  TYPE_ECO text
)
RETURNS boolean AS $$
  BEGIN
     
    IF TT_qc_wetland_code(CO_TER, CL_DRAIN, gr_ess, cl_den, cl_haut, TYPE_ECO, 'QC03') IN('SONS', 'BTNN', 'FTNN', 'FONS', 'BONS', 'STNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    
  END; 
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_qc_prg4_wetland_validation(text, text, text, text, text, text)
--
-- CO_TER text,
-- CL_DRAIN text,
-- gr_ess text,
-- cl_dens text,
-- cl_haut text,
-- TYPE_ECO text
--
-- Get the wetland code and check it matches one of the expected values
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_prg4_wetland_validation(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_prg4_wetland_validation(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_den text,
  cl_haut text,
  TYPE_ECO text
)
RETURNS boolean AS $$
  BEGIN
     
    IF TT_qc_wetland_code(CO_TER, CL_DRAIN, gr_ess, cl_den, cl_haut, TYPE_ECO, 'QC04') IN('SONS', 'BTNN', 'FTNN', 'FONS', 'BONS', 'STNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    
  END; 
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_qc_prg5_wetland_validation(text, text, text, text, text, text)
--
-- CO_TER text,
-- CL_DRAIN text,
-- gr_ess text,
-- cl_dens text,
-- cl_haut text,
-- TYPE_ECO text
--
-- Get the wetland code and check it matches one of the expected values
------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_prg5_wetland_validation(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_prg5_wetland_validation(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_den text,
  cl_haut text,
  TYPE_ECO text
)
RETURNS boolean AS $$
  BEGIN
     
    IF TT_qc_wetland_code(CO_TER, CL_DRAIN, gr_ess, cl_den, cl_haut, TYPE_ECO, 'QC05') IN('SONS', 'BTNN', 'FTNN', 'FONS', 'BONS', 'STNN') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    
  END; 
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TT_qc_prg3_wetland_translation(text, text, text, text, text, text, text)
--
-- CO_TER text,
-- CL_DRAIN text,
-- gr_ess text,
-- cl_dens text,
-- cl_haut text,
-- TYPE_ECO text
--
-- Get the 4 character wetland code and translate 

------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_prg3_wetland_translation(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_prg3_wetland_translation(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_dens text,
  cl_haut text,
  TYPE_ECO text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
    _wetland_code text;
  BEGIN
  
    _wetland_code = TT_qc_wetland_code(CO_TER, CL_DRAIN, gr_ess, cl_dens, cl_haut, TYPE_ECO, 'QC03');
    
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
    
  END; 
$$ LANGUAGE plpgsql IMMUTABLE;

-------------------------------------------------------------------------------
-- TT_qc_prg4_wetland_translation(text, text, text, text, text, text, text)
--
-- CO_TER text,
-- CL_DRAIN text,
-- gr_ess text,
-- cl_dens text,
-- cl_haut text,
-- TYPE_ECO text
--
-- Get the 4 character wetland code and translate 

------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_prg4_wetland_translation(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_prg4_wetland_translation(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_dens text,
  cl_haut text,
  TYPE_ECO text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
    _wetland_code text;
  BEGIN
  
    _wetland_code = TT_qc_wetland_code(CO_TER, CL_DRAIN, gr_ess, cl_dens, cl_haut, TYPE_ECO, 'QC04');
    
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
    
  END; 
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
-- TT_qc_prg5_wetland_translation(text, text, text, text, text, text, text)
--
-- CO_TER text,
-- CL_DRAIN text,
-- gr_ess text,
-- cl_dens text,
-- cl_haut text,
-- TYPE_ECO text
--
-- Get the 4 character wetland code and translate 
-- Note this is identical to TT_qc_prg4_wetland_translation

------------------------------------------------------------
--DROP FUNCTION IF EXISTS TT_qc_prg5_wetland_translation(text, text, text, text, text, text);
CREATE OR REPLACE FUNCTION TT_qc_prg5_wetland_translation(
  CO_TER text,
  CL_DRAIN text,
  gr_ess text,
  cl_dens text,
  cl_haut text,
  TYPE_ECO text,
  ret_char text
)
RETURNS text AS $$
  DECLARE
    _wetland_code text;
  BEGIN
  
    _wetland_code = TT_qc_wetland_code(CO_TER, CL_DRAIN, gr_ess, cl_dens, cl_haut, TYPE_ECO, 'QC05');
    
    IF _wetland_code IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN TT_wetland_code_translation(_wetland_code, ret_char);
    
  END; 
$$ LANGUAGE plpgsql IMMUTABLE;
-------------------------------------------------------------------------------
