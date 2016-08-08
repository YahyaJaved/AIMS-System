delete from log_table;
delete from dependency_table;
delete from corrupted_transactions_table;
delete from malicious_transactions_table;
delete from repair_table;
delete from blocked_tuples_table;
delete from blocked_transactions_table;
delete from avail_metric_table;
delete from active_transactions_table;
delete from temp_tuples_table_AIMS;
delete from blocked_tuples_table_DTQR;
delete from blocked_tuples_table_AIMS;

/* Vacuuming the backup tables, delete every version of the table that is one hour old */

delete  
from country_backup
where mod_time < clock_timestamp() - interval '1 hour'
and tuple_id in (select tuple_id from country_backup Group by tuple_id having count(*) > 1);

delete  
from branch_backup
where mod_time < clock_timestamp() - interval '1 hour'
and tuple_id in (select tuple_id from branch_backup Group by tuple_id having count(*) > 1);

delete  
from customer_backup
where mod_time < clock_timestamp() - interval '1 hour'
and tuple_id in (select tuple_id from customer_backup Group by tuple_id having count(*) > 1);

delete  
from account_backup
where mod_time < clock_timestamp() - interval '1 hour'
and tuple_id in (select tuple_id from account_backup Group by tuple_id having count(*) > 1);

delete  
from checking_backup
where mod_time < clock_timestamp() - interval '1 hour'
and tuple_id in (select tuple_id from checking_backup Group by tuple_id having count(*) > 1);

delete  
from saving_backup
where mod_time < clock_timestamp() - interval '1 hour'
and tuple_id in (select tuple_id from saving_backup Group by tuple_id having count(*) > 1);

--delete from country_backup;
--delete from branch_backup;
--delete from customer_backup;
--delete from account_backup;
--delete from checking_backup;
--delete from saving_backup;

