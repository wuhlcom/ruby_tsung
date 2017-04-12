SELECT * FROM results
SELECT * FROM delays
SELECT * FROM errors
/*笛卡尔积*/
SELECT * FROM results cross join delays
/*on相等的列会显示两次*/
select * from delays inner join errors on delays.id=errors.id
/*using相等的列只会显示1次*/
select * from delays inner join errors using (id);
/*所有的例进行相等比较*/
select * from delays natural join errors
select * from delays left outer join errors on delays.id=errors.id limit 30
select * from  errors left outer join delays on delays.id=errors.id limit 30
select * from  errors left outer join delays using (id) limit 30
select * from  results left outer join delays on delays.id=results.id 
select * from  results left outer join delays using (id)

SELECT * FROM pubs where revpub_time is not null

SELECT id,ip_src,ip_dst,times FROM delays

insert into delays (id,ip_src,ip_dst,times) values (1,"","",0.334)

insert into delays (id,ip_src,ip_dst,times) values (2,"","",0.234),(3,"","",0.552)

delete from delays

select avg(times) from delays
select max(times) from delays
select min(times) from delays

SELECT * FROM pubs
SELECT count(*) FROM pubs
SELECT count(*) FROM pubs where revpub_time is  not null
SELECT * FROM pubs where revpub_time is  not null
select id,pub_time,revpub_time,strftime("%f",pub_time) as pub,strftime("%f",revpub_time) as rev from pubs where revpub_time is not null
select id,pub_time,revpub_time,(strftime("%f",pub_time)-strftime("%f",revpub_time)) as result from pubs where revpub_time is not null
select (strftime("%f",pub_time)-strftime("%f",revpub_time)) as result from pubs where revpub_time is not null

select (strftime("%f",pub_time)-strftime("%f",revpub_time)) as result from pubs where revpub_time is not null

select * from sqlite_master where type="table" and name="delays";
select * from sqlite_master 

SELECT id,pub_time,revpub_time,delay_time,t,h FROM pubs

alter table pubs add column t decimal
alter table pubs add column h decimal(10,4)

update pubs set t=strftime("%f",revpub_time)-strftime("%f",pub_time) where revpub_time is not null
update pubs set h=strftime("%f",revpub_time)-strftime("%f",pub_time) where revpub_time is not null

	select * from delays
insert into delays (id,name,delay_times,created_at,updated_at) values (1,"hi",0.234,"2017-0407 14:30:22:234","2017-0407 14:30:22:234")
insert into delays (id,name,delay_times,created_at,updated_at) values (2,"hei",0.234,datetime('now'),datetime('now'))
alter table delays add column t decimal
alter table delays add column pub_time decimal
alter table delays rename column delay_times to revpub_time 

select * from pubs
insert into pubs (id,name,pub_time,revpub_time,delay_time,created_at,updated_at)
 values (2,"hei",datetime('now'),datetime('now',"10.233 seconds"),null,datetime('now'),datetime('now')),
 (3,"hi",datetime('now'),datetime('now',"10.233 seconds"),null,datetime('now'),datetime('now')),
  (4,"ha",datetime('now'),datetime('now',"10.233 seconds"),null,datetime('now'),datetime('now'))
  
update pubs set delay_time=(strftime("%Y%m%d%H%M%f",revpub_time)-strftime("%Y%m%d%H%M%f",pub_time))