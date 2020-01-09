CREATE temporary table firstview1
SELECT 
	website_pageviews.website_session_id,
    Min(website_pageviews.website_pageview_id) as entry_url
FROM website_pageviews
inner join website_sessions
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at < "2012-07-28"
	and website_pageviews.website_pageview_id>23504
    and utm_source="gsearch"
    and utm_campaign="nonbrand"
group by website_pageviews.website_session_id
;


CREATE temporary table firstview1_session
SELECT
	firstview1.website_session_id,
    website_pageviews.pageview_url as entry_url
FROM firstview1
left join website_pageviews
on firstview1.website_session_id=website_pageviews.website_session_id
group by firstview1.website_session_id
;

CREATE temporary table bounce_session1
SELECT 
	firstview1_session.website_session_id,
    COUNT(website_pageviews.website_session_id) as count_view_num,
    website_pageviews.pageview_url
FROM firstview1_session
left join website_pageviews
on firstview1_session.website_session_id=website_pageviews.website_session_id
group by firstview1_session.website_session_id
having count_view_num=1
order by firstview1_session.website_session_id
;


SELECT 
	firstview1_session.entry_url,
    COUNT(firstview1_session.website_session_id) as sessions,
    COUNT(bounce_session1.website_session_id) as bound_session,
    COUNT(bounce_session1.website_session_id)/COUNT(firstview1_session.website_session_id) as bounce_rate
FROM firstview1_session
left join bounce_session1
on firstview1_session.website_session_id=bounce_session1.website_session_id
group by firstview1_session.entry_url
order by firstview1_session.website_session_id
;
