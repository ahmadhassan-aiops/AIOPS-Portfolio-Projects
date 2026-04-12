CREATE DATABASE IF NOT EXISTS sponsorship_roi_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sponsorship_roi_db;

CREATE TABLE IF NOT EXISTS dim_athletes (
    athlete_id          VARCHAR(10)       NOT NULL,
    athlete_name        VARCHAR(100)      NOT NULL,
    sport               VARCHAR(50)       NOT NULL,
    region              VARCHAR(50)       NOT NULL,
    nationality         VARCHAR(50)       NOT NULL,
    age                 TINYINT UNSIGNED  NOT NULL,
    performance_score   DECIMAL(5,2)      NOT NULL,
    ranking             SMALLINT UNSIGNED NOT NULL,
    popularity_index    DECIMAL(5,2)      NOT NULL,
    social_followers    INT UNSIGNED      NOT NULL,
    contract_value      DECIMAL(15,2)     NOT NULL,
    years_sponsored     TINYINT UNSIGNED  NOT NULL,
    podium_rate_pct     DECIMAL(5,2)      NOT NULL,

    CONSTRAINT pk_athletes PRIMARY KEY (athlete_id)
);

CREATE TABLE IF NOT EXISTS fact_events (
    event_id            VARCHAR(10)       NOT NULL,
    sport               VARCHAR(50)       NOT NULL,
    event_name          VARCHAR(150)      NOT NULL,
    event_date          DATE              NOT NULL,
    event_year          YEAR              NOT NULL,
    event_month         VARCHAR(15)       NOT NULL,
    event_quarter       CHAR(2)           NOT NULL,
    region              VARCHAR(50)       NOT NULL,
    host_city           VARCHAR(100)      NOT NULL,
    event_type          VARCHAR(50)       NOT NULL,
    broadcast_type      VARCHAR(50)       NOT NULL,
    sponsorship_cost    DECIMAL(15,2)     NOT NULL,
    duration_days       TINYINT UNSIGNED  NOT NULL,

    CONSTRAINT pk_events PRIMARY KEY (event_id)
);

CREATE TABLE IF NOT EXISTS fact_engagement (
    event_id                VARCHAR(10)       NOT NULL,
    views                   BIGINT UNSIGNED   NOT NULL,
    social_impressions      BIGINT UNSIGNED   NOT NULL,
    likes                   INT UNSIGNED      NOT NULL,
    shares                  INT UNSIGNED      NOT NULL,
    comments                INT UNSIGNED      NOT NULL,
    engagement_rate_pct     DECIMAL(5,2)      NOT NULL,
    pre_event_eng_pct       DECIMAL(5,2)      NOT NULL,
    post_event_eng_pct      DECIMAL(5,2)      NOT NULL,
    platform                VARCHAR(50)       NOT NULL,
    brand_mentions          INT UNSIGNED      NOT NULL,
    hashtag_reach           BIGINT UNSIGNED   NOT NULL,
    short_form_video_views  BIGINT UNSIGNED   NOT NULL,
    sentiment_score         DECIMAL(3,2)      NOT NULL,
    follower_growth         INT UNSIGNED      NOT NULL,

    CONSTRAINT pk_engagement PRIMARY KEY (event_id),
    CONSTRAINT fk_engagement_event
        FOREIGN KEY (event_id) REFERENCES fact_events (event_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS fact_revenue_proxy (
    event_id                    VARCHAR(10)    NOT NULL,
    est_revenue_contribution    DECIMAL(15,2)  NOT NULL,
    cpm_based_revenue           DECIMAL(15,2)  NOT NULL,
    conversion_factor           DECIMAL(10,4)  NOT NULL,
    brand_awareness_lift_pct    DECIMAL(5,2)   NOT NULL,
    media_value                 DECIMAL(15,2)  NOT NULL,
    merch_revenue_proxy         DECIMAL(15,2)  NOT NULL,
    revenue_attribution_model   VARCHAR(50)    NOT NULL,

    CONSTRAINT pk_revenue_proxy PRIMARY KEY (event_id),
    CONSTRAINT fk_revenue_event
        FOREIGN KEY (event_id) REFERENCES fact_events (event_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS bridge_event_athletes (
    bridge_id               VARCHAR(10)   NOT NULL,
    event_id                VARCHAR(10)   NOT NULL,
    athlete_id              VARCHAR(10)   NOT NULL,
    athlete_role            VARCHAR(50)   NOT NULL,
    event_performance_score DECIMAL(5,2)  NOT NULL,
    podium_finish           VARCHAR(5)    NULL,

    CONSTRAINT pk_bridge PRIMARY KEY (bridge_id),
    CONSTRAINT uq_bridge_event_athlete UNIQUE (event_id, athlete_id),
    CONSTRAINT fk_bridge_event
        FOREIGN KEY (event_id)   REFERENCES fact_events  (event_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bridge_athlete
        FOREIGN KEY (athlete_id) REFERENCES dim_athletes (athlete_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_events_sport     ON fact_events (sport);
CREATE INDEX idx_events_region    ON fact_events (region);
CREATE INDEX idx_events_year      ON fact_events (event_year);
CREATE INDEX idx_events_quarter   ON fact_events (event_quarter);
CREATE INDEX idx_events_date      ON fact_events (event_date);
CREATE INDEX idx_eng_platform     ON fact_engagement (platform);
CREATE INDEX idx_rev_model        ON fact_revenue_proxy (revenue_attribution_model);
CREATE INDEX idx_ath_sport        ON dim_athletes (sport);
CREATE INDEX idx_ath_region       ON dim_athletes (region);
CREATE INDEX idx_bridge_event     ON bridge_event_athletes (event_id);
CREATE INDEX idx_bridge_athlete   ON bridge_event_athletes (athlete_id);