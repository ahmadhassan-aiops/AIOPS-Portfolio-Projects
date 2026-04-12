USE sponsorship_roi_db;

SELECT 'dim_athletes',          COUNT(*) FROM dim_athletes;
SELECT 'fact_events',            COUNT(*) FROM fact_events;
SELECT 'fact_engagement',        COUNT(*) FROM fact_engagement;
SELECT 'fact_revenue_proxy',     COUNT(*) FROM fact_revenue_proxy;
SELECT 'bridge_event_athletes',  COUNT(*) FROM bridge_event_athletes;