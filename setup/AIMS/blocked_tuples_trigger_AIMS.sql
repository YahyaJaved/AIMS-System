/*

This implements our AIMS damage containment algorithm. This in addition blocked_tuples_trigger (DTQR)
blocks only those tuples whose ibs are being attacked by the orginal malicious transaction, hence fewer
tuples are blocked if even if 4 / 5 ibs are attacked when there are 5 ibs. Rest of the concept is the
same as the blocked_tuples_trigger.

*/




CREATE OR REPLACE FUNCTION blocked_tuples_trigger_AIMS() RETURNS TRIGGER
AS $blocked_tuples_trigger_AIMS$
Declare

rec record;
malicious_transaction_id bigint := 0;
transaction_commit_time timestamp;
transaction_detection_time timestamp;
number_blocked_tuples int := 0;
	
Begin
-------------------------------------------------------------------------------------------
/* There is a possible race conditon between response and recovery system (blocked_tuples_trigger and mal_trg)
that if the mal_trg tries to generate dependencies before blocked_tuples_table is populated by the blocked_tuples_trigger
for a particular malicious_transaction then its possible that some of the incoming transactions (that try to read malicious tuples) pass through because blocked_tuples_table
is not populated yet while the dependency generation is underway simultaneously. Its possible that mal_trg passed the dependency generation  phase and after that it starts recovery. The transactions that pass would never get caught in this scenario. To serialize this I am creating locks that has the xid of the malicious transaction as the key */

perform pg_advisory_xact_lock(malicious_transaction_id);
--------------------------------------------------------------------------------------------

transaction_detection_time := new.detection_time_stamp;

-- No need to do it here as I am already adding 4 hours in the detection at mtx.sql
--transaction_detection_time := transaction_detection_time + interval '4 hours';

malicious_transaction_id := new.transaction_id;


-----------------------------------------------------------------------------------------------
--Finding the Commit Time of the malicious transaction
---This query did the same thing as below but not in an optimal fashion

--select l1.time_stamp into transaction_commit_time
--from log_table l1
--where l1.transaction_id = malicious_transaction_id and l1.time_stamp = (select min(l2.time_stamp)
--									from log_table l2
--									where l2.transaction_id = malicious_transaction_id and l2.operation <> 1);
-----------------------------------------------------------------------------------------------

/* Finding the commit time of the malicous transcation, here the time when the transction effectively starts is taken
so that the write set of the malicious transaction itself can be included in the blocked tuples table */ 
--VERIFIED

select time_stamp into transaction_commit_time
from log_table
where transaction_id = malicious_transaction_id
Order by time_stamp ASC
LIMIT 1;

------------------------------------------------------------------------------------------------
	
-- Generating the blocked tuples set of Peng Liu's model

/* Identifying the tuples modified between the commit and detection time of the malicious transaction under consideration */
-- Populating the temp_log_table for this malicous transaction as well
--VERIFIED
	
FOR rec IN
SELECT * 
FROM log_table 
Where time_stamp BETWEEN transaction_commit_time and transaction_detection_time 
	LOOP

	insert into temp_log_table values (malicious_transaction_id, rec.time_stamp, rec.transaction_id, rec.depends_on_transaction, rec.object_id, rec.operation, rec.tableid, rec.chk_id, rec.balance);

	IF rec.operation = 3 THEN
	insert into blocked_tuples_table_DTQR values (rec.object_id, malicious_transaction_id);
	END IF;
		
	END LOOP;

---------------------------------------------------------------------------------------------------

-- Generating the blocked tuples set for AIMS model

--Selecting the tuples modified by the malicious transactions 

FOR rec IN
SELECT * 
FROM log_table 
Where operation <> 1 and transaction_id = malicious_transaction_id 
	LOOP

	insert into temp_tuples_table_AIMS values (rec.object_id, malicious_transaction_id);

	END LOOP;

-----------------------------------------------------------------------------------------------------

/*
--Mapping between thamirs table ibd and ib_assignment_table here 

CREATE TEMP TABLE ib_assignment_table AS
Select R1.oid as object_id, I1.ib
From ibd I1, Randomdata R1
Where I1.object_id = R1.id;

*/

-------------------------------------------------------------------------------------------------------

--Selecting the ibs the malicious transactions write set belongs to

FOR rec IN
SELECT DISTINCT I1.ib
FROM ibd I1, temp_tuples_table_AIMS T1
where I1.object_id = T1.blocked_tuples
	LOOP
	
	insert into blocked_ibs values (rec.ib, malicious_transaction_id);

	END LOOP;

--------------------------------------------------------------------------------------------------------

--Select all of the tuples belonging to blocked_ibs in the blocked_tuples_table_AIMS

FOR rec IN
SELECT I1.object_id, I1.ib 
FROM ibd I1 
Where I1.ib IN (select ib
		from blocked_ibs
		where malicious_transaction = malicious_transaction_id)  
	LOOP

	insert into blocked_tuples_table_AIMS values (rec.object_id, malicious_transaction_id, rec.ib);

	END LOOP;

---------------------------------------------------------------------------------------------------------

--Populate the original blocked_tuples_table by taking the intersection between blocked_tuples_table_DTQR and blocked_tuples_table_AIMS

FOR rec IN
SELECT blocked_tuples, ib 
FROM blocked_tuples_table_AIMS 
Where malicious_transaction = malicious_transaction_id and blocked_tuples IN (select blocked_tuples
										from blocked_tuples_table_DTQR
										where malicious_transaction = malicious_transaction_id)  
	LOOP

	insert into AIMS_blocked_tuples_table values (rec.blocked_tuples, malicious_transaction_id, transaction_detection_time, NULL, rec.ib);

	END LOOP;

-----------------------------------------------------------------------------------------------------------

--Delete temporary tables

--delete from temp_tuples_table_AIMS;
--delete from blocked_tuples_table_DTQR;
--delete from blocked_tuples_table_AIMS;
--drop table ib_assignment_table;
--drop table blocked_ibs;

Return Null;
END;
$blocked_tuples_trigger_AIMS$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS blocked_tuples_trigger_AIMS on blocked_transactions_table;
CREATE TRIGGER blocked_tuples_trigger_AIMS
AFTER INSERT ON blocked_transactions_table
    FOR EACH ROW EXECUTE PROCEDURE blocked_tuples_trigger_AIMS();
