SELECT *
FROM dbo.engagement_data;

SELECT
EngagementID,
CampaignID,
ContentID,
ProductID,
UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,
LEFT(ViewsClicksCombined, CHARINDEX('-',ViewsClicksCombined)-1) AS Views,
RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-',ViewsClicksCombined)) AS Clicks,
Likes,
FORMAT(CONVERT(DATE,EngagementDate), 'MM.dd.yyyy') AS EngagementDate
FROM dbo.engagement_data