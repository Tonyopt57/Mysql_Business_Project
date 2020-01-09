SELECT
	Min(created_at) as first_created_at,
    website_pageview_id as first_pv_id,
    pageview_url
FROM website_pageviews
where created_at<"2012-11-10"
and pageview_url="/billing-2"
;


SELECT 
	COUNT(website_pageviews.website_session_id) as sessions,
    website_pageviews.pageview_url as billing_version,
    COUNT(orders.website_session_id) as orders,
    COUNT(orders.website_session_id)/COUNT(website_pageviews.website_session_id) as billing_to_order_rt
FROM website_pageviews
left join orders
on orders.website_session_id=website_pageviews.website_session_id
where 
	website_pageviews.created_at<"2012-11-10"
    and website_pageviews.website_pageview_id>=53550
    and website_pageviews.pageview_url in ("/billing","/billing-2")
group by billing_version
order by billing_to_order_rt
;