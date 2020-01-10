-- Analyzing seasonality
-- take a look at 2012 monthly and weekly volume pattern

SELECT
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.order_id) as orders
FROM website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id
where website_sessions.created_at<"2013-01-01"
group by 1,2
;

SELECT
	year(website_sessions.created_at) as yr,
	week(website_sessions.created_at) as wk,
	Date(website_sessions.created_at) as week_start_day,
    COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.order_id) as orders
FROM website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id
where website_sessions.created_at<"2013-01-01"
group by 1,2
;

-- It is found that the selling grow steadily all year and a significant burst between 2012-11-18 and 2012-11-25
-- It may due to the Black Friday and Cyber Monday.alter

-- analyze average website session volume, by hour of day and by day week.
-- we found that from 8am to 5pm are the busy period.
create temporary table daily_hourly_sessions
SELECT
	Date(website_sessions.created_at) as created_date,
    weekday(website_sessions.created_at) as wk,
	hour(website_sessions.created_at) as hr,
    COUNT(website_sessions.website_session_id) as website_sessions
FROM website_sessions
where website_sessions.created_at between "2013-09-15" and "2013-11-15"
group by 1,2,3
;

SELECT
	hr,
    avg(website_sessions) as avg_session,
    avg(case when wk=0 then website_sessions else null end) as mon,
    avg(case when wk=1 then website_sessions else null end) as tue,
    avg(case when wk=2 then website_sessions else null end) as wed,
    avg(case when wk=3 then website_sessions else null end) as thu,
    avg(case when wk=4 then website_sessions else null end) as fri,
    avg(case when wk=5 then website_sessions else null end) as sat,
    avg(case when wk=6 then website_sessions else null end) as sun
from daily_hourly_sessions
group by 1
;

/*
    COUNT(case when weekday(website_sessions.created_at)=0 then website_sessions.website_session_id else null end) as mon,
    COUNT(case when weekday(website_sessions.created_at)=1 then website_sessions.website_session_id else null end) as tue,
    COUNT(case when weekday(website_sessions.created_at)=2 then website_sessions.website_session_id else null end) as wed,
    COUNT(case when weekday(website_sessions.created_at)=3 then website_sessions.website_session_id else null end) as thu,
    COUNT(case when weekday(website_sessions.created_at)=4 then website_sessions.website_session_id else null end) as fri,
    COUNT(case when weekday(website_sessions.created_at)=5 then website_sessions.website_session_id else null end) as sat,
    COUNT(case when weekday(website_sessions.created_at)=6 then website_sessions.website_session_id else null end) as sun
*/