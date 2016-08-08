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
malicious_transaction_id xid := 0;
transaction_commit_time timestamp;
transaction_detection_time timestamp;
number_blocked_tuples int := 0;
	
Begin

transaction_detection_time := new.detection_time_stamp;

transaction_detection_time := transaction_detection_time + interval '4 hours';

malicious_transaction_id := new.transaction_id;


raise notice 'malicious detection time: %', transaction_detection_time;

select l1.time_stamp into transaction_commit_time
from log_table l1
where l1.transaction_id = malicious_transaction_id and l1.time_stamp = (select max(l2.time_stamp)
																								from log_table l2
																								where l2.transaction_id = malicious_transaction_id and l2.operation <> 1);


raise notice 'malicious commit time: %', transaction_commit_time;
	
FOR rec IN
SELECT * 
FROM log_table 
Where operation <> 1 and time_stamp BETWEEN transaction_commit_time and transaction_detection_time 
	LOOP

	insert into blocked_tuples_table values (rec.object_id, malicious_transaction_id, transaction_detection_time, NULL);

	END LOOP;


Return Null;
END;
$blocked_tuples_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS blocked_tuples_trigger on blocked_transactions_table;

CREATE TRIGGER blocked_tuples_trigger
AFTER INSERT ON malicious_transactions_table
    FOR EACH ROW EXECUTE PROCEDURE blocked_tuples_trigger();
