
select * from [Shark _tank ]..Data

--total episodes

select max([Ep# No#]) from [Shark _tank ]..Data
select count(distinct [Ep# No#]) from [Shark _tank ]..Data

--pitches

select count(distinct brand )from [Shark _tank ]..Data

-- pitches converted
select cast(sum(a.converted_not_converted) as float) / cast(count(*) as float) from(
select [Amount Invested lakhs], case when [Amount Invested lakhs]>0 then 1 else 0 end as converted_not_converted from [Shark _tank ]..Data)a

-- total male

select sum(male) from [Shark _tank ]..Data

--total female

select sum(Female) from [Shark _tank ]..Data

--gender ratio

select sum(Female)/sum(male) from [Shark _tank ]..Data

--total invested amount

select sum([Amount Invested lakhs])  from [Shark _tank ]..Data

--avg equity taken

select AVG(a.[Equity Taken %]) from
(select* from [Shark _tank ]..Data where [Equity Taken %]>0)a

--highest deal taken

select max([Amount Invested lakhs]) from  [Shark _tank ]..Data

--highest equity taken

select max([Equity Taken %]) from  [Shark _tank ]..Data

--startups having at least women

select sum(a.Female_count) startups_having_atleast_women from (
select Female,case when Female >0 then 1 else 0 end as Female_count from [Shark _tank ]..Data) a

--pitches converted having atlleast no women

select * from [Shark _tank ]..Data

select sum(b.female_count)from(

select case when a.female>0 then 1 else 0 end as female_count ,a.*from (
(select * from  [Shark _tank ]..Data where Deal != 'No Deal')) a)b

-- avg team members

select avg([Team members]) from [Shark _tank ]..Data

-- amount invested per deal

select AVG(a.[Amount Invested lakhs]) amount_invested_per_deal from
(select * from [Shark _tank ]..Data where Deal!='No Deal')a

-- avg age group of contestants

select [Avg age],count([Avg age])cnt from [Shark _tank ]..Data group by [Avg age] order by cnt desc

-- location group of contestants

select [Location],count([Location]) cnt from [Shark _tank ]..Data group by [Location] order by cnt desc

-- sector group of contestants

select [Sector],count([Sector]) cnt from [Shark _tank ]..Data group by [Sector] order by cnt desc

--partner deals

select [Partners],count([Partners]) cnt from [Shark _tank ]..Data  where [Partners]!='-' group by [Partners]order by cnt desc

-- making the matrix


select * from [Shark _tank ]..Data

select 'Ashnner' as keyy,count([Ashneer Amount Invested]) from [Shark _tank ]..Data where [Ashneer Amount Invested] is not null


select 'Ashnner' as keyy,count([Ashneer Amount Invested]) from [Shark _tank ]..Data where [Ashneer Amount Invested] is not null AND [Ashneer Amount Invested]!=0

SELECT 'Ashneer' as keyy,SUM(C.[Ashneer Amount Invested]),AVG(C.[Ashneer Equity Taken %]) 
FROM (SELECT * FROM [Shark _tank ]..Data  WHERE [Ashneer Equity Taken %]!=0 AND [Ashneer Equity Taken %] IS NOT NULL) C


select m.keyy,m.total_deals_present,m.total_deals,n.total_amount_invested,n.avg_equity_taken from

(select a.keyy,a.total_deals_present,b.total_deals from(

select 'Ashneer' as keyy,count([Ashneer Amount Invested]) total_deals_present from [Shark _tank ]..Data where [Ashneer Amount Invested] is not null) a

inner join (
select 'Ashneer' as keyy,count([Ashneer Amount Invested]) total_deals from [Shark _tank ]..Data 
where [Ashneer Amount Invested] is not null AND [Ashneer Amount Invested]!=0) b 

on a.keyy=b.keyy) m

inner join 

(SELECT 'Ashneer' as keyy,SUM(C.[Ashneer Amount Invested]) total_amount_invested,
AVG(C.[Ashneer Equity Taken %]) avg_equity_taken
FROM (SELECT * FROM [Shark _tank ]..Data  WHERE [Ashneer Equity Taken %] is not null)C) n
on m.keyy=n.keyy

-- which is the startup in which the highest amount has been invested in each domain/sector

select c.* from 
(select brand,sector,[Amount Invested lakhs],rank() over(partition by [Sector] order by [Amount Invested lakhs] desc) rnk 

from [Shark _tank ]..Data) c

where c.rnk=1