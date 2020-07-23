-- https://postgres.cz/wiki/PL/pgSQL_(en)#Using_PL.2FpgSQL_language_for_custom_functions

CREATE OR REPLACE FUNCTION next_day(IN d date, IN day varchar) 
RETURNS date AS $$
DECLARE 
  id integer
  dow integer;
BEGIN 
  dow := EXTRACT(dow FROM d);
  id := CASE lower(substring(day FROM 1 FOR 3))
            WHEN 'sun' THEN 0
            WHEN 'mon' THEN 1
            WHEN 'tue' THEN 2
            WHEN 'wed' THEN 3
            WHEN 'thu' THEN 4
            WHEN 'fri' THEN 5
            WHEN 'sat' THEN 6 END;
  IF id IS NULL THEN
    RAISE EXCEPTION 'Wrong identifier for day ' || quote_literal(day);
  END IF;
  RETURN CASE id <= dow
             WHEN true  THEN d + (id - dow + 7)
             WHEN false THEN d + (id - dow) END;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;