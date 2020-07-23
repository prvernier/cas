DROP FUNCTION IF EXISTS get_vri(varchar, int);

CREATE OR REPLACE FUNCTION get_vri(sppCode VARCHAR, minCC INT) 
  RETURNS TABLE (species VARCHAR, crownClosure INT) AS $$
DECLARE 
  var_r record;
BEGIN
  FOR var_r IN(
    SELECT species_cd_1, crown_closure 
    FROM bc_0008.vri9b 
    --WHERE species_cd_1 ILIKE sppCode AND crown_closure >= minCC
    WHERE species_cd_1 IN (SELECT sourceSpecies FROM bc_0008.species WHERE species_cd_1 ILIKE sppCode) AND crown_closure >= minCC
  )  
  LOOP
    species := upper(var_r.species_cd_1); 
    crownClosure := var_r.crown_closure;
    --test := var_r.crown_closure; 
    RETURN NEXT;
  END LOOP;
END; $$ 
LANGUAGE 'plpgsql';

SELECT * FROM get_vri ('BA%', 10);