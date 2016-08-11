create table log_table
( time_stamp timestamp, transaction_id xid,
object_id oid, operation int, tableid oid) without oids;

/* To get oid of the log table for new installation */
--select oid from pg_class where relname= 'log_table';

-------------------------------------------------------
--drop table if exists ships_backup;
--create table ships_backup
--(mod_transaction xid, mod_time timestamp, tuple_id oid, name varchar(30)) without oids;

---------------------------------------------------------
drop table if exists country_backup;
CREATE TABLE country_backup
(mod_transaction xid
, mod_time timestamp
, tuple_id oid
, c_id integer NOT NULL
, c_name   varchar(50) NOT NULL
, c_dfreq smallint not null) without oids;

---------------------------------------------------------
drop table if exists branch_backup;
CREATE TABLE branch_backup
(mod_transaction xid
, mod_time timestamp
, tuple_id oid
, b_id integer     
, b_c_id   integer
, b_saddress varchar(200)
, b_zipcode varchar(10)
, b_rtotal_checking float
, b_rts_checking timestamp
, b_rtotal_saving float
, b_rts_saving timestamp) without oids;

---------------------------------------------------------
drop table if exists customer_backup;
CREATE TABLE customer_backup
(mod_transaction xid
, mod_time timestamp
, tuple_id oid
, cust_id 		bigint
, cust_fname   	varchar(50)
, cust_lname   	varchar(50)
, cust_dob date
, cust_saddress   varchar(200)
, cust_zipcode varchar(10)
, cust_curr_tx_count integer
, cust_total_tx_count bigint
, cust_rts_total_tx_count timestamp) without oids;

---------------------------------------------------------
drop table if exists account_backup;
CREATE TABLE account_backup
(mod_transaction xid
, mod_time timestamp
, tuple_id oid
, a_id bigint
, a_cust_id bigint
, a_b_id integer) without oids;


---------------------------------------------------------
drop table if exists checking_backup;
CREATE TABLE checking_backup
(mod_transaction xid
, mod_time timestamp
, tuple_id oid
, chk_a_id 	    bigint
, chk_balance 	FLOAT) without oids;

---------------------------------------------------------
drop table if exists saving_backup;
CREATE TABLE saving_backup
(mod_transaction xid
, mod_time timestamp
, tuple_id oid
, sav_a_id 	    bigint
, sav_balance 	FLOAT) without oids;

---------------------------------------------------------
drop table if exists dependency_table;
create table dependency_table
(transaction_id xid, depends_on_transaction xid,
read_object oid, write_object oid, time_stamp timestamp) without oids;


------------------------------------------------------------

drop table if exists blocked_transactions_table;
create table blocked_transactions_table
(transaction_id xid, detection_time_stamp timestamp) without oids;


-------------------------------------------------------------
drop table if exists malicious_transactions_table;
create table malicious_transactions_table
(transaction_id xid, detection_time_stamp timestamp) without oids;

--------------------------------------------------------------
drop table if exists corrupted_transactions_table;
create table corrupted_transactions_table
(transaction_id xid, detection_time_stamp timestamp) without oids;

-------------------------------------------------------------
drop table if exists repair_table;
create table repair_table
(corrupted_tuples_oid oid, mal_commit_time timestamp, corrupted_transactions xid, relation_name regclass) without oids;

----------------------------------------------------------------
drop table if exists art_table;
create table art_table
(transaction_id xid, transaction_start_time timestamp, transaction_end_time timestamp) without oids;

------------------------------------------------------------------
drop table if exists blocked_tuples_table;
create table blocked_tuples_table
(blocked_tuples oid, malicious_transaction xid) without oids;

------------------------------------------------------------------
drop table if exists avail_metric_table;
create table avail_metric_table
(malicious_transaction xid, number_blocked_tuples int, recovery_time float, avail_time float,detection_timestamp timestamp, end_rec_timestamp timestamp) without oids;
--------------------------------------------------------------------
drop table if exists blocked_tuples_table_DTQR;
create table blocked_tuples_table_DTQR
(blocked_tuples oid, malicious_transaction xid) without oids;

--------------------------------------------------------------------
drop table if exists blocked_tuples_table_AIMS;
create table blocked_tuples_table_AIMS
(blocked_tuples oid, malicious_transaction xid) without oids;

--------------------------------------------------------------------
drop table if exists temp_tuples_table_AIMS;
create table temp_tuples_table_AIMS
(blocked_tuples oid, malicious_transaction xid) without oids;

--------------------------------------------------------------------
--drop table if exists blocked_ib_table;
--create table blocked_ib_table
--(ib int) without oids;

--------------------------------------------------------------------
drop table if exists active_transactions_table;
create table active_transactions_table
(transaction_id xid) without oids;

-------------- New blocked tuples table -----------------

drop table if exists blocked_tuples_table;
create table blocked_tuples_table
(blocked_tuples oid, malicious_transaction xid, detection_timestamp timestamp, recovery_timestamp timestamp) without oids;

---------- status of blocked tuples ------------


drop table if exists blocked_tuples_status;
create table blocked_tuples_status
(blocked_tuples_count int, status_timestamp timestamp, malicious_transation xid) without oids;


----- Blocked ibs table, originally it was a temp table defined in blocked_tuples_trigger_AIMS ------

drop table if exists blocked_ibs;
create table blocked_ibs
(ib int, malicious_transaction xid) without oids;

-------------- benign transaction status table ---------

drop table if exists benign_transaction_table;
create table benign_transaction_table
(transaction_id xid, suspension_time timestamp, resumption_time timestamp) without oids;









