Select *
From dbo.customer_journey;


WITH DuplicateRecords AS (
	SELECT
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		ROW_NUMBER() OVER( PARTITION BY CustomerID,ProductID,VisitDate,Stage, Action ORDER BY JourneyID) AS row_num
	FROM dbo.customer_journey
)

SELECT *
FROM DuplicateRecords
WHERE row_num > 1;


---

SELECT 
    JourneyID,  -- Selects the unique identifier for each journey to ensure data traceability
    CustomerID,  -- Selects the unique identifier for each customer to link journeys to specific customers
    ProductID,  -- Selects the unique identifier for each product to analyze customer interactions with different products
    VisitDate,  -- Selects the date of the visit to understand the timeline of customer interactions
    Stage,  -- Uses the uppercased stage value from the subquery for consistency in analysis
    Action,  -- Selects the action taken by the customer (e.g., View, Click, Purchase)
    COALESCE(Duration, avg_duration) AS Duration  -- Replaces missing durations with the average duration for the corresponding date
FROM 
    (
        -- Subquery to process and clean the data
        SELECT 
            JourneyID,  -- Selects the unique identifier for each journey to ensure data traceability
            CustomerID,  -- Selects the unique identifier for each customer to link journeys to specific customers
            ProductID,  -- Selects the unique identifier for each product to analyze customer interactions with different products
            VisitDate,  -- Selects the date of the visit to understand the timeline of customer interactions
            UPPER(Stage) AS Stage,  -- Converts Stage values to uppercase for consistency in data analysis
            Action,  -- Selects the action taken by the customer (e.g., View, Click, Purchase)
            Duration,  -- Uses Duration directly, assuming it's already a numeric type
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  -- Calculates the average duration for each date, using only numeric values
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action  -- Groups by these columns to identify duplicate records
                ORDER BY JourneyID  -- Orders by JourneyID to keep the first occurrence of each duplicate
            ) AS row_num  -- Assigns a row number to each row within the partition to identify duplicates
        FROM 
            dbo.customer_journey  -- Specifies the source table from which to select the data
    ) AS subquery  -- Names the subquery for reference in the outer query
WHERE 
    row_num = 1;  -- Keeps only the first occurrence of each duplicate group identified in the subquery
