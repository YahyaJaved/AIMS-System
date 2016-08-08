Begin;

select * 
from ships
where name = 'Ship5';

select * 
from ships
where name = 'Ship6';

update ships set name = 'HMS Beagle'
where name = 'HMS Beagle';

update ships set name = 'HMS Victoria'
where name = 'HMS Victoria';

Commit; 
