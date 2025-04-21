create schema if not exists elections;

create table if not exists elections.candidate_data (
	year int,
	constituency varchar(50),
	party varchar(10),
	candidate_name varchar(100)
);

create table if not exists elections.party_data (
	year int,
	constituency varchar(20),
	electors int,
	party varchar(5),
	votes int
);


, candidate_summary as (
	select candidate_name
	, count(distinct year) as elections
	, min(year) as earliest_contested
	, max(year) as latest_contested
	, count(distinct case when )
	)
select candidate_name, max(party), min(party), count(distinct year), min(year), max(year) from elections.candidate_data group by 1 order by 4 desc


with votes as (
	select year
	, constituency
	, sum(votes) as total_votes
	 , max(votes) as winning_vote
	 , max(electors) as electors
	from elections.party_data 
	group by 1,2
	)

, result_summary as (
	select p.*
	, case when total_votes>0 then round(votes::decimal/total_votes,2) end as perc_of_votes
	, case when winning_vote = votes then 1 else 0 end as won
	from elections.party_data p left join votes v on v.year = p.year and v.constituency = p.constituency
	)

, constituency_data as (
	select year
	, constituency
	, count(distinct candidate_name)/count(distinct case when party='-' then candidate_name else party end) as seats
	, count(distinct case when party <> '-' then party end) as parties_contesting
	, count(distinct case when party='-' then candidate_name end) as independents_contesting
	, count(distinct candidate_name) as candidates_contesting
	from elections.candidate_data
	group by 1,2
	)

, seats_summary as (
	select year
	, sum(seats) as total_seats
	, count(distinct constituency) as total_constituencies
	, count(distinct case when seats>1 then constituency end) as total_grc
	, count(distinct case when seats=1 then constituency end) as total_smc
	, count(distinct case when parties_contesting = seats then constituency end) as total_walkovers
	from constituency_data
	group by 1
	)

, party_performance as (
	select r.year
	, party
    , count(r.constituency) as constituencies_contested
  	, sum(seats) as seats_contested 
	, sum(case when won=1 then seats else 0 end) as seats_won
    , round(avg(perc_of_votes),2) avg_vote_perc
	from result_summary r left join constituency_data c on r.year = c.year and r.constituency = c.constituency
	group by 1,2
	)

select * from party_performance order by 1,6 desc
