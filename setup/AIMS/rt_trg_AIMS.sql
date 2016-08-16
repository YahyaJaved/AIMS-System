/*
This trigger identifies the tuples modified by the malicious and the affected transactions
(collectively called as corrupted transactions) and then populates the repair table.
*/

CREATE OR REPLACE FUNCTION rt_trigger() RETURNS TRIGGER
AS $rt_trigger$
Declare

rec record;
ts_current timestamp := current_timestamp;
table_name regclass := NULL; 

	
Begin
	
FOR rec IN
SELECT * 
FROM log_table 
Where transaction_id = new.transaction_id and operation <> 1
	LOOP

	select relname into table_name 
	from pg_class where oid = rec.tableid;

	insert into repair_table values (new.IDS_transaction, rec.object_id, rec.time_stamp, rec.transaction_id, table_name);

	END LOOP;

Return Null;
END;
$rt_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS rt_trigger on corrupted_transactions_table_AIMS;
CREATE TRIGGER rt_trigger
AFTER INSERT ON corrupted_transactions_table_AIMS
    FOR EACH ROW EXECUTE PROCEDURE rt_trigger();
