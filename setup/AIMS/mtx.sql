CREATE OR REPLACE FUNCTION alertMTxn(etxid bigint)
    RETURNS void AS $$
DECLARE
    dummy xid := etxid;
    ts_current timestamp := current_timestamp;
    t_current xid := txid_current();
BEGIN
  insert into malicious_transactions_table(transaction_id, detection_time_stamp,rec_transaction_id) 
        values (dummy, ts_current,t_current);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION blockTxn(etxid bigint)
    RETURNS void AS $$
DECLARE
    dummy xid := etxid;
    ts_current timestamp := current_timestamp;
    t_current xid := txid_current();
BEGIN
  insert into blocked_transactions_table values (dummy, ts_current,t_current);
END;
$$ LANGUAGE plpgsql;
