create table ships
(name varchar(30));


insert into ships values ('Black Pearl');
insert into ships values ('The Flying Dutchman');
insert into ships values ('HMS Beagle');
insert into ships values ('HMS Victoria');
insert into ships values ('USS Cole');
insert into ships values ('USS Lincoln');
insert into ships values ('USS Indianapolis');
insert into ships values ('Ship1');
insert into ships values ('Ship2');
insert into ships values ('Ship3');
insert into ships values ('Ship4');
insert into ships values ('Ship5');
insert into ships values ('Ship6');

create table shipps
(name varchar(30));

insert into shipps values ('Ship90');
insert into shipps values ('Ship80');
insert into shipps values ('Ship70');

select s1.name
from ships s1, shipps s2
where s1.name = s2.name;
