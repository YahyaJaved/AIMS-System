bin/psql -d tpcc -a -f txn1.sql
bin/psql -d tpcc -a -f txn2.sql
bin/psql -d tpcc -a -f txn3.sql
bin/psql -d tpcc -a -f txn4.sql



bin/psql -d tpcc -a -f blocked_txn.sql
bin/psql -d tpcc -a -f mal_txn.sql

bin/psql -d tpcc -a -f blocked_txn1.sql
bin/psql -d tpcc -a -f mal_txn.sql
