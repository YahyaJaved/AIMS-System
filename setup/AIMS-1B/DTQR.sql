Begin;

drop trigger if exists blocked_tuples_trigger_AIMS on blocked_transactions_table;

drop trigger if exists blocked_tuples_trigger on blocked_transactions_table;

drop trigger if exists mal_trg on malicious_transactions_table;

drop trigger if exists rt_trg on corrupted_transactions_table;

drop trigger if exists transaction_control_Beforetrigger on checking;



Commit;
