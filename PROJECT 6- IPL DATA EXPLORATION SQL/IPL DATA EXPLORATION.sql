drop table if exists #ipls;

create table #ipls 
(
id	float,
inning	float,
overr	float,
ball	float,
batsman	nvarchar(255),
non_striker	nvarchar(255),
bowler	nvarchar(255),
batsman_runs	float,
extra_runs	float,
total_runs	float,
non_boundary	float,
is_wicket	float,
dismissal_kind	nvarchar(255),
player_dismissed	nvarchar(255),
fielder	nvarchar(255),
extras_type	nvarchar(255),
batting_team	nvarchar(255),
bowling_team nvarchar(255)
)

insert into #ipls
select * from IPL.[dbo].[IPL 1]
union
select * from IPL.[dbo].[IPL 2]
union
select * from IPL.[dbo].[IPL 3]
union
select * from IPL.[dbo].[IPL 4];

select count(*) from #ipls;
select count(*) from IPL.[dbo].[IPL 1];
select count(*) from IPL.[dbo].[IPL 2];
select count(*) from IPL.[dbo].[IPL 3];
select count(*) from IPL.[dbo].[IPL 4];

--1)NO OF MATCHES PLAYED PER SEASON

select * from #ipls;
select * from IPL.dbo.ipl;

select yr,count(distinct [id]) number_of_matches from
(select year(date) yr,id from IPL.dbo.ipl)a
group by yr;

-- 2)NO OF MOST PLAYER OF MATCHES

select * from
(select player_of_match,yr,mom,rank() over(partition by yr order by mom desc) rnk from
(
select player_of_match,year(date) yr,count(player_of_match) mom from IPL.dbo.ipl
group by player_of_match,year(date) 
)a)b
where rnk=1;

--3)NO OF MATCHES PLAYED IN A TOP 5 VENUE
select top 5 [venue],count([venue]) 
from IPL.dbo.ipl 
group by [venue]
order by count([venue]) desc;

--4)NO OF TOTAL RUNS SCORED BY BATSMEN IN ALL MATCHES
 select sum(total_runs) from
 (
 select  batsman,sum(total_runs) total_runs from #ipls group by batsman 
 )a;

--5)NO TOTAL RUNS SCORED BY BATSMEN IN MATCHES
 select *,total_runs/sum(total_runs) over(order by total_runs rows between unbounded preceding and unbounded following) runs from
(select  batsman,sum(total_runs) total_runs from #ipls group by batsman )a;

--6)CALCULATE THE TOP BATSMEN IN MATCHES
 select * from #ipls;

 select top 1 batsman,count(batsman) from
( select * from #ipls where batsman_runs=4)a
group by batsman
order by count(batsman) desc;
]
--7)CACULATE THE 3000 RUNS CLUB HIGHEST STRIKE RATE

select top 1 batsman,batsman_runs,strike_rate from 
(select batsman ,batsman_runs,((batsman_runs*1.0)/total_balls)*100 strike_rate from
(select  batsman,sum(batsman_runs) batsman_runs,count(batsman) total_balls  from #ipls group by batsman )a)b
where batsman_runs>=3000 order by strike_rate desc

--8)CACULATE THE NO OF TOP 1 BOWLER , RUNS CONCEDED ,TOTAL BALLS IN MATCHES
select * from #ipls;

select top 1 bowler,(total_runs_conceded/(total_balls*1.0)) economy_rate from
(select bowler,count(bowler) total_balls,sum(total_runs) total_runs_conceded
from #ipls
group by bowler)a
where total_balls>300
order by (total_runs_conceded/(total_balls*1.0))

--9)NO OF MATCHES WON BY EACH OF TEAM
select winner,count(winner) from IPL.dbo.ipl group by winner;