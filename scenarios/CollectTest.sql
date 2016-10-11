CREATE OR REPLACE FUNCTION CollectTestMal() RETURNS integer
AS $$
Declare

percent float := 0.1;
source_bal1 float := 0;
source_bal2 float := 0;
dummy1 oid := 0;
dummy2 oid := 0;
dummy3 xid := 0;
dummy4 int := 0;
amount1 int := 0;
amount2 int := 0;
total_amount int := 0 ;
	
Begin

select oid, tableoid, xmin, chk_id, balance into dummy1, dummy2 , dummy3 , dummy4, source_bal1 
from checking
where chk_id = 1;

select oid, tableoid, xmin, chk_id, balance into dummy1, dummy2 , dummy3 , dummy4, source_bal2 
from checking
where chk_id = 2;

amount1 := percent * source_bal1;

amount2 := percent * source_bal2;

total_amount := amount1 + amount2;

update checking set balance = balance - amount1
where chk_id = 1;

update checking set balance = balance - amount2
where chk_id = 2;

update checking set balance = balance + total_amount
where chk_id = 3;

Return Null;
END;
$$ LANGUAGE plpgsql;

Begin;

select CollectTestMal();

Commit;

CREATE OR REPLACE FUNCTION CollectTestAfc() RETURNS integer
AS $$
Declare

percent float := 0.1;
source_bal1 float := 0;
source_bal2 float := 0;
dummy1 oid := 0;
dummy2 oid := 0;
dummy3 xid := 0;
dummy4 int := 0;
amount1 int := 0;
amount2 int := 0;
total_amount int := 0 ;
	
Begin

select oid, tableoid, xmin, chk_id, balance into dummy1, dummy2 , dummy3 , dummy4, source_bal1 
from checking
where chk_id = 3;

select oid, tableoid, xmin, chk_id, balance into dummy1, dummy2 , dummy3 , dummy4, source_bal2 
from checking
where chk_id = 4;

amount1 := percent * source_bal1;

amount2 := percent * source_bal2;

total_amount := amount1 + amount2;

update checking set balance = balance - amount1
where chk_id = 3;

update checking set balance = balance - amount2
where chk_id = 4;

update checking set balance = balance + total_amount
where chk_id = 5;


Return Null;
END;
$$ LANGUAGE plpgsql;

Begin;

select CollectTestAfc();

Commit;
