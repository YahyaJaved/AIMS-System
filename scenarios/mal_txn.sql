CREATE or replace FUNCTION somefunc() RETURNS integer AS $$
DECLARE
    malicious_transaction xid := 0;
    ts_current timestamp := current_timestamp;
    ts_malicious timestamp := NULL;    

BEGIN

	ts_malicious := ts_current + interval '4 hours';

	select transaction_id into malicious_transaction 
	from blocked_transactions_table; 

	select detection_time_stamp into ts_malicious 
	from blocked_transactions_table; 
    
	insert into malicious_transactions_table values (malicious_transaction, ts_malicious);

	delete from blocked_transactions_table;

Return 0;
END;
$$ LANGUAGE plpgsql;

Begin;

select somefunc();

select pg_sleep(3);

Commit;
