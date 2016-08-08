CREATE or replace FUNCTION somefunc() RETURNS integer AS $$
DECLARE
    malicious_transaction xid := 0;
    ts_current timestamp := current_timestamp;
    ts_malicious timestamp := NULL; 
	 ts_dummy timestamp := NULL;

BEGIN

/*	delete from blocked_tuples_table; */
	
	ts_malicious := ts_current + interval '4 hours';
	ts_dummy := ts_malicious - interval '00:00:05.00000';

	select transaction_id into malicious_transaction 
	from log_table
	where time_stamp >= ts_dummy 
	LIMIT 1; 
    
	insert into blocked_transactions_table values (malicious_transaction, ts_malicious);

Return 0;
END;
$$ LANGUAGE plpgsql;

Begin;

select somefunc();

Commit;
