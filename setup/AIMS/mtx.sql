CREATE OR REPLACE FUNCTION alertMTxn(etxid bigint,ts_current timestamp)
    RETURNS void AS $$
DECLARE
    dummy bigint := etxid;
--     ts_current timestamp := current_timestamp;
    t_current bigint := cast(txid_current() as bigint);
BEGIN
	ts_current := ts_current + interval '4 hours';
  insert into malicious_transactions_table values (dummy, ts_current,t_current);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION blockTxn(etxid bigint,ts_current timestamp)
    RETURNS void AS $$
DECLARE
    dummy bigint := etxid;
--     ts_current timestamp := current_timestamp;
    t_current bigint := cast(txid_current() as bigint);
BEGIN
	ts_current := ts_current + interval '4 hours';
  insert into blocked_transactions_table values (dummy, ts_current,t_current);
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------
/*
CREATE OR REPLACE FUNCTION block()
    RETURNS void AS $$
DECLARE
    dummy bigint := 26029;
		 ts_current timestamp := current_timestamp;
    t_current bigint := cast(txid_current() as bigint);
BEGIN
	ts_current := ts_current + interval '7 hours';
  insert into blocked_transactions_table values (dummy, ts_current,t_current);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION mal()
    RETURNS void AS $$
DECLARE
    dummy bigint := 26029;
		 ts_current timestamp := current_timestamp;
    t_current bigint := cast(txid_current() as bigint);
BEGIN
	ts_current := ts_current + interval '7 hours';
  insert into malicious_transactions_table values (dummy, ts_current,t_current);
END;
$$ LANGUAGE plpgsql;

*/
--------------------------------------------------------------------------------
