create temporary table first_page
SELECT
	website_session_id,
    Min(website_pageview_id) as landing_page
FROM website_pageviews
WHERE created_at<"2012-06-12"
group by website_session_id
;

create temporary table landing_page_num
SELECT 
	website_pageviews.pageview_url as entry_page,
    COUNT(distinct first_page.website_session_id) as sessions_hitting_this_landing_page
FROM first_page
left join website_pageviews
on website_pageviews.website_pageview_id=first_page.landing_page
group by entry_page
;

create temporary table landing_page_person
SELECT 
	first_page.website_session_id,
    website_pageviews.pageview_url as entry_url
FROM first_page
left join website_pageviews
on website_pageviews.website_session_id=first_page.website_session_id
group by first_page.website_session_id
;

Create temporary table bounce_session_only
SELECT 
	landing_page_person.website_session_id,
    landing_page_person.entry_url,
    count(website_pageviews.website_pageview_id) as count_num_views
FROM landing_page_person
left join website_pageviews
on website_pageviews.website_session_id=landing_page_person.website_session_id
group by landing_page_person.website_session_id, landing_page_person.entry_url
having count_num_views=1
;

SELECT 
	landing_page_person.entry_url,
    COUNT(distinct landing_page_person.website_session_id) as sessions,
    COUNT(bounce_session_only.website_session_id) as bound_session,
    COUNT(bounce_session_only.website_session_id)/COUNT(distinct landing_page_person.website_session_id) as bounce_rate
FROM landing_page_person
left join bounce_session_only
on landing_page_person.website_session_id=bounce_session_only.website_session_id
group by landing_page_person.entry_url
order by landing_page_person.website_session_id
;

