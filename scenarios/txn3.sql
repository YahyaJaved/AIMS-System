Begin;

select * 
from ships
where name = 'Ship3';

select * 
from ships
where name = 'Ship4';

update ships set name = 'Ship5'
where name = 'Ship5';

update ships set name = 'Ship6'
where name = 'Ship6';

Commit; 
