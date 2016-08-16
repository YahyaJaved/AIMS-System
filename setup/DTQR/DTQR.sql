Begin;

drop trigger if exists blocked_tuples_trigger_AIMS on blocked_transactions_table;

\i blocked_tuples_trigger.sql

Commit;
