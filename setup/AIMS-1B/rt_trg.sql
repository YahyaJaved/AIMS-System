/*
This trigger identifies the tuples modified by the malicious and the affected transactions
(collectively called as corrupted transactions) and then populates the repair table.
*/

CREATE OR REPLACE FUNCTION rt_trigger() RETURNS TRIGGER
AS $rt_trigger$
Declare

rec record;
rec1 record;
ts_current timestamp := current_timestamp;
table_name regclass := NULL; 
transaction_status varchar(20) := NULL;
readset_size int := 0;
writeset_size int := 0;

amount float := 0;
total_amount float := 0; --used in distribute and many-to-many
source_bal float := 0;
pay_percent float := 0;
old_bal float := 0;
new_bal float := 0;
source oid := 0;
dest oid := 0;
no_dest_accts int := 0; --used only in many-to-many
	
Begin

transaction_status := new.status;

/* 1st step of AIMS recovery: UNDO */

/* First loop identifies the write set of the malicious / affected transaction */ --- << VERIFIED >>
	
FOR rec IN
SELECT * 
FROM temp_log_table 
Where transaction_id = new.transaction_id and operation <> 1
LOOP

/* the second loop identifies the correct version of the tuple to which it is be rolled back. The correct version is the version
with the timestamp just prior to the commit time of the malicious / affected transaction */ --- << VERIFIED >>

	FOR rec1 IN
	select *
	from log_table --- checking_backup can also be used here 
	where object_id = rec.object_id and operation <> 1  and time_stamp < new.mal_commit_time
	Order by time_stamp DESC
	LIMIT 1 
	LOOP
	
		UPDATE checking 
		SET chk_id = rec1.chk_id, balance = rec1.balance
		WHERE oid = rec1.object_id;

	
	END LOOP;

	--select relname into table_name 
	--from pg_class where oid = rec.tableid;

	--insert into repair_table values (rec.object_id, rec.time_stamp, rec.transaction_id, new.status, table_name);

END LOOP;

/* 2nd step of AIMS recovery: REDO -- Only for affected transactions */

IF transaction_status = 'affected' THEN -- << VERIFIED >>

/* Calculate the read-set size and write-set size of the affected transaction so that we can identify the transaction profile
from that */ --- << VERIFIED >>

select count(*) into readset_size
from temp_log_table
where transaction_id = new.transaction_id and operation = 1;

select count(*) into writeset_size
from temp_log_table
where transaction_id = new.transaction_id and operation <> 1;

-----------------------------------------SEND PAYMENT---------------------------------------
-- << VERIFIED >> all of send payment module

	IF readset_size = 1 and writeset_size = 2 THEN

  --Identify the souce and destination tuples that is the source and the destination accounts 

		-- Since there is only one read for the send payment
		select object_id into source
		from temp_log_table
		where transaction_id = new.transaction_id and operation = 1;

		-- Two wirtes for send payment but dest is the one on which read has not taken place
		select object_id into dest
		from temp_log_table
		where transaction_id = new.transaction_id and operation <> 1 and object_id <> source;		

		-- Get the most recent value of the source balance 
		select balance into source_bal
		from checking
		where oid = source;

		-- In order to find the percentage of the source balance this affected transaction was trying to transfer, we take the old and the new 				value of the of the balance when this affected transaction issued the update in the first place on the source tuple 
		select new_balance, old_balance into new_bal, old_bal
		from checking_backup
		where mod_transaction = new.transaction_id and tuple_id = source;

		-- Calculation of the percentage of the source balance this affected transaction was trying to transfer
		pay_percent := abs(new_bal - old_bal);
		pay_percent := pay_percent / old_bal;

		-- Finding the new amount which would be used to redo the transfer intended by the affected transaction as if the affected 							transaction is reisued at this moment with reading of clean data as the modifications of the malicious transaction has been 						rolled back   
		amount := pay_percent * source_bal;

		-- Redoing the send payment
		IF amount <= source_bal THEN

		update checking 
		set balance = balance - amount
		where oid = source;

		update checking
		set balance = balance + amount
		where oid = dest;

		END IF;	

---------------------------------------------COLLECT-------------------------------------------
-- << VERIFIED >> all of the collect module

	ELSIF readset_size > 1 and writeset_size = readset_size + 1 THEN
		
		-- Identify the destination tuple first, it is the one which is not the in the read set of the transaction		
		select t1.object_id into dest
		from temp_log_table t1
		where t1.transaction_id = new.transaction_id and t1.operation <> 1 and t1.object_id NOT IN (select t2.object_id
																																																				from temp_log_table t2
																															where t2.transaction_id = new.transaction_id and t2.operation = 1);

		-- This loop goes through each source account one by one - all of the tuples on which read has taken place are the source tuples
		For rec IN
		select *
		from temp_log_table
		where transaction_id = new.transaction_id and operation = 1
		ORDER BY time_stamp ASC
		Loop

			-- one of the source tuple
			source := rec.object_id;

			-- Inside this loop we have one source tuple and one dest tuple, so every calculation is the same now as of the send payment
			
			-- Get the most recent value of the source balance 
			select balance into source_bal
			from checking
			where oid = source;

			-- In order to find the percentage of the source balance this affected transaction was trying to transfer, we take the old and the new value of the of the balance when this affected transaction issued the update in the first place on the source tuple 
			select new_balance, old_balance into new_bal, old_bal
			from checking_backup
			where mod_transaction = new.transaction_id and tuple_id = source;

			-- Calculation of the percentage of the source balance this affected transaction was trying to transfer
			pay_percent := abs(new_bal - old_bal) / old_bal;
			--pay_percent := pay_percent / old_bal;

			-- Finding the new amount which would be used to redo the transfer intended by the affected transaction as if the affected transaction is reisued at this moment with reading of clean data as the modifications of the malicious transaction has been rolled back   
			amount := pay_percent * source_bal;

			-- Redoing the send payment
			IF amount <= source_bal THEN

			update checking 
			set balance = balance - amount
			where oid = source;

			update checking
			set balance = balance + amount
			where oid = dest;

			END IF;
		
		END Loop;	

--------------------------------------DISTRIBUTE------------------------------------------
-- << VERIFIED >> all of DISTRIBUTE module

	ELSIF readset_size = 1 and writeset_size > 2 THEN

		-- Identify the source tuple first, it is the only tuple that is in the readset of the transaction
		select object_id into source
		from temp_log_table
		where transaction_id = new.transaction_id and operation = 1;

	-- We can calculate the amount that need to be sent to each destination tuple here

	-- Get the most recent value of the source balance 
		select balance into source_bal
		from checking
		where oid = source;

	-- In order to find the percentage of the source balance this affected transaction was trying to transfer, we take the old and the new value of the of the balance when this affected transaction issued the update in the first place on the source tuple 
		select new_balance, old_balance into new_bal, old_bal
		from checking_backup
		where mod_transaction = new.transaction_id and tuple_id = source;

	-- Calculation of the percentage of the source balance this affected transaction was trying to transfer
		pay_percent := abs(new_bal - old_bal);
		pay_percent := pay_percent / old_bal;

-- Finding the new amount which would be used to redo the transfer intended by the affected transaction as if the	affected transaction is reisued at this moment with reading of clean data as the modifications of the malicious transaction has been rolled back   

	-- This is the total amount that is sent from the source tuple			
	total_amount := pay_percent * source_bal;

	-- The amount per destination is the total amount deducted from the source divided by the number of destination tuples i.e. the writeset_size - 1
	amount := total_amount / (writeset_size - 1) ;

	-- Now check if the total_amount is less than or equal to the source_balance, if yes then continue otherwise redo nothing and exit
	IF total_amount <= source_bal THEN

	-- Deduct the total amount to be transferred from the source
		update checking 
		set balance = balance - total_amount
		where oid = source;
	
		-- Loop through all of the destination tuples and add the amount to them
		FOR rec IN 
		select *
		from temp_log_table 
		where transaction_id = new.transaction_id and operation <> 1 and object_id <> source
		ORDER BY time_stamp ASC
		Loop
	
			dest := rec.object_id;	
	
			update checking
			set balance = balance + amount
			where oid = dest ;
	
		End Loop;
	

	END IF;

--------------------------------------MANY-TO-MANY (N to M)------------------------------------------
-- << VERIFIED >> all of N to M module

	ELSIF readset_size > 1 and writeset_size > readset_size + 1 THEN

		-- First we will calculate the total amount that is to be collected from N source accounts, for that we loop through each of the source tuple 
		FOR rec IN 	
		select * 
		from temp_log_table
		where transaction_id = new.transaction_id and operation = 1
		ORDER BY time_stamp ASC
		LOOP
	
			-- one of the source tuple
			source := rec.object_id;
			
			-- Get the most recent value of the source balance for this source tuple 
			select balance into source_bal
			from checking
			where oid = source;

			-- In order to find the percentage of the source balance for this particular source tuple this affected transaction was trying to transfer, we take the old and the new value of the of the balance of this tuple when this affected transaction issued the update in the first place on the source tuple 
			select new_balance, old_balance into new_bal, old_bal
			from checking_backup
			where mod_transaction = new.transaction_id and tuple_id = source;

			-- Calculation of the percentage of the source balance this affected transaction was trying to transfer from this source tuple
			pay_percent := abs(new_bal - old_bal);
			pay_percent := pay_percent / old_bal;

			-- The amount that is to be deducted from this source tuple which is the transfer amount of this source tuple
			amount := pay_percent * source_bal;

			-- Now deduct the amount from the source tuple under discussion and add its contribution to the total
			IF amount <= source_bal THEN

			-- The contribution of this source tuple to the total_amount that is to distributed among the destination tuples
			total_amount := total_amount + amount;
			
			update checking 
			set balance = balance - amount
			where oid = source;

			END IF;
			
		END LOOP;

		-- Now we distribute the total_amount among M destination accounts (tuples)
		no_dest_accts := writeset_size - readset_size;
		
		-- Amount per destination aacount 
		amount := total_amount / no_dest_accts;

		-- Loop throught the destination tuples and update their balance by adding the amount to their respective balance
		FOR rec IN
		select *
		from temp_log_table t1
		where t1.transaction_id = new.transaction_id and t1.operation <> 1 and t1.object_id NOT IN (select t2.object_id
																																													from temp_log_table t2
																																													where t2.transaction_id = new.transaction_id and t2.operation = 1)
		ORDER BY time_stamp ASC
		LOOP

			dest := rec.object_id;	
	
			update checking
			set balance = balance + amount
			where oid = dest ;
		 
		END LOOP;
		


END IF;

END IF;

Return Null;
END;
$rt_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS rt_trigger on corrupted_transactions_table;
CREATE TRIGGER rt_trigger
AFTER INSERT ON corrupted_transactions_table
    FOR EACH ROW EXECUTE PROCEDURE rt_trigger();
