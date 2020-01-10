-- Identify repeat_visitor
Create temporary table table1
SELECT
	user_id,
    SUM(is_repeat_session) as revisit_count
FROM website_sessions
where created_at between "2014-01-01" and "2014-11-01"
group by user_id
;

SELECT
	revisit_count,
    COUNT(user_id) as users
FROM table1
group by 1
order by 1 
;

-- 123

SELECT
    case when utm_campaign="nonbrand" then "paid_nonbrand"
    when utm_campaign="brand" then "paid_brand"
    when utm_source is null and http_referer is not null then "organic_search"
    when utm_source is null and http_referer is null then "direct_type_in"
    when utm_source ="socialbook" then "paid_social"
    else "check again" end as channel_group,
    COUNT(case when is_repeat_session=0 then website_session_id else null end) as new_sessions,
    COUNT(case when is_repeat_session=1 then website_session_id else null end) as repeat_sessions
FROM website_sessions
where created_at between "2014-01-01" and "2014-11-01" 
group by 1
;

SELECT
	website_sessions.is_repeat_session,
    COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.order_id) as orders,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) as conv_rate,
    SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) as rev_per_sessions
FROM website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id
where website_sessions.created_at<"2014-11-08" and website_sessions.created_at>="2014-01-01"
group by 1
;