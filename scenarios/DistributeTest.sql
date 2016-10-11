CREATE OR REPLACE FUNCTION DistributeTestMal() RETURNS integer
AS $$
Declare

percent float := 0.1;
source_bal float := 0;
dummy1 oid := 0;
dummy2 oid := 0;
dummy3 xid := 0;
dummy4 int := 0;
amount1 int := 0;
amount2 int := 0;
total_amount int := 0 ;
	
Begin

select oid, tableoid, xmin, chk_id, balance into dummy1, dummy2 , dummy3 , dummy4, source_bal 
from checking
where chk_id = 1;

total_amount := percent * source_bal;

amount1 := total_amount /2;
amount2 := total_amount / 2;

update checking set balance = balance - total_amount
where chk_id = 1;

update checking set balance = balance + amount1
where chk_id = 2;

update checking set balance = balance + amount2
where chk_id = 3;

Return Null;
END;
$$ LANGUAGE plpgsql;

Begin;

select DistributeTestMal();

Commit;

CREATE OR REPLACE FUNCTION DistributeTestAfc() RETURNS integer
AS $$
Declare

percent float := 0.1;
source_bal float := 0;
dummy1 oid := 0;
dummy2 oid := 0;
dummy3 xid := 0;
dummy4 int := 0;
amount1 int := 0;
amount2 int := 0;
total_amount int := 0 ;
	
Begin

select oid, tableoid, xmin, chk_id, balance into dummy1, dummy2 , dummy3 , dummy4, source_bal 
from checking
where chk_id = 3;

total_amount := percent * source_bal;

amount1 := total_amount /2;
amount2 := total_amount / 2;

update checking set balance = balance - total_amount
where chk_id = 3;

update checking set balance = balance + amount1
where chk_id = 4;

update checking set balance = balance + amount2
where chk_id = 5;



Return Null;
END;
$$ LANGUAGE plpgsql;

Begin;

select DistributeTestAfc();

Commit;
