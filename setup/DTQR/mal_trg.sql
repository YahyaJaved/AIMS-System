/*

This trigger activates the the response and recovery system.
It activates the lock for the transaction control in the response system aswell
and also populates the avail_metric_table for the calculation of the avialability 
performance metric.

*/


CREATE OR REPLACE FUNCTION mal_trg() RETURNS TRIGGER
AS $mal_trg$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := NULL;
wait float := 0;
number_blocked_tuples int := 0;
tuples_unrecovered int := 0;
recover_time float := NULL;
transaction_commit_time timestamp; 

avail_time float := NULL;
total_touched_tuples int := 0;
	
Begin

raise notice 'AIMS Recovery System has Started';


select count(distinct blocked_tuples) into tuples_unrecovered
from blocked_tuples_table
where recovery_timestamp IS NULL; 

insert into blocked_tuples_status values (tuples_unrecovered, new.detection_time_stamp,  new.transaction_id);


/* Advisory Lock for Transaction Control */
perform pg_advisory_xact_lock(1);

/* Advisory Lock for Suspicious Transactions */
--perform pg_advisory_xact_lock(2);

-- POPULATE THE ACTIVE TRANSACTIONS TABLE FOR SUSPICIOUS TRANSACTION MANAGEMENT

FOR rec IN
SELECT backend_xid 
From pg_stat_activity
where state = 'active'
	LOOP

	insert into active_transactions_table values (rec.backend_xid);

	END LOOP;

/* Wait for sometime proportional to the number of tuples blocked */

--wait := number_blocked_tuples / 67.3;

--perform pg_sleep(wait);

/* ACTIVATE THE RECOVERY SYSTEM */

select txid_current() into t_current;

insert into corrupted_transactions_table values (new.transaction_id, new.detection_time_stamp);
	
FOR rec IN
SELECT DISTINCT transaction_id 
FROM log_table 
Where depends_on_transaction = new.transaction_id and time_stamp < new.detection_time_stamp
	LOOP

	insert into corrupted_transactions_table values (rec.transaction_id, ts_current);

	END LOOP;

/*** Populate the availability metric table ***/

/* Count blocked number of tuples */

select count(*) into number_blocked_tuples
from blocked_tuples_table
where malicious_transaction = new.transaction_id;

-- Count number of accessed tuples till now

select count(DISTINCT object_id) into total_touched_tuples
from log_table;

ts_current := clock_timestamp();

/* Time difference handle */

ts_current := ts_current; 

SELECT EXTRACT(EPOCH FROM (ts_current - new.detection_time_stamp)) into recover_time;

-- calculate the avail time 

avail_time := total_touched_tuples - number_blocked_tuples; -- total number of available tuples for this attack
avail_time := avail_time / total_touched_tuples;  -- ratio of the available tuples with the total tuples touched
avail_time := avail_time * recover_time; -- multiply the ratio of the available tuples with the time those tuples were available call it X

-- Checks for zero tuples blocked

IF number_blocked_tuples = 0 then 
	recover_time := 0;
	avail_time := 0;
END IF;

-- Insert values into avail_metric_table
insert into avail_metric_table values (new.transaction_id, number_blocked_tuples, recover_time, avail_time,new.detection_time_stamp,clock_timestamp());


--delete from blocked_tuples_table
--where malicious_transaction = new.transaction_id;

/* Release the tuples that are recovered */
/* Log the time when the tuples were released in the blocked_transctions_table */

select count(distinct blocked_tuples) into tuples_unrecovered
from blocked_tuples_table
where recovery_timestamp IS NULL;


insert into blocked_tuples_status values (tuples_unrecovered, ts_current,  new.transaction_id);

update blocked_tuples_table set recovery_timestamp = ts_current
where malicious_transaction = new.transaction_id;

/****** Populate the blocked_tuples_status table *******/

--select count(distinct blocked_tuples) into tuples_unrecovered
--from blocked_tuples_table
--where recovery_timestamp = NULL; 


--insert into blocked_tuples_status values (tuples_unrecovered, ts_current,  new.transaction_id);

/*
select txid_current() into t_current;

insert into corrupted_transactions_table values (new.transaction_id, new.detection_time_stamp);
	
FOR rec IN
SELECT DISTINCT transaction_id 
FROM dependency_table 
Where depends_on_transaction = new.transaction_id
	LOOP

	insert into corrupted_transactions_table values (rec.transaction_id, ts_current);

	END LOOP;
*/


raise notice 'AIMS Recovery System has Completed Recovery';

Return Null;
END;
$mal_trg$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS mal_trg on malicious_transactions_table;
CREATE TRIGGER mal_trg
AFTER INSERT ON malicious_transactions_table
    FOR EACH ROW EXECUTE PROCEDURE mal_trg();
