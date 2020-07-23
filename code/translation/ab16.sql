-- Summarize attributes

-- Count number of rows
select count(*) from ab.ab_0016;

-- List 20 rows
select crownclose, height, sp1, sp1_percnt, sp2, sp2_percnt, sp3, sp3_percnt, sp4, sp4_percnt, sp5, sp5_percnt from ab.ab_0016 limit 20;

-- Crown closure
select crownclose, count(*) from ab.ab_0016 group by crownclose order by crownclose;

-- Height
select height, count(*) from ab.ab_0016 group by height order by height;

-- Species
select sp1, count(*) from ab.ab_0016 group by sp1 order by sp1;

-- Species percent
select sp1_percnt, count(*) from ab.ab_0016 group by sp1_percnt order by sp1_percnt;

-- Unique combinations of species and percent
select sp1, sp1_percnt, count(*) from ab.ab_0016 group by sp1, sp1_percnt order by sp1, sp1_percnt;

select forest_id_2, count(*) from rawfri.ab16 group by forest_id_2 order by count desc

SELECT forest_id_2, count(forest_id_2)
FROM rawfri.ab16
GROUP BY forest_id_2
HAVING count(forest_id_2) > 1