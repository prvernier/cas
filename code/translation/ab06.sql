-- Summarize attributes

-- Count number of rows
select count(*) from ab.ab_0006;

-- List 20 rows
select density, height, sp1, sp1_per, sp2, sp2_per, sp3, sp3_per, sp4, sp4_per, sp5, sp5_per from ab.ab_0006 limit 20;

-- Crown closure
select density, count(*) from ab.ab_0006 group by density order by density;

-- Height
select height, count(*) from ab.ab_0006 group by height order by height;

-- Species
select sp1, count(*) from ab.ab_0006 group by sp1 order by sp1;

-- Species percent
select sp1_per, count(*) from ab.ab_0006 group by sp1_per order by sp1_per;

-- Unique combinations of species and percent
select sp1, sp1_per, count(*) from ab.ab_0006 group by sp1, sp1_per order by sp1, sp1_per;
