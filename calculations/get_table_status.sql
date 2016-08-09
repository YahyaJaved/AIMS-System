copy (select * from blocked_tuples_status order by status_timestamp asc) to '/var/lib/postgresql/blk_counter.csv' with delimiter ',' csv;
