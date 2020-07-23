-- Summarize attributes

-- Count number of rows
select count(*) from nb.nb_0001;

-- List 20 rows (lots of missing values!)
select l1cc, l1ht, l1s1, l1pr1, l1s2, l1pr2, l1s3, l1pr3, l1s4, l1pr4, l1s5, l1pr5 from nb.nb_0001 limit 20;

-- Crown closure
select l1cc, count(*) from nb.nb_0001 group by l1cc order by l1cc;

-- Height
select l1ht, count(*) from nb.nb_0001 group by l1ht order by l1ht;

-- Species
select l1s1, count(*) from nb.nb_0001 group by l1s1 order by l1s1;

-- Species percent
select l1pr1, count(*) from nb.nb_0001 group by l1pr1 order by l1pr1;

-- Unique combinations of species and percent
select l1s1, l1pr1, count(*) from nb.nb_0001 group by l1s1, l1pr1 order by l1s1, l1pr1;

-- Is feature_id unique?
select l1cc, count(*) from rawfri.nb01 group by l1cc having count(l1cc) > 1 order by count desc
select l1cc, count(*) from rawfri.nb01_rnd10k group by l1cc order by l1cc asc
SELECT forest_id_2, count(forest_id_2) FROM rawfri.ab16 GROUP BY forest_id_2 HAVING count(forest_id_2) > 1
