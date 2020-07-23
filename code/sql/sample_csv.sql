-- Function to load a csv file
-- https://stackoverflow.com/questions/17662631/how-to-copy-from-csv-file-to-postgresql-table-with-headers-in-csv-file
-- Works well but doesn't necessarily create appropriate field types

create or replace function load_csv_file
    (
        target_table  text, -- name of the table that will be created
        csv_file_path text,
        col_count     integer
    )

returns void as $$

declare
    iter      integer; -- dummy integer to iterate columns with
    col       text; -- to keep column names in each iteration
    col_first text; -- first column name, e.g., top left corner on a csv file or spreadsheet

begin
    set schema 'bc_0008';

    create table temp_table ();

    -- add just enough number of columns
    for iter in 1..col_count
    loop
        execute format ('alter table temp_table add column col_%s text;', iter);
    end loop;

    -- copy the data from csv file
    execute format ('copy temp_table from %L with delimiter '','' quote ''"'' csv ', csv_file_path);

    iter := 1;
    col_first := (select col_1 from temp_table limit 1);

    -- update the column names based on the first row which has the column names
    for col in execute format ('select unnest(string_to_array(trim(temp_table::text, ''()''), '','')) from temp_table where col_1 = %L', col_first)
    loop
        execute format ('alter table temp_table rename column col_%s to %s', iter, col);
        iter := iter + 1;
    end loop;

    -- delete the columns row // using quote_ident or %I does not work here!?
    execute format ('delete from temp_table where %s = %L', col_first, col_first);

    -- change the temp table name to the name given as parameter, if not blank
    if length (target_table) > 0 then
        execute format ('alter table temp_table rename to %I', target_table);
    end if;
end;

$$ language plpgsql;

SELECT load_csv_file('test1', 'C:\Users\beacons\Dropbox (BEACONs)\PRV\github\cas\fri\bc_0008\species.csv', 4)
