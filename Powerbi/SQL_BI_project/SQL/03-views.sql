-- VIEWS


-- VIEW 1 : vw_kpi_summary
CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT
    e.event_id,
    e.event_name,
    e.sport,
    e.region,
    e.event_year,
    e.event_quarter,
    e.event_date,
    e.event_type,
    e.broadcast_type,
    e.sponsorship_cost,
    e.duration_days,

    eng.views,
    eng.social_impressions,
    eng.likes,
    eng.shares,
    eng.comments,
    eng.engagement_rate_pct,
    eng.pre_event_eng_pct,
    eng.post_event_eng_pct,
    eng.platform,
    eng.brand_mentions,
    eng.hashtag_reach,
    eng.short_form_video_views,
    eng.sentiment_score,
    eng.follower_growth,

    rev.est_revenue_contribution,
    rev.cpm_based_revenue,
    rev.media_value,
    rev.merch_revenue_proxy,
    rev.brand_awareness_lift_pct,
    rev.revenue_attribution_model,

    -- KPI 1 : ROI %
    -- (Revenue - Cost) / Cost x 100
    ROUND(
        ((rev.est_revenue_contribution - e.sponsorship_cost) / e.sponsorship_cost) * 100
    , 2) AS roi_pct,

    -- KPI 2 : Cost per View
    -- Sponsorship Cost / Total Views
    ROUND(e.sponsorship_cost / NULLIF(eng.views, 0), 4)
        AS cost_per_view,

    -- KPI 3 : Cost per Engagement
    -- Sponsorship Cost / (Likes + Shares + Comments)
    ROUND(
        e.sponsorship_cost / NULLIF(eng.likes + eng.shares + eng.comments, 0)
    , 4) AS cost_per_engagement,

    -- KPI 4 : Engagement Lift
    -- Post-Event Engagement % - Pre-Event Engagement %
    ROUND(eng.post_event_eng_pct - eng.pre_event_eng_pct, 2)
        AS engagement_lift_pct,

    -- KPI 5 : Media ROI
    -- Earned Media Value / Sponsorship Cost
    ROUND(rev.media_value / NULLIF(e.sponsorship_cost, 0), 4)
        AS media_roi,

    -- KPI 6 : Revenue per Day
    -- Estimated Revenue / Event Duration in Days
    ROUND(rev.est_revenue_contribution / NULLIF(e.duration_days, 0), 2)
        AS revenue_per_day,

    -- KPI 7 : Attention Score  (Custom KPI - 0 to 100)
    ROUND(
        (eng.sentiment_score               * 100 * 0.40)
      + (eng.engagement_rate_pct                 * 0.30)
      + (rev.brand_awareness_lift_pct            * 0.20)
      + (LEAST(eng.follower_growth / 2000.0, 100) * 0.10)
    , 2) AS attention_score

FROM      fact_events        e
JOIN      fact_engagement    eng ON e.event_id = eng.event_id
JOIN      fact_revenue_proxy rev ON e.event_id = rev.event_id;

SELECT * FROM vw_kpi_summary;
-- -----------------------------------------------------------------------------
-- VIEW 2 : vw_roi_by_sport

CREATE OR REPLACE VIEW vw_roi_by_sport AS
SELECT
    sport,
    COUNT(event_id)                          AS total_events,
    ROUND(SUM(sponsorship_cost), 2)          AS total_spend,
    ROUND(SUM(est_revenue_contribution), 2)  AS total_revenue,
    ROUND(AVG(roi_pct), 2)                   AS avg_roi_pct,
    ROUND(AVG(cost_per_view), 4)             AS avg_cost_per_view,
    ROUND(AVG(cost_per_engagement), 4)       AS avg_cost_per_engagement,
    ROUND(AVG(attention_score), 2)           AS avg_attention_score
FROM  vw_kpi_summary
GROUP BY sport
ORDER BY avg_roi_pct DESC;

SELECT * FROM vw_roi_by_sport;

-- VIEW 3 : vw_engagement_lift

CREATE OR REPLACE VIEW vw_engagement_lift AS
SELECT
    sport,
    region,
    event_year,
    COUNT(event_id)                      AS total_events,
    ROUND(AVG(pre_event_eng_pct),  2)    AS avg_pre_event_eng_pct,
    ROUND(AVG(post_event_eng_pct), 2)    AS avg_post_event_eng_pct,
    ROUND(AVG(engagement_lift_pct), 2)   AS avg_engagement_lift_pct,
    ROUND(AVG(sentiment_score), 2)       AS avg_sentiment_score,
    ROUND(SUM(follower_growth), 0)       AS total_follower_growth
FROM  vw_kpi_summary
GROUP BY sport, region, event_year
ORDER BY avg_engagement_lift_pct DESC;

SELECT * FROM vw_engagement_lift;


-- VIEW 4 : vw_athlete_performance

CREATE OR REPLACE VIEW vw_athlete_performance AS
SELECT
    a.athlete_id,
    a.athlete_name,
    a.sport,
    a.region,
    a.nationality,
    a.age,
    a.performance_score,
    a.ranking,
    a.popularity_index,
    a.social_followers,
    a.contract_value,
    a.years_sponsored,
    a.podium_rate_pct,

    COUNT(b.event_id)                                                  AS total_events,
    ROUND(AVG(b.event_performance_score), 2)                           AS avg_event_performance,
    SUM(CASE WHEN b.podium_finish = '1'             THEN 1 ELSE 0 END) AS gold_finishes,
    SUM(CASE WHEN b.podium_finish IN ('1','2','3')  THEN 1 ELSE 0 END) AS total_podium_finishes,
    SUM(CASE WHEN b.athlete_role = 'Primary Athlete'    THEN 1 ELSE 0 END) AS primary_appearances,
    SUM(CASE WHEN b.athlete_role = 'Supporting Athlete' THEN 1 ELSE 0 END) AS supporting_appearances,

    ROUND(SUM(e.sponsorship_cost), 2)                                  AS total_event_spend,
    ROUND(a.contract_value / NULLIF(COUNT(b.event_id), 0), 2)         AS contract_cost_per_event

FROM       dim_athletes           a
LEFT JOIN  bridge_event_athletes  b ON a.athlete_id = b.athlete_id
LEFT JOIN  fact_events            e ON b.event_id   = e.event_id
GROUP BY
    a.athlete_id, a.athlete_name, a.sport, a.region, a.nationality,
    a.age, a.performance_score, a.ranking, a.popularity_index,
    a.social_followers, a.contract_value, a.years_sponsored, a.podium_rate_pct;

SELECT * FROM vw_athlete_performance;

-- VIEW 5 : vw_regional_growth


-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_regional_growth AS
SELECT
    region,
    event_year,
    event_quarter,
    COUNT(event_id)                           AS total_events,
    ROUND(SUM(follower_growth), 0)            AS total_follower_growth,
    ROUND(AVG(brand_awareness_lift_pct), 2)   AS avg_brand_awareness_lift_pct,
    ROUND(SUM(views), 0)                      AS total_views,
    ROUND(SUM(social_impressions), 0)         AS total_impressions,
    ROUND(AVG(sentiment_score), 2)            AS avg_sentiment_score,
    ROUND(SUM(sponsorship_cost), 2)           AS total_spend
FROM  vw_kpi_summary
GROUP BY region, event_year, event_quarter
ORDER BY event_year, event_quarter, total_follower_growth DESC;

SELECT * FROM vw_regional_growth;

-- VIEW 6 : vw_attention_score

CREATE OR REPLACE VIEW vw_attention_score AS
SELECT
    sport,
    ROUND(AVG(attention_score), 2)           AS avg_attention_score,
    ROUND(MAX(attention_score), 2)           AS max_attention_score,
    ROUND(MIN(attention_score), 2)           AS min_attention_score,
    COUNT(event_id)                          AS total_events,
    ROUND(AVG(sentiment_score), 2)           AS avg_sentiment,
    ROUND(AVG(engagement_rate_pct), 2)       AS avg_engagement_rate_pct,
    ROUND(AVG(brand_awareness_lift_pct), 2)  AS avg_brand_awareness_lift_pct
FROM  vw_kpi_summary
GROUP BY sport
ORDER BY avg_attention_score DESC;


SELECT * FROM vw_attention_score;