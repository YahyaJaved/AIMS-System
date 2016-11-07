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
rec1 record;
t_current bigint;
t_xmin bigint := 0;
rec_finish timestamp := NULL;
wait float := 0;
number_blocked_tuples int := 0;
tuples_unrecovered int := 0;
recover_time float := NULL;
detection_time timestamp;
mal_commit_time timestamp; 
clock_timestamp timestamp;
rec_start timestamp := NULL;

avail_time float := NULL;
total_touched_tuples int := 0;
	
Begin

raise notice 'AIMS Recovery System has Started';

/* For race condition between response and recovery system, this is a check to prevent the possibility */
-- To make sure response system aquires this lock first
perform pg_sleep(0.1);
perform pg_advisory_xact_lock(new.transaction_id);

-- Logging the blocked_tuples status , it actually models the arrival and departure from blocked_tuples_table a.k.a B-vector or B-queue
-- << VERIFIED >>
select count(distinct blocked_tuples) into tuples_unrecovered
from AIMS_blocked_tuples_table
where recovery_timestamp IS NULL; 

rec_start := clock_timestamp();

/* Time difference handle for discrepancy between detection time and current_time  */

rec_start := rec_finish + interval '4 hours';

insert into blocked_tuples_status values (tuples_unrecovered, rec_start,  new.transaction_id);


/* Advisory Lock for Transaction Control, lock for each blocked ib */
FOR rec IN
SELECT ib
from blocked_ibs
where malicious_transaction = new.transaction_id
Loop
perform pg_advisory_xact_lock(rec.ib);
End loop;


/* Advisory Lock for Suspicious Transactions */
--perform pg_advisory_xact_lock(2);

/*
-------------------------------------------------------------
-- POPULATE THE ACTIVE TRANSACTIONS TABLE FOR SUSPICIOUS TRANSACTION MANAGEMENT

FOR rec IN
SELECT backend_xid 
From pg_stat_activity
where state = 'active'
	LOOP

	insert into active_transactions_table values (rec.backend_xid);

	END LOOP;
*/

--------------------------------------------------------------
/* Wait for sometime proportional to the number of tuples blocked */

--wait := number_blocked_tuples / 67.3;

--perform pg_sleep(wait);
--------------------------------------------------------------

raise notice 's1';

/* ACTIVATE THE RECOVERY SYSTEM */

select txid_current() into t_current;

---MADE CHANGES TO MTX.SQL, THE INSERTED TIME THERE IS ALREADY 4 HOURS AHEAD
---detection_time := new.detection_time_stamp + interval '4 hours'; 
--- mal_commit_time is log_table time which is 4 hours ahead of system time  
--- << VERIFIED >>
select time_stamp into mal_commit_time
from log_table
where transaction_id = new.transaction_id
Order by time_stamp ASC
LIMIT 1;

-- << VERIFIED >>
insert into corrupted_transactions_table values (new.transaction_id, new.detection_time_stamp, mal_commit_time, 'malicious');

raise notice 's2';
--------------------------------------------------

-- Find the affected transactions
-- << VERIFIED >>
	
FOR rec IN
SELECT DISTINCT transaction_id 
FROM temp_log_table 
Where depends_on_transaction = new.transaction_id
	LOOP

	insert into corrupted_transactions_table values (rec.transaction_id, new.detection_time_stamp, mal_commit_time, 'affected');
	
	For rec1 IN
	SELECT DISTINCT transaction_id 
	FROM temp_log_table 
	Where depends_on_transaction = rec.transaction_id
		Loop
			insert into corrupted_transactions_table values (rec1.transaction_id, new.detection_time_stamp, mal_commit_time, 'affected');
		END loop;

	END LOOP;

-----------------------------------------------------------------------------------------------------
-- << VERIFIED >> the whole avail metric module

/*** Populate the availability metric table ***/

/* Count blocked number of tuples */

select count(DISTINCT blocked_tuples) into number_blocked_tuples
from AIMS_blocked_tuples_table
where malicious_transaction = new.transaction_id;

-- Count number of accessed tuples till now

select count(DISTINCT object_id) into total_touched_tuples
from log_table;

rec_finish := clock_timestamp();

/* Time difference handle for discrepancy between detection time and current_time  */

rec_finish := rec_finish + interval '4 hours'; 

SELECT EXTRACT(EPOCH FROM (rec_finish - rec_start)) into recover_time;

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
insert into avail_metric_table values (new.transaction_id, number_blocked_tuples, recover_time, avail_time, rec_start, rec_finish);

----------------------------------------------------------------------------------------------------

-- I removed this statment because we didn't wanted to lose any information about the number of tuples blocked and recovered in the blocked tuples table, otherwise this delete statement was not creating any problems in the consistency and working of the recovery system
--delete from blocked_tuples_table
--where malicious_transaction = new.transaction_id;

----------------------------------------------------------------------------------------------------

/* Release the tuples that are recovered */
/* Log the time when the tuples were released in the blocked_transctions_table */

-- Update the block tuples table and freeing the recoverd tuples 
-- << VERIFIED >>
update blocked_tuples_table set recovery_timestamp = rec_finish
where malicious_transaction = new.transaction_id;

-- logging the number of unrecovered tuples (from other malicious transactions) after the recovery system has completed recovery for this malicious transaction 
-- << VERIFIED >>
select count(distinct blocked_tuples) into tuples_unrecovered
from AIMS_blocked_tuples_table
where recovery_timestamp IS NULL;

/* 07-11-16
-- Compatibility with the log_table
-- << VERIFIED >>
clock_timestamp := clock_timestamp() + interval '4 hours';
*/

insert into blocked_tuples_status values (tuples_unrecovered, rec_finish,  new.transaction_id);

----------------------------------------------------------------------------------------------------

/*****************************************************/

/* Clean the temp_log_table */

--This delete is not creating any consistency issues because its only deleting its part of table identified by the mal txn xid
-- << VERIFIED >>
delete from temp_log_table where reference_txn = new.transaction_id;

/*****************************************************/


raise notice 'AIMS Recovery System has Completed Recovery';

Return Null;
END;
$mal_trg$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS mal_trg on malicious_transactions_table;
CREATE TRIGGER mal_trg
AFTER INSERT ON malicious_transactions_table
    FOR EACH ROW EXECUTE PROCEDURE mal_trg();
