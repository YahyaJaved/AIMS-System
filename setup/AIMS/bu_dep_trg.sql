



/*

BACKUP AND DEPENDENCY TRIGGER

This trigger gets fired for each transaction so it should be defined
for every table. This trigger performs two tasks: 
(i) It popuates the versions table (backup table) for recovery.
(ii) It generates the transaction dependency graph and data and data dependency graph
     by populating the dependency_table.
*/

/*

CREATE OR REPLACE FUNCTION dependency_trigger() RETURNS TRIGGER
AS $dependency_trigger$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

-- Backup Table Population

insert into randomdata_backup values (t_current, ts_current, new.oid, new.id, new.fname, new.lname, new.bname, new.dob, new.ncars, new.bankbalance, new.addressline, new.city, new.zipcode, new.country);

-- Dependency Generation	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from randomdata
	where oid = rec.object_id;

	insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);

	END LOOP;

Return Null;
END;
$dependency_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER dependency_trigger
AFTER INSERT OR UPDATE ON randomdata
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger();

*/

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dependency_trigger_country() RETURNS TRIGGER
AS $dependency_trigger_country$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Backup Table Population */

insert into country_backup values (t_current, ts_current, new.oid, new.c_id, new.c_name, new.c_dfreq);

/* Dependency Generation */	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from COUNTRY
	where oid = rec.object_id;
	
	IF t_xmin IS NOT NULL then
		insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);
	END IF;	
	END LOOP;

Return Null;
END;
$dependency_trigger_country$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS dependency_trigger_country on country;
CREATE TRIGGER dependency_trigger_country
AFTER INSERT OR UPDATE ON COUNTRY
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger_country();

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dependency_trigger_branch() RETURNS TRIGGER
AS $dependency_trigger_branch$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Backup Table Population */

insert into branch_backup values (t_current, ts_current, new.oid, new.b_id, new.b_c_id, new.b_saddress, new.b_zipcode, new.b_rtotal_checking, new.b_rts_checking, new.b_rtotal_saving, new.b_rts_saving);

/* Dependency Generation */	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from BRANCH
	where oid = rec.object_id;
	IF t_xmin IS NOT NULL then
		insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);
	END IF;	
	END LOOP;

Return Null;
END;
$dependency_trigger_branch$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS dependency_trigger_branch on branch;
CREATE TRIGGER dependency_trigger_branch
AFTER INSERT OR UPDATE ON BRANCH
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger_branch();

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dependency_trigger_customer() RETURNS TRIGGER
AS $dependency_trigger_customer$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Backup Table Population */

insert into customer_backup values (t_current, ts_current, new.oid, new.cust_id, new.cust_fname, new.cust_lname, new.cust_dob, new.cust_saddress, new.cust_zipcode, new.cust_curr_tx_count, new.cust_total_tx_count, new.cust_rts_total_tx_count);

/* Dependency Generation */	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from CUSTOMER
	where oid = rec.object_id;
	IF t_xmin IS NOT NULL then
		insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);
	END IF;	
	END LOOP;

Return Null;
END;
$dependency_trigger_customer$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS dependency_trigger_customer on customer;
CREATE TRIGGER dependency_trigger_customer
AFTER INSERT OR UPDATE ON CUSTOMER
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger_customer();

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dependency_trigger_account() RETURNS TRIGGER
AS $dependency_trigger_account$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Backup Table Population */

insert into account_backup values (t_current, ts_current, new.oid, new.a_id, new.a_cust_id, new.a_b_id);

/* Dependency Generation */	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from ACCOUNT
	where oid = rec.object_id;
	IF t_xmin IS NOT NULL then	
		insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);
	END IF;	
	
	END LOOP;

Return Null;
END;
$dependency_trigger_account$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS dependency_trigger_account on account;
CREATE TRIGGER dependency_trigger_account
AFTER INSERT OR UPDATE ON ACCOUNT
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger_account();

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dependency_trigger_checking() RETURNS TRIGGER
AS $dependency_trigger_checking$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Backup Table Population */

insert into checking_backup values (t_current, ts_current, new.oid, new.chk_a_id, new.chk_balance);

/* Dependency Generation */	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from CHECKING
	where oid = rec.object_id;
	IF t_xmin IS NOT NULL then
		insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);
	END IF;	

	END LOOP;

Return Null;
END;
$dependency_trigger_checking$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS dependency_trigger_checking on checking;
CREATE TRIGGER dependency_trigger_checking
AFTER INSERT OR UPDATE ON CHECKING
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger_checking();

--------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION dependency_trigger_saving() RETURNS TRIGGER
AS $dependency_trigger_saving$
Declare

rec record;
t_current xid;
t_xmin xid := 0;
ts_current timestamp := current_timestamp;
	
Begin

select txid_current() into t_current;

/* Backup Table Population */

insert into saving_backup values (t_current, ts_current, new.oid, new.sav_a_id, new.sav_balance);

/* Dependency Generation */	
FOR rec IN
SELECT * 
FROM log_table 
Where operation = 1 and transaction_id = t_current
	LOOP

	select xmin into t_xmin 
	from SAVING
	where oid = rec.object_id;
	IF t_xmin IS NOT NULL then
		insert into dependency_table values (t_current, t_xmin,rec.object_id, new.oid, ts_current);
	END IF;	

	END LOOP;

Return Null;
END;
$dependency_trigger_saving$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS dependency_trigger_saving on saving;
CREATE TRIGGER dependency_trigger_saving
AFTER INSERT OR UPDATE ON SAVING
    FOR EACH ROW EXECUTE PROCEDURE dependency_trigger_saving();


