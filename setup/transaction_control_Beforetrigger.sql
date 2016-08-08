/*

Transaction control after trigger is fired for each transaction and it suspends all those 
transactions whose read set has blocked tuples in the blocked tuples table. Once the recovery is done for
those blocked tuples these transactions are then allowed to execute. Temporal oredering is insured for the re-execution 
of the suspended transactions.

*/



CREATE OR REPLACE FUNCTION transaction_control_Beforetrigger() RETURNS TRIGGER
AS $transaction_control_Beforetrigger$
Declare

flag oid := NULL;
rec record;
t_current xid;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Transaction Locking and Suspension */	

/* IF the read set of the transaction has any tuple common with the blocked tuples table's unrecovered table
 i.e. the tuples recovery_timestap in the blocked_tuples_table is NULL then suspend the transaction until 
the tuple is recovered */  

SELECT l1.object_id into flag
FROM log_table l1, blocked_tuples_table b1 
Where l1.object_id = b1.blocked_tuples and l1.transaction_id = t_current and b1.recovery_timestamp = NULL
LIMIT 1; 
If NOT FOUND Then
		raise notice 'Everything Fine';
ELSE 
		raise notice '--AIMS Response System Message--';
		raise notice 'transaction: % has been suspended', t_current;

/* Advisory Lock */
		perform pg_advisory_xact_lock(1);

		raise notice '--AIMS Response System Message--';
		raise notice 'transaction: % has resumed execution', t_current;
	
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
END IF;

Return Null;
END;
$transaction_control_Beforetrigger$ LANGUAGE plpgsql;

--CREATE TRIGGER transaction_control_Beforetrigger
--BEFORE UPDATE ON Randomdata
  --FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();

DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_country on COUNTRY;

CREATE TRIGGER transaction_control_Beforetrigger_country
BEFORE UPDATE ON COUNTRY
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_branch on BRANCH;
CREATE TRIGGER transaction_control_Beforetrigger_branch
BEFORE UPDATE ON BRANCH
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_customer on CUSTOMER;
CREATE TRIGGER transaction_control_Beforetrigger_customer
BEFORE UPDATE ON CUSTOMER
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();

DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_account on ACCOUNT;

CREATE TRIGGER transaction_control_Beforetrigger_account
BEFORE UPDATE ON ACCOUNT
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();

DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_checking on CHECKING;
CREATE TRIGGER transaction_control_Beforetrigger_checking
BEFORE UPDATE ON CHECKING
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();

DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_saving on SAVING;
CREATE TRIGGER transaction_control_Beforetrigger_saving
BEFORE UPDATE ON SAVING
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Beforetrigger();
