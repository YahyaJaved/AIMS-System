CREATE or replace FUNCTION myfunc() RETURNS integer AS $$
DECLARE
    
	rec record;
	start_time_experiment timestamp := NULL;
	end_time_experiment timestamp := NULL;
	total_time float := NULL;

	normal_avail_time float := NULL;
	attack_avail_time float := NULL;
	sum_recover_time float := NULL;
	availability float := NULL;

BEGIN

	select time_stamp into start_time_experiment
	from log_table 
	Order by time_stamp ASC
	LIMIT 1;

	select time_stamp into end_time_experiment
	from log_table 
	Order by time_stamp DESC
	LIMIT 1;

	SELECT EXTRACT(EPOCH FROM (end_time_experiment - start_time_experiment)) into total_time;-- Total experiment time

	select sum(avail_time) into attack_avail_time  -- sum of all individual ratio of available tuples multipled by their respective recovery time (qauntity X) for each attack
	from avail_metric_table;

	select sum(recovery_time) into sum_recover_time -- sum of the time when the availabity was not 100%
	from avail_metric_table;

	normal_avail_time := abs(total_time - sum_recover_time); -- Time when the system availabilty was 100% 

	availability := attack_avail_time + normal_avail_time; -- sum of attack avail time  and normal avail time
	availability := availability / total_time; -- calculation of ratio

	availability := availability * 100; --availability percentage

	raise notice 'TOTAL  EXPERIMENT Attack Avail Time = %', attack_avail_time;

	raise notice 'TOTAL  Normal Avail Time = %', normal_avail_time;

	raise notice 'TOTAL  EXPERIMENT Time = %', total_time;
		
	raise notice 'TOTAL PERCENTAGE EXPERIMENT AVAILABILITY = %', availability;
	


Return 0;
END;
$$ LANGUAGE plpgsql;

Begin;

select myfunc();

Commit;
