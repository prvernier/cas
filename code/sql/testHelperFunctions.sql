-- Test helper functions
--SELECT crown_closure, TT_NotNull(crown_closure) FROM bc_0008.vri9 LIMIT 10;
--SELECT crown_closure, TT_Between(crown_closure, 50, 100) FROM bc_0008.vri9 LIMIT 10;
--SELECT crown_closure, TT_Copy(crown_closure) INTO bc_0008.test9 FROM bc_0008.vri9 LIMIT 10;
--SELECT TT_FullTableName('bc_0008', 'species');

-- Test functions using ab_0006
SELECT density, TT_NotNull(density) FROM ab.ab_0006 LIMIT 10;
SELECT height, TT_NotNull(height) FROM ab.ab_0006 LIMIT 10;
SELECT height, TT_Between(height, 50, 100) FROM ab.ab_0006 LIMIT 10;
SELECT sp1, TT_NotEmpty(sp1) FROM ab.ab_0006 LIMIT 10;
SELECT sp1_per, TT_GreaterThan(sp1_per, 10) FROM ab.ab_0006 LIMIT 10;
SELECT sp1_per, TT_LessThan(sp1_per, 10) FROM ab.ab_0006 LIMIT 10;
SELECT height, TT_Copy(height) INTO ab.ab_0006_new LIMIT 10;

--DROP FUNCTION IF EXISTS TT_MatchStr(text, name, name);

--SELECT species_cd_1, TT_MatchStr(species_cd_1) FROM bc_0008.vri9b;
SELECT species_cd_1, TT_MatchStr4('species_cd_1', 'sourceSpecies', 'bc_0008', 'species') FROM bc_0008.vri9b;
--SELECT species_cd_1, TT_MatchStr(species_cd_1, SELECT STRING_AGG(sourceSpecies, ', ') FROM bc_0008.species) FROM bc_0008.vri9b;

/*
CREATE OR REPLACE FUNCTION TT_test(
  var1 text
  var2 text  
  var3 name,  -- schema name
  var4 name  -- table name
)
RETURNS boolean AS $$
DECLARE
  query text;
  return boolean;
  BEGIN
    query = 'SELECT ' || var1 || ' IN (SELECT ' || var2 || ' FROM ' || TT_FullTableName(var3, var4) || ')';
    EXECUTE query INTO return;
    RETURN return;
  END;
$$ LANGUAGE plpgsql VOLATILE;
*/
