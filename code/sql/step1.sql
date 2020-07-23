-- Create species table from csv file and join to vri9

DROP TABLE bc_0008.species;
DROP TABLE bc_0008.vri9b;

CREATE TABLE bc_0008.species (
    species_id integer,
    province character varying(2),
    targetSpecies character varying(9),
    sourceSpecies character varying,
    CONSTRAINT species_pkey PRIMARY KEY (sourceSpecies)
);

COPY bc_0008.species (species_id, province, targetSpecies, sourceSpecies)
    FROM 'C:\Users\beacons\Dropbox (BEACONs)\PRV\github\cas\fri\bc_0008\species.csv' 
    WITH (FORMAT csv, HEADER, DELIMITER ',');

--SELECT * FROM bc_0008.species LIMIT 20;

SELECT objectid_1, crown_closure, species_cd_1, species_cd_2 INTO TABLE bc_0008.vri9b FROM bc_0008.vri9 LIMIT 20;
ALTER TABLE bc_0008.vri9b
  ADD CONSTRAINT vri_species 
  FOREIGN KEY (species_cd_1)
  REFERENCES bc_0008.species (sourceSpecies) 
  MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

SELECT vri9b.species_cd_1 AS source1, species.sourceSpecies AS source2, species.targetSpecies AS target 
    FROM bc_0008.species, bc_0008.vri9b 
    WHERE species.sourceSpecies = vri9b.species_cd_1;

--SELECT * FROM vri9b;