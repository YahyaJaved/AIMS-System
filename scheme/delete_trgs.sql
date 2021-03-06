drop trigger if exists blocked_tuples_trigger on blocked_transactions_table;
DROP TRIGGER IF EXISTS blocked_tuples_trigger on blocked_transactions_table;
DROP TRIGGER IF EXISTS dependency_trigger_country on COUNTRY;
DROP TRIGGER IF EXISTS dependency_trigger_branch on BRANCH;
DROP TRIGGER IF EXISTS dependency_trigger_customer on CUSTOMER;
DROP TRIGGER IF EXISTS dependency_trigger_account on ACCOUNT;
DROP TRIGGER IF EXISTS dependency_trigger_checking on CHECKING;
DROP TRIGGER IF EXISTS dependency_trigger_saving on SAVING;
drop trigger if exists blocked_tuples_trigger_AIMS on blocked_transactions_table;
DROP TRIGGER IF EXISTS mal_trg on malicious_transactions_table;
DROP TRIGGER IF EXISTS recovery_trigger on repair_table;
DROP TRIGGER IF EXISTS rt_trigger on corrupted_transactions_table;
DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_country on COUNTRY;
DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_branch on BRANCH;
DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_customer on CUSTOMER;
DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_account on ACCOUNT;
DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_checking on CHECKING;
DROP TRIGGER IF EXISTS transaction_control_Aftertrigger_saving on SAVING;
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_country on COUNTRY;
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_branch on BRANCH;
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_customer on CUSTOMER;
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_account on ACCOUNT;
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_checking on CHECKING;
DROP TRIGGER IF EXISTS transaction_control_Beforetrigger_saving on SAVING;
DROP TRIGGER IF EXISTS blocked_tuples_trigger_AIMS on blocked_transactions_table;
