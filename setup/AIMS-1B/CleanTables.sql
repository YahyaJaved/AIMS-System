CREATE OR REPLACE FUNCTION CleanTables() RETURNS integer
AS $$
Declare

amount int := 1000;
	
Begin

delete from malicious_transactions_table;
delete from corrupted_transactions_table;
delete from blocked_transactions_table;
delete from blocked_tuples_status;
delete from avail_metric_table; 

Return Null;
END;
$$ LANGUAGE plpgsql;
