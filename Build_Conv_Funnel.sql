create temporary table steps
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    case when pageview_url="/products" Then 1 else 0 end as product_page,
    case when pageview_url="/the-original-mr-fuzzy" Then 1 else 0 end as fuzzy_page,
	case when pageview_url="/cart" Then 1 else 0 end as cart_page,
    case when pageview_url="/shipping" Then 1 else 0 end as shipping_page,
    case when pageview_url="/billing" Then 1 else 0 end as billing_page,
    case when pageview_url="/thank-you-for-your-order" Then 1 else 0 end as thank_page
FROM website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where 
	website_sessions.created_at between "2012-08-05" and "2012-09-05"
	-- and pageview_url in ("/lander-1","/products","/the-original-mr-fuzzy","/cart","/shipping","/billing","/thank-you-for-your-order")
    and website_sessions.utm_source="gsearch"
    and website_sessions.utm_campaign="nonbrand"
;

Create temporary table steps_visit    
SELECT
	steps.website_session_id,
    steps.pageview_url,
    steps.created_at,
    MAX(steps.product_page) as product_visit,
    MAX(steps.fuzzy_page) as fuzzy_visit,
    MAX(steps.cart_page) as cart_visit,
    MAX(steps.shipping_page) as shipping_visit,
    MAX(steps.billing_page) as billing_visit,
    MAX(steps.thank_page) as thank_visit
FROM steps
group by steps.website_session_id
;

create temporary table steps_counts
SELECT
	COUNT(steps_visit.website_session_id) as sessions,
    SUM(steps_visit.product_visit) as product_num,
    SUM(steps_visit.fuzzy_visit) as fuzzy_num,
    SUM(steps_visit.cart_visit) as cart_num,
    SUM(steps_visit.shipping_visit) as shipping_num,
    SUM(steps_visit.billing_visit) as billing_num,
    SUM(steps_visit.thank_visit) as thank_num
FROM steps_visit
;
SELECT * FROM steps_counts;

SELECT
    product_num/sessions as product_rate,
    fuzzy_num/product_num as fuzzy_rate,
    cart_num/product_num as cart_rate,
    shipping_num/cart_num as shipping_rate,
    billing_num/shipping_num as billing_rate,
    thank_num/billing_num as thank_rate
FROM steps_counts
;
