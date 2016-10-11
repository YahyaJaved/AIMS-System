CREATE OR REPLACE FUNCTION SendPaymentTestMal() RETURNS integer
AS $$
Declare

amount int := 1000;
	
Begin

perform oid, tableoid, xmin, *
from checking
where chk_id = 1;

update checking set balance = balance - amount
where chk_id = 1;

update checking set balance = balance + amount
where chk_id = 2;

Return Null;
END;
$$ LANGUAGE plpgsql;

Begin;

select SendPaymentTestMal();

Commit;

CREATE OR REPLACE FUNCTION SendPaymentTestAfc() RETURNS integer
AS $$
Declare

amount int := 1000;
	
Begin

perform oid, tableoid, xmin, *
from checking
where chk_id = 2;

update checking set balance = balance - amount
where chk_id = 2;

update checking set balance = balance + amount
where chk_id = 3;


Return Null;
END;
$$ LANGUAGE plpgsql;

Begin;

select SendPaymentTestAfc();

Commit;
