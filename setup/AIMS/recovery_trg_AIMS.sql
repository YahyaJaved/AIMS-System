/*

This trigger fires up when an insertion is made in the repair_table.
Rapir table has the oids of the tuples that need to be rolled back to the version 
prior to the attack that is the commit time of the malicious transaction. The procedure
picks up the appropriate version of the tuple from the versions table and update the original table
with the correct version of the of the tuple not affected by the malicious transaction. 

*/

CREATE OR REPLACE FUNCTION recovery_trigger() RETURNS TRIGGER
AS $recovery_trigger$
Declare

rec record;
ts_current timestamp := current_timestamp;
dummy bigint := NULL;
tbl_var text := NULL;
	
Begin

tbl_var := new.relation_name;

/*
IF tbl_var = 'randomdata' THEN 

	select id into dummy
	from randomdata_backup
	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
	from randomdata_backup
	where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions));
	IF NOT FOUND THEN
    	delete from randomdata where oid = new.corrupted_tuples_oid;
	END IF;
	
	FOR rec IN
	select *
	from randomdata_backup
	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
									from randomdata_backup
									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions))
	LOOP

	UPDATE randomdata 
	SET id = rec.id, fname = rec.fname, lname = rec.lname, bname = rec.bname, dob = rec.dob, ncars = rec.ncars, bankbalance = rec.bankbalance, addressline = rec.addressline, city = rec.city, zipcode = rec.zipcode, country = rec.country 
	WHERE oid = rec.tuple_id;

--EXECUTE format('UPDATE %I SET id = %s, fname = %s, lname = %s, bname = %s, dob = %s, ncars = %s, bankbalance = %s, addressline = %s, city = %s, zipcode = %s, country = %s WHERE oid = %s', tbl_var, rec.id, rec.fname, rec.lname, rec.bname, rec.dob, rec.ncars, rec.bankbalance, rec.addressline, rec.city, rec.zipcode, rec.country, rec.tuple_id);

--EXECUTE format('UPDATE %I SET id = %s WHERE oid = %s', tbl_var, rec.id, rec.tuple_id);

--EXECUTE 'UPDATE' || quote_ident(tbl_var) || 'SET' || 'fname = '|| quote_ident(rec.fname) ||', lname = '|| quote_ident(rec.lname) ||', bname = '|| quote_ident(rec.bname) ||', addressline = '|| quote_ident(rec.addressline) ||', city = '|| quote_ident(rec.city) ||', zipcode = '|| quote_ident(rec.zipcode) ||', country = '|| quote_ident(rec.country) ||'WHERE oid = '|| quote_ident(rec.tuple_id) ;

	END LOOP;
END IF;
*/

----------------------------------------------------------------------------------------------------

-- IF tbl_var = 'country' THEN 
-- 
-- --For malicious insertion
-- 	select c_id into dummy
-- 	from country_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from country_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions));
-- 	IF NOT FOUND THEN
--     	--delete from country where oid = new.corrupted_tuples_oid;
-- 	UPDATE country 
-- 	SET c_id = c_id, c_name = c_name, c_dfreq = c_dfreq
-- 	WHERE oid = new.corrupted_tuples_oid;
-- 	END IF;
-- 
-- --For malicious update	
-- 	FOR rec IN
-- 	select *
-- 	from country_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from country_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions))
-- 	LOOP
-- 
-- 	UPDATE country 
-- 	SET c_id = rec.c_id, c_name = rec.c_name, c_dfreq = rec.c_dfreq
-- 	WHERE oid = rec.tuple_id;
-- 
-- 	END LOOP;
-- END IF;

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------

-- IF tbl_var = 'branch' THEN 
-- 
-- --For malicious insertion
-- 	select b_id into dummy
-- 	from branch_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from branch_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions));
-- 	IF NOT FOUND THEN
--     	--delete from branch where oid = new.corrupted_tuples_oid;
-- 	UPDATE branch 
-- 	SET b_id = b_id, b_c_id = b_c_id, b_saddress = b_saddress, b_zipcode = b_zipcode, b_rtotal_checking = b_rtotal_checking, b_rts_checking = b_rts_checking, b_rtotal_saving = b_rtotal_saving, b_rts_saving = b_rts_saving
-- 	WHERE oid = new.corrupted_tuples_oid;
-- 	END IF;
-- 
-- --For malicious update	
-- 	FOR rec IN
-- 	select *
-- 	from branch_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from branch_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions))
-- 	LOOP
-- 
-- 	UPDATE branch 
-- 	SET b_id = rec.b_id, b_c_id = rec.b_c_id, b_saddress = rec.b_saddress, b_zipcode = rec.b_zipcode, b_rtotal_checking = rec.b_rtotal_checking, b_rts_checking = rec.b_rts_checking, b_rtotal_saving = rec.b_rtotal_saving, b_rts_saving = rec.b_rts_saving
-- 	WHERE oid = rec.tuple_id;
-- 
-- 	END LOOP;
-- END IF;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- IF tbl_var = 'customer' THEN 
-- 
-- --For malicious insertion
-- 	select cust_id into dummy
-- 	from customer_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from customer_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions));
-- 	IF NOT FOUND THEN
--     	--delete from customer where oid = new.corrupted_tuples_oid;
-- 	UPDATE customer 
-- 	SET cust_id = cust_id, cust_fname = cust_fname, cust_lname = cust_lname, cust_dob = cust_dob, cust_saddress = cust_saddress, cust_zipcode = cust_zipcode, cust_curr_tx_count = cust_curr_tx_count, cust_total_tx_count = cust_total_tx_count, cust_rts_total_tx_count = cust_rts_total_tx_count
-- 	WHERE oid = new.corrupted_tuples_oid;
-- 	END IF;
-- 
-- --For malicious update	
-- 	FOR rec IN
-- 	select *
-- 	from customer_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from customer_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions))
-- 	LOOP
-- 
-- 	UPDATE customer 
-- 	SET cust_id = rec.cust_id, cust_fname = rec.cust_fname, cust_lname = rec.cust_lname, cust_dob = rec.cust_dob, cust_saddress = rec.cust_saddress, cust_zipcode = rec.cust_zipcode, cust_curr_tx_count = rec.cust_curr_tx_count, cust_total_tx_count = rec.cust_total_tx_count, cust_rts_total_tx_count = rec.cust_rts_total_tx_count
-- 	WHERE oid = rec.tuple_id;
-- 
-- 	END LOOP;
-- END IF;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- IF tbl_var = 'account' THEN 
-- 
-- --For malicious insertion
-- 	select a_id into dummy
-- 	from account_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from account_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions));
-- 	IF NOT FOUND THEN
--     	--delete from account where oid = new.corrupted_tuples_oid;
-- 	UPDATE account
-- 	SET a_id = a_id, a_cust_id = a_cust_id, a_b_id = a_b_id
-- 	WHERE oid = new.corrupted_tuples_oid;
-- 	END IF;
-- 
-- --For malicious update	
-- 	FOR rec IN
-- 	select *
-- 	from account_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from account_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions))
-- 	LOOP
-- 
-- 	UPDATE account
-- 	SET a_id = rec.a_id, a_cust_id = rec.a_cust_id, a_b_id = rec.a_b_id
-- 	WHERE oid = rec.tuple_id;
-- 
-- 	END LOOP;
-- END IF;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

IF tbl_var = 'checking' THEN 

--For malicious update	
	FOR rec IN
	select *
	from log_table
	where object_id = new.corrupted_tuples_oid and operation <> 1  and transaction_id <> new.corrupted_transactions
	Order by time_stamp DESC
	LIMIT 1 
	LOOP

	If rec.operation = 2 then
		-- Insert only. Delete the row. Currently I am doing nothing as it can disturb the experimentation
		UPDATE checking 
		SET chk_id = chk_id, balance = balance
		WHERE oid = rec.object_id;			

	Elsif rec.operation = 3 then 
		UPDATE checking 
		SET chk_id = rec.chk_id, balance = rec.balance
		WHERE oid = rec.object_id;
	End If;

	END LOOP;
END IF;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- IF tbl_var = 'saving' THEN 
-- 
-- --For malicious insertion
-- 	select sav_a_id into dummy
-- 	from saving_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from saving_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions));
-- 	IF NOT FOUND THEN
--     	--delete from saving where oid = new.corrupted_tuples_oid;
-- 	UPDATE saving 
-- 	SET sav_a_id = sav_a_id, sav_balance = sav_balance
-- 	WHERE oid = new.corrupted_tuples_oid;
-- 	END IF;
-- 
-- --For malicious update	
-- 	FOR rec IN
-- 	select *
-- 	from saving_backup
-- 	where tuple_id = new.corrupted_tuples_oid and mod_time = (select max(mod_time)
-- 									from saving_backup
-- 									where tuple_id = new.corrupted_tuples_oid and not (mod_transaction = new.corrupted_transactions))
-- 	LOOP
-- 
-- 	UPDATE saving 
-- 	SET sav_a_id = rec.sav_a_id, sav_balance = rec.sav_balance
-- 	WHERE oid = rec.tuple_id;
-- 
-- 	END LOOP;
-- END IF;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

raise notice '--------------------------------------------------------';
raise notice 'AIMS Recovery System has Completed the Recovery Process';
raise notice '--------------------------------------------------------';

Return Null;
END;
$recovery_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS recovery_trigger on repair_table;

CREATE TRIGGER recovery_trigger
AFTER INSERT ON repair_table
    FOR EACH ROW EXECUTE PROCEDURE recovery_trigger();
