Begin;

select * 
from ships
where name = 'Ship1';

select * 
from ships
where name = 'Ship2';

update ships set name = 'Ship3'
where name = 'Ship3';

update ships set name = 'Ship4'
where name = 'Ship4';

Commit; 
