-- Question 1
SELECT 
	Year(website_sessions.created_at) as Year_Period,
	Month(website_sessions.created_at) as Month_Period,
    COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as order_count
FROM website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
where website_sessions.utm_source="gsearch" and website_sessions.created_at<"2012-11-27"
group by 1,2
;

-- Question 2
SELECT 
	Year(website_sessions.created_at) as Year_Period,
	Month(website_sessions.created_at) as Month_Period,
    COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as order_count,
    COUNT(case when website_sessions.utm_campaign="nonbrand" Then 1 else null end) as Nonbrand_Session_Count,
    COUNT(case when website_sessions.utm_campaign="nonbrand" Then orders.order_id else null end) as Nonbrand_Session_order,
    COUNT(case when website_sessions.utm_campaign="brand" Then 1 else null end) as Brand_Session_Count,
    COUNT(case when website_sessions.utm_campaign="brand" Then orders.order_id else null end) as Brand_Session_order
FROM website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
where website_sessions.utm_source="gsearch" and website_sessions.created_at<"2012-11-27"
group by 1,2
;

-- Question 3
SELECT 
	Year(website_sessions.created_at) as Year_Period,
	Month(website_sessions.created_at) as Month_Period,
    COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as order_count,
    COUNT(case when website_sessions.device_type="desktop" Then 1 else null end) as desktop_Count,
    COUNT(case when website_sessions.device_type="desktop" Then orders.order_id else null end) as desktop_order,
    COUNT(case when website_sessions.device_type="mobile" Then 1 else null end) as mobile_Count,
    COUNT(case when website_sessions.device_type="mobile" Then orders.order_id else null end) as mobile_order
FROM website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
where website_sessions.utm_source="gsearch" and website_sessions.created_at<"2012-11-27"
group by 1,2
;

-- Question 4
SELECT 
	Year(website_sessions.created_at) as Year_Period,
	Month(website_sessions.created_at) as Month_Period,
    COUNT(distinct case when utm_source="gsearch" then website_sessions.website_session_id else null end) as gsearch,
	COUNT(distinct case when utm_source="bsearch" then website_sessions.website_session_id else null end) as bsearch,
    COUNT(distinct case when utm_source is null and http_referer is not null then website_sessions.website_session_id else null end) as organic_search,
    COUNT(distinct case when utm_source is null and http_referer is null then website_sessions.website_session_id else null end) as direct_search
FROM website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
where website_sessions.created_at<"2012-11-27"
group by 1,2
;

-- Question 5
SELECT 
	Year(website_sessions.created_at) as Year_Period,
	Month(website_sessions.created_at) as Month_Period,
    COUNT(distinct website_sessions.website_session_id) as sessions,
	COUNT(distinct orders.order_id) as order_count,
    COUNT(distinct orders.order_id)/COUNT(distinct website_sessions.website_session_id) as conv_rate
FROM website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
where  website_sessions.created_at<"2012-11-27"
group by 1,2
;

-- Question 6
SELECT
	*
FROM website_pageviews
WHERE pageview_url="/lander-1"
;

SELECT
	website_pageviews.pageview_url,
	COUNT(distinct website_pageviews.website_session_id) as sessions,
    COUNT(distinct orders.order_id) as orders,
    COUNT(distinct orders.order_id)/COUNT(distinct website_pageviews.website_session_id) as conv_rate
FROM website_pageviews
left join orders
on website_pageviews.website_session_id=orders.website_session_id
WHERE 
	website_pageviews.created_at between "2012-06-19" and "2012-07-28"
	and website_pageviews.website_pageview_id>=23504
    and website_pageviews.pageview_url in ("/home","/lander-1")
group by 1
;

-- Question 7
SELECT distinct
pageview_url
FROM website_pageviews;


create temporary table first_step
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    case when website_pageviews.pageview_url="/home" then 1 else 0 end as home_entry,
    case when website_pageviews.pageview_url="/lander-1" then 1 else 0 end as land_entry,
    case when website_pageviews.pageview_url="/products" then 1 else 0 end as product,
    case when website_pageviews.pageview_url="/the-original-mr-fuzzy" then 1 else 0 end as fuzzy,
    case when website_pageviews.pageview_url="/cart" then 1 else 0 end as cart,
    case when website_pageviews.pageview_url="/shipping" then 1 else 0 end as shipping,
    case when website_pageviews.pageview_url="/billing" then 1 else 0 end as billing,
    case when website_pageviews.pageview_url="/thank-you-for-your-order" then 1 else 0 end as thank
FROM
website_pageviews
WHERE
	website_pageviews.created_at between "2012-06-19" and "2012-07-28"
	and website_pageviews.website_pageview_id>=23504
order by website_pageviews.website_session_id,website_pageviews.created_at
;

create temporary table second_step
SELECT
	first_step.website_session_id,
    first_step.pageview_url,
	MAX(first_step.home_entry) as home_entry,
    MAX(first_step.land_entry) as land_entry,
    MAX(first_step.product) as product,
    MAX(first_step.fuzzy) as fuzzy,
    MAX(first_step.cart) as cart,
    MAX(first_step.shipping) as shipping,
    MAX(first_step.billing) as billing,
    MAX(first_step.thank) as thank
FROM first_step
group by 1
;

create temporary table third_step
SELECT
	second_step.pageview_url,
    SUM(second_step.home_entry) + SUM(second_step.land_entry) as sessions,
    SUM(second_step.product) as product_count,
    SUM(second_step.fuzzy) as fuzzy_count,
    SUM(second_step.cart) as cart_count,
    SUM(second_step.shipping) as shipping_count,
    SUM(second_step.billing) as billing_count,
    SUM(second_step.thank) as thank_count
FROM second_step
group by 1
;

SELECT
	pageview_url,
    product_count/sessions as to_procuct,
    fuzzy_count/product_count as to_fuzzy,
    cart_count/fuzzy_count as to_cart,
    shipping_count/cart_count as to_shipping,
    billing_count/shipping_count as to_billing,
    thank_count/billing_count as to_thank
FROM third_step
group by 1
;

SELECT * FROM third_step;

-- Question 8

SELECT
MIN(created_at),
Min(website_session_id)
FROM website_pageviews
where pageview_url="/billing-2"
;

SELECT
	website_pageviews.website_session_id,
	website_pageviews.pageview_url as billing_version,
    SUM(orders.price_usd) as total_revenue,
    SUM(orders.price_usd)/count(website_pageviews.website_session_id) as avg_revenue
FROM website_pageviews
Left join orders
on website_pageviews.website_session_id=orders.website_session_id
where 
	website_pageviews.created_at between "2012-09-10" and "2012-11-10"
	and website_pageviews.website_session_id>=25325
    and website_pageviews.pageview_url in ("/billing","/billing-2")
group by 2
;