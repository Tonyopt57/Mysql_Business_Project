-- Analysis for channel porfolio Management

SELECT
    week(created_at) as weeks,
    Date(created_at) as week_start_day,
    COUNT(website_session_id) as total_session,
    COUNT(case when utm_source="gsearch" then 1 else null end) as gsearch_session,
    COUNT(case when utm_source="bsearch" then 1 else null end) as bsearch_session
FROM website_sessions
where utm_campaign="nonbrand" and website_sessions.created_at between "2012-08-22" and "2012-11-29"
group by 1
;

SELECT
	utm_source,
    COUNT(website_session_id) as total_session,
        COUNT(case when device_type="mobile" then 1 else null end) as mobile_session,
    COUNT(case when device_type="mobile" then 1 else null end)/COUNT(website_session_id) as mobile_session_pct
    -- COUNT(case when device_type="desktop" then 1 else null end)/COUNT(website_session_id) as desktop_session_pct
FROM website_sessions
where utm_campaign="nonbrand" and website_sessions.created_at between "2012-08-22" and "2012-11-29"
	and utm_source in ("gsearch","bsearch")
group by 1
;

SELECT
	device_type,
    utm_source,
    COUNT(website_sessions.website_session_id) as total_session,
    COUNT(orders.order_id) as orders,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) as conv_rate
FROM website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id
where utm_campaign="nonbrand" and website_sessions.created_at between "2012-08-22" and "2012-09-19"
group by 1,2
order by conv_rate DESC
;

SELECT
    week(created_at) as weeks,
    Date(created_at) as week_start_day,
    COUNT(case when utm_source="gsearch" and device_type="desktop" then 1 else null end) as g_dtop_session,
    COUNT(case when utm_source="bsearch" and device_type="desktop" then 1 else null end) as b_dtop_session,
    COUNT(case when utm_source="bsearch" and device_type="desktop" then 1 else null end)/COUNT(case when utm_source="gsearch" and device_type="desktop" then 1 else null end) as b_pct_of_g_dtop,
    COUNT(case when utm_source="gsearch" and device_type="mobile" then 1 else null end) as g_mob_session,
    COUNT(case when utm_source="bsearch" and device_type="mobile" then 1 else null end) as b_mob_session,
	COUNT(case when utm_source="bsearch" and device_type="mobile" then 1 else null end)/COUNT(case when utm_source="gsearch" and device_type="mobile" then 1 else null end) as b_pct_of_g_mob
FROM website_sessions
where utm_campaign="nonbrand" and website_sessions.created_at between "2012-11-04" and "2012-12-22"
group by 1
;

-- Analyze direct traffic
/*
Analyze how much revenue we are generating from direct traffic is about keeping a pulse on how well our brand 
is doing in driving customers and business.
Pull organic search,direct type in and paid brand search sessions by month.alter
*/

SELECT
	year(created_at) as yr,
    month(created_at) as mo,
    COUNT(case when utm_campaign="nonbrand" then 1 else null end) as nonbrand,
    COUNT(case when utm_campaign="brand" then 1 else null end) as brand,
    COUNT(case when utm_campaign="brand" then 1 else null end)/COUNT(case when utm_campaign="nonbrand" then 1 else null end) as brand_pct_of_nonbrand,
    COUNT(case when utm_source is null and http_referer is null then 1 else null end) as direct,
    COUNT(case when utm_source is null and http_referer is null then 1 else null end)/COUNT(case when utm_campaign="nonbrand" then 1 else null end) as direct_pct_of_nonbrand,
    COUNT(case when utm_source is null and http_referer is not null then 1 else null end) as organic,
    COUNT(case when utm_source is null and http_referer is not null then 1 else null end)/COUNT(case when utm_campaign="nonbrand" then 1 else null end) as organic_pct_of_nonbrand
FROM website_sessions
where  website_sessions.created_at < "2012-12-23"
group by 1,2
;
