/*

Blocked tuples trigger gets fired when an insertion is made in the blocked transactions table.
It puts all the tuples being modified between the commit time of the malicious transaction and
time stamp of detection in the blocked tuples table which is used by the transaction control before trigger 
for transaction suspension if the read set of a transaction has the tuples in the blocked tuples table.
 
*/



CREATE OR REPLACE FUNCTION blocked_tuples_trigger() RETURNS TRIGGER
AS $blocked_tuples_trigger$
Declare

rec record;
malicious_transaction_id bigint := 0;
transaction_commit_time timestamp;
transaction_detection_time timestamp;
number_blocked_tuples int := 0;
	
Begin
---------------------------------------------------------------------------------------------
/* There is a possible race conditon between response and recovery system (blocked_tuples_trigger and mal_trg)
that if the mal_trg tries to generate dependencies before blocked_tuples_table is populated by the blocked_tuples_trigger
for a particular malicious_transaction then its possible that some of the incoming transactions (that try to read malicious tuples) pass through because blocked_tuples_table
is not populated yet while the dependency generation is underway simultaneously. Its possible that mal_trg passed the dependency generation  phase and after that it starts recovery. The transactions that pass would never get caught in this scenario. To serialize this I am creating locks that has the xid of the malicious transaction as the key */

perform pg_advisory_xact_lock(malicious_transaction_id);
---------------------------------------------------------------------------------------------

transaction_detection_time := new.detection_time_stamp;

-- No need to do it here as I am already adding 4 hours in the detection at mtx.sql
--transaction_detection_time := transaction_detection_time + interval '4 hours';

malicious_transaction_id := new.transaction_id;

----------------------------------------------------------------------------------------------
---This query did the same thing as below but not in an optimal fashion

--select l1.time_stamp into transaction_commit_time
--from log_table l1
--where l1.transaction_id = malicious_transaction_id and l1.time_stamp = (select min(l2.time_stamp)
--																								from log_table l2
--																								where l2.transaction_id = malicious_transaction_id and l2.operation <> 1);
----------------------------------------------------------------------------------------------


/* Finding the commit time of the malicous transcation, here the time when the transction effectively starts is taken
so that the write set of the malicious transaction itself can be included in the blocked tuples table */ 
--VERIFIED

select time_stamp into transaction_commit_time
from log_table
where transaction_id = malicious_transaction_id
Order by time_stamp ASC
LIMIT 1;

------------------------------------------------------------------------------------------------

/* Identifying the tuples modified between the commit and detection time of the malicious transaction under consideration */
--VERIFIED
	
FOR rec IN
SELECT * 
FROM log_table 
Where time_stamp BETWEEN transaction_commit_time and transaction_detection_time 
	LOOP

	insert into temp_log_table values (malicious_transaction_id, rec.time_stamp, rec.transaction_id, rec.depends_on_transaction, rec.object_id, rec.operation, rec.tableid, rec.chk_id, rec.balance);

	IF rec.operation = 3 THEN
	insert into blocked_tuples_table values (rec.object_id, malicious_transaction_id, transaction_detection_time, NULL);
	END IF;
		
	END LOOP;

----------------------------------------------------------------------------------------------------

Return Null;
END;
$blocked_tuples_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS blocked_tuples_trigger on blocked_transactions_table;

CREATE TRIGGER blocked_tuples_trigger
AFTER INSERT ON blocked_transactions_table
    FOR EACH ROW EXECUTE PROCEDURE blocked_tuples_trigger();
