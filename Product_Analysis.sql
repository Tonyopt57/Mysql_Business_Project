-- Product Analysis

-- pull monthly trends to date for number of sales,total revenue, and total margin generated 
SELECT
	year(created_at) as yr,
    month(created_at) as mo,
    COUNT(order_id) as num_of_sales,
    SUM(price_usd) as total_revenue,
    SUM(price_usd-cogs_usd) as total_margin
FROM orders
where orders.created_at<"2013-01-04"
group by mo
;

-- monthly order volume, overall conversion rate, revenue per session, and a breakdown of sales by product.

SELECT
	year(website_sessions.created_at) as yr,
    month(website_sessions.created_at) as mo,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) as conv_rate,
    SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) as revenue_per_session,
    COUNT(distinct case when orders.primary_product_id=1 then orders.order_id else null end) as product_one_orders,
    COUNT(distinct case when orders.primary_product_id=2 then orders.order_id else null end) as product_two_orders
FROM website_sessions
left join orders
on website_sessions.website_session_id=orders.website_session_id
where website_sessions.created_at between "2012-04-01" and "2013-04-05"
group by 2
;

/* product level website analysis:
	learning how customers interact with each of the data and how well each product converts customers.
*/

SELECT distinct
pageview_url
FROM website_pageviews
;

create temporary table times
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    case when created_at<"2013-01-06" Then "A. pre_product_2"
    when created_at>="2013-01-06" Then "B. post_product_2"
    else "check again" end as time_period 
FROM website_pageviews
where created_at between "2012-10-06" and "2013-04-06" and pageview_url="/products"
;

SELECT * from times;

create temporary table session_w_next_pageview
SELECT
	times.time_period,
    times.website_session_id,
    MIN(website_pageviews.website_pageview_id) as min_next_pageview_id
FROM times
left join website_pageviews
on 
	times.website_session_id=website_pageviews.website_session_id
	and website_pageviews.website_pageview_id>times.website_pageview_id
group by 1,2
;

create temporary table session_w_next_pageName
SELECT
	session_w_next_pageview.time_period,
    session_w_next_pageview.website_session_id,
    website_pageviews.pageview_url as next_page
FROM session_w_next_pageview
left join website_pageviews
on website_pageviews.website_pageview_id=session_w_next_pageview.min_next_pageview_id
;

SELECT
	session_w_next_pageName.time_period,
    COUNT(session_w_next_pageName.website_session_id) as sessions,
    COUNT(session_w_next_pageName.next_page) as w_next_pg,
    COUNT(session_w_next_pageName.next_page)/COUNT(session_w_next_pageName.website_session_id) as pct_w_next_page,
    COUNT(case when next_page="/the-original-mr-fuzzy" then website_session_id else null end ) as to_fuzzy,
    COUNT(case when next_page="/the-original-mr-fuzzy" then website_session_id else null end )/COUNT(session_w_next_pageName.website_session_id) as pct_to_fuzzy,
    COUNT(case when next_page="/the-forever-love-bear" then website_session_id else null end ) as to_bear,
    COUNT(case when next_page="/the-forever-love-bear" then website_session_id else null end )/COUNT(session_w_next_pageName.website_session_id) as pct_to_bear
FROM session_w_next_pageName
group by 1
;

-- Conversion funnel for each product.
create temporary table step_1
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url
FROM website_pageviews
WHERE 
	created_at between "2013-01-06" and "2013-04-10"
	and pageview_url in ("/the-original-mr-fuzzy","/the-forever-love-bear")
;

SELECT distinct          -- to see what label we should look for to build to the funnel after the product page
	website_pageviews.pageview_url
FROM step_1
	left join website_pageviews
		on website_pageviews.website_session_id=step_1.website_session_id
        and website_pageviews.website_pageview_id>step_1.website_pageview_id
;


create temporary table step_2
SELECT 
	step_1.website_session_id,
    step_1.pageview_url,
    case when website_pageviews.pageview_url="/cart" then 1 else 0 end as cart,
    case when website_pageviews.pageview_url="/shipping" then 1 else 0 end as shipping,
    case when website_pageviews.pageview_url="/billing-2" then 1 else 0 end as billing,
    case when website_pageviews.pageview_url="/thank-you-for-your-order" then 1 else 0 end as thank
FROM step_1
	left join website_pageviews
		on 
        website_pageviews.website_session_id=step_1.website_session_id
		and website_pageviews.website_pageview_id>step_1.website_pageview_id
;

Create temporary table step_3
SELECT 
	step_2.website_session_id,
    step_2.pageview_url,
	max(step_2.cart) as cart_count,
    max(step_2.shipping) as shipping_count,
    max(step_2.billing) as billing_count,
    max(step_2.thank) as thank_count
FROM step_2
group by 1
;

SELECT
	case 
		when pageview_url="/the-original-mr-fuzzy" then "mrfuzzy"
		when pageview_url="/the-forever-love-bear" then "lovebear"
        else null end as product_seen,
	COUNT(step_3.website_session_id) as sessions,
    SUM(step_3.cart_count) as cart_num,
    SUM(step_3.shipping_count) as shipping_num,
    SUM(step_3.billing_count) as billing_num,
    SUM(step_3.thank_count) as thank_num
FROM step_3
group by 1
;

SELECT
	case 
		when pageview_url="/the-original-mr-fuzzy" then "mrfuzzy"
		when pageview_url="/the-forever-love-bear" then "lovebear"
        else null end as product_seen,
	COUNT(step_3.website_session_id) as sessions,
    SUM(step_3.cart_count)/COUNT(step_3.website_session_id) as product_clickthrough_rate,
    SUM(step_3.shipping_count)/SUM(step_3.cart_count) as cart_clickthrough_rate,
    SUM(step_3.billing_count)/SUM(step_3.shipping_count) as shipping_clickthrough_rate,
    SUM(step_3.thank_count)/SUM(step_3.billing_count) as billing_clickthrough_rate
FROM step_3
group by 1
;


-- Cross-selling Product

create temporary table step_one
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    case when created_at<"2013-09-25" Then "A. pre_cross_sell"
    when created_at>="2013-09-25" Then "B. post_cross_sell"
    else "check again" end as time_period 
FROM website_pageviews
where created_at between "2013-08-25" and "2013-10-25" and pageview_url="/cart"
;



SELECT
	step_one.time_period,
	COUNT(step_one.website_session_id) as cart_sessions,
    COUNT(orders.order_id) as clickthroughs,
    COUNT(orders.order_id)/COUNT(step_one.website_session_id) as cart_ctr,
    SUM(orders.items_purchased)/COUNT(orders.order_id) as product_per_order,
    SUM(orders.price_usd)/COUNT(orders.order_id) as aov,
    SUM(orders.price_usd)/COUNT(step_one.website_session_id) as rev_per_cart_session
FROM step_one
left join orders
on orders.website_session_id=step_one.website_session_id
group by 1
;

-- product portfolio expansion

SELECT
	case when website_sessions.created_at<"2013-12-12" then "A.pre_birthday_bear"
		when website_sessions.created_at>="2013-12-12" then "B.post_birthday_bear"
        else "plz check again" end as time_period,
	COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.order_id) as orders,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) as con_rate,
    SUM(orders.price_usd) as total_revenue,
    SUM(orders.items_purchased) as total_item_sold,
    SUM(orders.price_usd)/SUM(orders.items_purchased) as avg_item_value,
    SUM(orders.price_usd)/COUNT(orders.order_id) as avg_order_value,
    SUM(orders.price_usd)/COUNT(website_sessions.website_session_id) as avg_session_revenue
FROM website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id
where website_sessions.created_at between "2013-11-12" and "2014-01-12"
group by time_period
;

-- refund analysis
-- show refund rate for each product.
SELECT
	year(order_items.created_at) as yr,
    month(order_items.created_at) as mo,
    COUNT(distinct case when order_items.product_id=1 then order_items.order_item_id else null end) as p1_order,
    COUNT(distinct case when order_items.product_id=1 then order_item_refunds.order_item_id else null end)/COUNT(distinct case when order_items.product_id=1 then order_items.order_item_id else null end) as p1_refund_rt,
    COUNT(distinct case when order_items.product_id=2 then order_items.order_item_id else null end) as p2_order,
	COUNT(distinct case when order_items.product_id=2 then order_item_refunds.order_item_id else null end)/COUNT(distinct case when order_items.product_id=2 then order_items.order_item_id else null end) as p2_refund_rt,
    COUNT(distinct case when order_items.product_id=3 then order_items.order_item_id else null end) as p3_order,
	COUNT(distinct case when order_items.product_id=4 then order_item_refunds.order_item_id else null end)/COUNT(distinct case when order_items.product_id=3 then order_items.order_item_id else null end) as p3_refund_rt,
    COUNT(distinct case when order_items.product_id=2 then order_items.order_item_id else null end) as p4_order,
    COUNT(distinct case when order_items.product_id=4 then order_item_refunds.order_item_id else null end)/COUNT(distinct case when order_items.product_id=4 then order_items.order_item_id else null end) as p4_refund_rt
FROM order_items
left join order_item_refunds
on order_items.order_item_id=order_item_refunds.order_item_id
where order_items.created_at<"2014-10-15"
group by 1,2
;

