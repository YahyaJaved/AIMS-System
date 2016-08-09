copy (select * from avail_metric_table order by detection_timestamp asc) to '/var/lib/postgresql/avail.csv' with delimiter ',' csv;
