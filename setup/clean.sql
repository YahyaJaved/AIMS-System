-- drop trigger IF exists dependency_trigger_country on country;
-- drop trigger if exists dependency_trigger_branch on branch;
-- drop trigger if exists dependency_trigger_customer on customer;
-- drop trigger if exists dependency_trigger_account on account;
drop trigger if exists dependency_trigger_checking on checking;
-- drop trigger if exists dependency_trigger_saving on saving;
-- drop trigger if exists transaction_control_Beforetrigger_country on country;
-- drop trigger if exists transaction_control_Beforetrigger_branch on branch;
-- drop trigger if exists transaction_control_Beforetrigger_customer on customer;
-- drop trigger if exists transaction_control_Beforetrigger_account on account;
-- drop trigger if exists transaction_control_Beforetrigger_saving on saving;
drop trigger if exists transaction_control_Beforetrigger_checking on checking;
-- drop trigger if exists transaction_control_Beforetrigger_AIMS_country on country;
-- drop trigger if exists transaction_control_Beforetrigger_AIMS_branch on branch;
-- drop trigger if exists transaction_control_Beforetrigger_AIMS_customer on customer;
-- drop trigger if exists transaction_control_Beforetrigger_AIMS_account on account;
-- drop trigger if exists transaction_control_Beforetrigger_AIMS_saving on saving;
-- drop trigger if exists transaction_control_Beforetrigger_AIMS_checking on checking;
-- drop trigger if exists transaction_control_Aftertrigger_country on country;
-- drop trigger if exists transaction_control_Aftertrigger_branch on branch;
-- drop trigger if exists transaction_control_Aftertrigger_customer on customer;
-- drop trigger if exists transaction_control_Aftertrigger_account on account;
drop trigger if exists transaction_control_Aftertrigger_checking on checking;
-- drop trigger if exists transaction_control_Aftertrigger_saving on saving;
drop trigger if exists blocked_tuples_trigger_AIMS on blocked_transactions_table;
drop trigger if exists blocked_tuples_trigger on blocked_transactions_table;
drop trigger if exists blocked_tuples_trigger_AIMS on malicious_transactions_table;
drop trigger if exists blocked_tuples_trigger on malicious_transactions_table;
drop trigger if exists mal_trg on malicious_transactions_table;
drop trigger if exists mal_trg_AIMS on malicious_transactions_table;
drop trigger if exists mal_trg on malicious_transactions_table;
drop trigger if exists recovery_trigger on repair_table;
drop trigger if exists rt_trigger on corrupted_transactions_table;
drop trigger if exists recovery_trigger_AIMS on repair_table;
drop trigger if exists rt_trigger_AIMS on corrupted_transactions_table;






