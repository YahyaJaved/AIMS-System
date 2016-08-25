/*

Transaction control after trigger is responsible for the management of the suspicious transactions.
It doesnot allow those transactions to commit whose ids are in the active transactions table, because those
transactions are considered as suspicious transactions. Once the recovery procedure is complete then these
transactions are allowed to commit and their changes are made visible to the whole DB. We make use of the MVCC
feature of the postgres and synchronization and consitency is achieved using the temporal ordering of the transactions
and inherent synchronization properties of the MVCC.

*/


CREATE OR REPLACE FUNCTION transaction_control_Aftertrigger() RETURNS TRIGGER
AS $transaction_control_Aftertrigger$
Declare

flagxid xid := NULL;
rec record;
t_current xid;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Transaction Locking and Suspension */


--The read set of the transaction, if read set has any tuple common with the blocked tuples table

SELECT transaction_id into flagxid
FROM active_transactions_table 
Where transaction_id = t_current
LIMIT 1; 
If NOT FOUND Then
		raise notice 'Everything Fine';
ELSE 
		raise notice '--AIMS Response System Message--';
		raise notice 'Active transaction: % has been marked as suspicious', t_current;

/* Advisory Lock */
		perform pg_advisory_xact_lock(1);

		raise notice '--AIMS Response System Message--';
		raise notice 'transaction: % has been identified as benign', t_current;
	
/* Read Select Tuples for this transaction here again as this transaction has read the corrupted tuples

		FOR rec IN
		SELECT l1.object_id
		FROM log_table l1
		Where l1.transaction_id = t_current and l1.operation = 1
			LOOP

			perform * 
			from Randomdata
			where oid = rec.object_id;

			END LOOP;

*/

END IF;

Return Null;
END;
$transaction_control_Aftertrigger$ LANGUAGE plpgsql;

--CREATE TRIGGER transaction_control_Aftertrigger
--AFTER UPDATE ON Randomdata
--  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();

-- DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_country on COUNTRY;
-- 
-- CREATE TRIGGER transaction_control_Aftertrigger_country
-- AFTER UPDATE ON COUNTRY
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();
-- 
-- DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_branch on BRANCH;
-- CREATE TRIGGER transaction_control_Aftertrigger_branch
-- AFTER UPDATE ON BRANCH
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();
-- DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_customer on CUSTOMER;
-- CREATE TRIGGER transaction_control_Aftertrigger_customer
-- AFTER UPDATE ON CUSTOMER
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();
-- 
-- DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_account on ACCOUNT;
-- CREATE TRIGGER transaction_control_Aftertrigger_account
-- AFTER UPDATE ON ACCOUNT
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();

DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_checking on CHECKING;

CREATE TRIGGER transaction_control_Aftertrigger_checking
AFTER UPDATE ON CHECKING
  FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();


-- DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_saving on SAVING;
-- 
-- CREATE TRIGGER transaction_control_Aftertrigger_saving
-- AFTER UPDATE ON SAVING
--   FOR EACH STATEMENT EXECUTE PROCEDURE transaction_control_Aftertrigger();
