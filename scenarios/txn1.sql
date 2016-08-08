Begin;

select * 
from ships
where name = 'Black Pearl';

select * 
from ships
where name = 'The Flying Dutchman';

update ships set name = 'Ship1'
where name = 'Ship1';

update ships set name = 'Ship2'
where name = 'Ship2';

Commit; 
