CREATE temporary table firstview2
SELECT 
	week(website_pageviews.created_at) as weeks,
    Min(Date(website_pageviews.created_at)) as week_start_day,
	website_pageviews.website_session_id,
    Min(website_pageviews.website_pageview_id) as entry_url
FROM website_pageviews
inner join website_sessions
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at between "2012-06-01" and "2012-08-31" 
    and utm_source="gsearch"
    and utm_campaign="nonbrand"
group by website_pageviews.website_session_id, weeks
;


CREATE temporary table firstview_session2
SELECT
	firstview2.weeks,
	firstview2.week_start_day,
	firstview2.website_session_id,
    website_pageviews.pageview_url as entry_url
FROM firstview2
left join website_pageviews
on firstview2.website_session_id=website_pageviews.website_session_id
group by firstview2.website_session_id
;

CREATE temporary table bounce_session2
SELECT 
	firstview_session2.week_start_day,
	firstview_session2.website_session_id,
    COUNT(website_pageviews.website_session_id) as count_view_num,
    website_pageviews.pageview_url
FROM firstview_session2
left join website_pageviews
on firstview_session2.website_session_id=website_pageviews.website_session_id
group by firstview_session2.website_session_id
having count_view_num=1
order by firstview_session2.website_session_id
;


SELECT 
	firstview_session2.week_start_day,
    -- COUNT(firstview_session2.website_session_id) as sessions,
    -- COUNT(bounce_session2.website_session_id) as bound_session,
    COUNT(bounce_session2.website_session_id)/COUNT(firstview_session2.website_session_id) as bounce_rate,
    COUNT(distinct case when firstview_session2.entry_url="/home" then firstview_session2.website_session_id else null end) as home_session,
    COUNT(distinct case when firstview_session2.entry_url="/lander-1" then firstview_session2.website_session_id else null end) as lander_session
FROM firstview_session2
left join bounce_session2
on firstview_session2.website_session_id=bounce_session2.website_session_id
group by firstview_session2.weeks
order by firstview_session2.website_session_id
;

