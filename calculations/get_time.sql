--SELECT EXTRACT(EPOCH FROM ((select max(end_rec_timestamp) + interval '4 hours' from avail_metric_table) - (select time_stamp from log_table    Order by time_stamp ASC LIMIT 1)));
SELECT EXTRACT(EPOCH FROM ((select time_stamp from log_table order by time_stamp DESC LIMIT 1) - (select time_stamp from log_table    Order by time_stamp ASC LIMIT 1)));

