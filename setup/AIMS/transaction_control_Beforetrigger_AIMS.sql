/*

Transaction control after trigger is fired for each transaction and it suspends all those 
transactions whose read set has blocked tuples in the blocked tuples table. Once the recovery is done for
those blocked tuples these transactions are then allowed to execute. Temporal oredering is insured for the re-execution 
of the suspended transactions.

*/



CREATE OR REPLACE FUNCTION transaction_control_Beforetrigger_AIMS() RETURNS TRIGGER
AS $transaction_control_Beforetrigger_AIMS$
Declare

flag oid := NULL;
rec record;
t_current bigint;
ts_current1 timestamp;
ts_current2 timestamp;
	
Begin

select txid_current() into t_current;

/* Transaction Locking and Suspension */	

/* IF the read set of the transaction has any tuple common with the blocked tuples table's unrecovered table
 i.e. the tuples recovery_timestap in the blocked_tuples_table is NULL then suspend the transaction until 
the tuple is recovered */  

For rec in
SELECT DISTINCT b1.ib
FROM log_table l1, AIMS_blocked_tuples_table b1 
Where l1.object_id = b1.blocked_tuples and l1.transaction_id = t_current and b1.recovery_timestamp IS NULL
	Loop

/* Drop the lock you are holding for the tuples you are trying to update and rollback to the start */
--	rollback to savepoint start;

/* Check transaction status suspension time */
		ts_current1 := clock_timestamp();

		
/* Advisory Lock */
		perform pg_advisory_xact_lock(rec.ib);

/* Check transaction status resumption time */
		ts_current2 := clock_timestamp();
		--insert into benign_transaction_table values (t_current, ts_current1, ts_current2);
		select transaction_id into flag
		from benign_transaction_table
		where transaction_id = t_current
		limit 1;
		if not found then
			insert into benign_transaction_table values (t_current, ts_current1, ts_current2);
		else 
			update benign_transaction_table set resumption_time = ts_current2
			where transaction_id = t_current;
		
		end if;	
	
	END Loop;

/* Read Select Tuples for this transaction here again as this transaction has read the corrupted tuples

		FOR rec IN
		SELECT l1.object_id
		FROM log_table l1, blocked_tuples_table b1 
		Where l1.transaction_id = t_current and l1.operation = 1 and l1.object_id = b1.blocked_tuples
			LOOP

			perform * 
			from Randomdata
			where oid = rec.object_id;

			END LOOP;
*/
--insert into benign_transaction_status values (t_current, ts_current1, ts_current2);
Return Null;
END;
$transaction_control_Beforetrigger_AIMS$ LANGUAGE plpgsql;

--CREATE TRIGGER transaction_control_Beforetrigger_AIMS
--BEFORE UPDATE ON Randomdata
  --FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();

-- DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_AIMS_country on COUNTRY;
-- 
-- CREATE TRIGGER transaction_control_Beforetrigger_AIMS_country
-- BEFORE UPDATE ON COUNTRY
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();
-- DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_AIMS_branch on BRANCH;
-- CREATE TRIGGER transaction_control_Beforetrigger_AIMS_branch
-- BEFORE UPDATE ON BRANCH
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();
-- DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_AIMS_customer on CUSTOMER;
-- CREATE TRIGGER transaction_control_Beforetrigger_AIMS_customer
-- BEFORE UPDATE ON CUSTOMER
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();
-- 
-- DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_AIMS_account on ACCOUNT;
-- 
-- CREATE TRIGGER transaction_control_Beforetrigger_AIMS_account
-- BEFORE UPDATE ON ACCOUNT
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();

DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_AIMS_checking on CHECKING;
CREATE TRIGGER transaction_control_Beforetrigger_AIMS_checking
BEFORE UPDATE ON CHECKING
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();

-- DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_AIMS_saving on SAVING;
-- CREATE TRIGGER transaction_control_Beforetrigger_AIMS_saving
-- BEFORE UPDATE ON SAVING
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger_AIMS();
