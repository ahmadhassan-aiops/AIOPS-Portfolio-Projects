				-- 1. Basic Data Retrieval & Filtering

USE WideWorldImporters;
GO
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

--to get a list of all tables grouped by schema
SELECT 
    s.name AS SchemaName, 
    t.name AS TableName
FROM 
    sys.tables t
JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
ORDER BY 
    SchemaName, TableName;

---------------------------------------------------

--to get column details for all tables
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM 
    INFORMATION_SCHEMA.COLUMNS
ORDER BY 
    TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;


---------------------------------------------------------------------------------

					--	(Questions for Analysis)  --

-- 1.1 List all distinct countries where customers are located
SELECT DISTINCT CountryName
FROM Application.Countries;

-- 1.2 Count the number of customers in the United States
SELECT COUNT(*) AS USA_Customers
FROM Sales.Customers c
JOIN  Application.Cities ci ON c.DeliveryCityID = ci.CityID
JOIN Application.StateProvinces sp ON ci.StateProvinceID = sp.StateProvinceID
JOIN Application.Countries co ON sp.CountryID = co.CountryID
WHERE co.CountryName ='United States'

-- 1.3 Display the total number of customers
SELECT COUNT(*) AS Total_Customers
FROM Sales.Customers;

--------------------------------------------------------------------------------------------------


                -- 2. Logical Operators in Filtering

-- 2.1 List customers from the US or Canada with a non-null phone number
SELECT c.PhoneNumber, c.CustomerName
FROM Sales.Customers c
JOIN Application.Cities ci ON c.DeliveryCityID = ci.CityID
JOIN Application.StateProvinces sp ON ci.StateProvinceID = sp.StateProvinceID
JOIN Application.Countries co ON sp.CountryID = co.CountryID
WHERE co.CountryName IN ('United States','Canada')
AND c.PhoneNumber IS NOT NULL;

-- 2.2 Find customers in cities starting with 'A' and orders over $500
SELECT c.CustomerID, c.CustomerName, ci.CityName, ct.TransactionAmount
FROM Sales.Customers c
JOIN Sales.CustomerTransactions ct ON ct.CustomerID  = c.CustomerID
JOIN Application.Cities ci ON ci.CityID = c.DeliveryCityID
WHERE ci.CityName LIKE 'A%'
AND ct.TransactionAmount > 500
ORDER BY TransactionAmount

-- 2.3 Identify customers with no orders

SELECT c.CustomerID, c.CustomerName
FROM Sales.Customers c
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NOT NULL;


 
--------------------------------------------------------------------------------------------------


					-- 3. Aggregate Functions & Aliases


-- 3.1 Show total and average sales per product category, rounded
SELECT sgr.StockGroupName ,ROUND(SUM(il.ExtendedPrice),2) AS TotalSales, ROUND(AVG(il.ExtendedPrice),2) AS AvgSales
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sg ON sg.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sgr ON sgr.StockGroupID = sg.StockGroupID
GROUP BY sgr.StockGroupName
ORDER BY AvgSales DESC;


-- to specify the decimal places
SELECT CAST(SUM(il.ExtendedPrice) AS DECIMAL(10,1)) AS TotalSales
FROM Sales.InvoiceLines il;



-- 3.2 Count the number of products per category
SELECT sgr.StockGroupName, COUNT(si.StockItemID) AS ProductCount
FROM Warehouse.StockItems si
JOIN Warehouse.StockItemStockGroups sg ON sg.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sgr ON sgr.StockGroupID = sg.StockGroupID
GROUP BY sgr.StockGroupName
ORDER BY ProductCount DESC;


-- 3.3 Number of orders per customer
SELECT c.CustomerID, c.CustomerName , COUNT(o.OrderID) AS OrderCount
FROM Sales.Customers c
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
ORDER BY OrderCount DESC;


--------------------------------------------------------------------------------------------------

				-- 4. Sorting and Grouping



-- 4.1 Show top 10 products by total sales in the last year
SELECT TOP 10 
	si.StockItemName AS Product,
	SUM(il.ExtendedPrice) AS TotalSales
FROM Sales.InvoiceLines il
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
WHERE i.InvoiceDate >= DATEADD(YEAR,-1, GETDATE())
GROUP BY si.StockItemName




-- 4.2 Display total sales per product category with sales > $10,000
SELECT sg.StockGroupName As Product_Category, SUM(il.ExtendedPrice) AS TotalSales
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sgr ON sgr.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sg ON sg.StockGroupID = sgr.StockGroupID
GROUP BY sg.StockGroupName
HAVING SUM(il.ExtendedPrice) > 10000
ORDER BY TotalSales DESC;

-- 4.2 Display avg sales per product category with sales > $10,000
SELECT sg.StockGroupName As Product_Category, AVG(il.ExtendedPrice) AS AvgSales
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sgr ON sgr.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sg ON sg.StockGroupID = sgr.StockGroupID
GROUP BY sg.StockGroupName
HAVING SUM(il.ExtendedPrice) > 10000
ORDER BY AvgSales DESC;

--------------------------------------------------------------------------------------------------


				-- 5. Joins


-- 5.1 Use INNER JOIN to find customers with orders

SELECT c.CustomerID,c.CustomerName,o.OrderID,o.OrderDate
FROM Sales.Customers c
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID

-- 5.2 Use LEFT JOIN to show all customers and their orders
SELECT c.CustomerID,c.CustomerName,o.OrderID,o.OrderDate
FROM Sales.Customers c
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID



--5.3 Compare Stock Items with Same Price
SELECT 
    A.StockItemID AS ItemA_ID,
    A.StockItemName AS ItemA_Name,
    B.StockItemID AS ItemB_ID,
    B.StockItemName AS ItemB_Name,
    A.UnitPrice
FROM 
    Warehouse.StockItems A
JOIN 
    Warehouse.StockItems B
    ON A.UnitPrice = B.UnitPrice
	-- avoid self-matching and duplicates
   AND A.StockItemID < B.StockItemID;  


Select * FROM Warehouse.StockItems

-- 5.4 Employees and Their Managers
SELECT e1.EmployeeID AS EmployeeID, 
       e1.FirstName + ' ' + e1.LastName AS EmployeeName, 
       e2.FirstName + ' ' + e2.LastName AS ManagerName
FROM Employees e1
LEFT JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID;



--------------------------------------------------------------------------------------------------

				-- 6. Set Operations


-- 6.1 Find products sold in both January and February
SELECT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
	SELECT il1.StockItemID
	FROM Sales.InvoiceLines il1
	JOIN Sales.Invoices il ON il1.InvoiceID =il.InvoiceID
	WHERE MONTH(il.InvoiceDate) = 1
)
AND si.StockItemID IN (
	SELECT il1.StockItemID
	FROM Sales.InvoiceLines il1
	JOIN Sales.Invoices il ON il1.InvoiceID =il.InvoiceID
	WHERE MONTH(il.InvoiceDate) = 2
)
ORDER BY si.StockItemName;

-- 6.2 List products sold in January but not in july
SELECT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
	SELECT il1.StockItemID
	FROM Sales.InvoiceLines il1
	JOIN Sales.Invoices il ON il1.InvoiceID =il.InvoiceID
	WHERE MONTH(il.InvoiceDate) = 1
)
AND si.StockItemID NOT IN (
	SELECT il1.StockItemID
	FROM Sales.InvoiceLines il1
	JOIN Sales.Invoices il ON il1.InvoiceID =il.InvoiceID
	WHERE MONTH(il.InvoiceDate) = 7
)
ORDER BY si.StockItemName;

											--Another way--

SELECT DISTINCT il1.StockItemID
FROM Sales.InvoiceLines il1
JOIN Sales.Invoices i1 ON il1.InvoiceID = i1.InvoiceID
WHERE MONTH(i1.InvoiceDate) = 1

-- {1,2,3,4} , {1,2}  difference of sets (except) {3,4}
EXCEPT 

SELECT DISTINCT il2.StockItemID
FROM Sales.InvoiceLines il2
JOIN Sales.Invoices i2 ON il2.InvoiceID = i2.InvoiceID
WHERE MONTH(i2.InvoiceDate) = 7;


-- 6.3 Get all unique products sold in Jan or July

SELECT DISTINCT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices i1 ON il1.InvoiceID = i1.InvoiceID
    WHERE MONTH(i1.InvoiceDate) = 1

	-- all unique records in both table {1,2,3,4} , {1,2}  union {1,2,3,4}  
    UNION 

    SELECT il2.StockItemID
    FROM Sales.InvoiceLines il2
    JOIN Sales.Invoices i2 ON il2.InvoiceID = i2.InvoiceID
    WHERE MONTH(i2.InvoiceDate) = 7

ORDER BY si.StockItemName;


-- 6.3 Get all products sold in both Jan or July
SELECT DISTINCT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices i1 ON il1.InvoiceID = i1.InvoiceID
    WHERE MONTH(i1.InvoiceDate) = 1

	-- same records will be fetched {1,2,3,4} , {1,2}  Intersect {1,2}
    INTERSECT 

    SELECT il2.StockItemID
    FROM Sales.InvoiceLines il2
    JOIN Sales.Invoices i2 ON il2.InvoiceID = i2.InvoiceID
    WHERE MONTH(i2.InvoiceDate) = 7
)
ORDER BY si.StockItemName;


--------------------------------------------------------------------------------------------------


				-- 7. CASE Statements


-- 7.1 Categorize products into High, Medium, or Low based on quantity sold
SELECT 
    si.StockItemID,
    si.StockItemName,
    SUM(il.Quantity) AS TotalQuantitySold,
    CASE 
        WHEN SUM(il.Quantity) > 100000 THEN 'High'
        WHEN SUM(il.Quantity) BETWEEN 50000 AND 100000  THEN 'Medium'
        ELSE 'Low'
    END AS SalesCategory
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
GROUP BY si.StockItemID, si.StockItemName
ORDER BY TotalQuantitySold DESC;


-- 7.2 Create a discount pricing model using CASE based on quantity sold

SELECT 
    si.StockItemID,
    si.StockItemName,
    SUM(il.Quantity) AS TotalQuantitySold,
    ROUND(AVG(il.UnitPrice), 2) AS AvgUnitPrice,
    
    CASE 
        WHEN SUM(il.Quantity) > 100000 THEN 0.15
        WHEN SUM(il.Quantity) BETWEEN 50000 AND 100000 THEN 0.10
        ELSE 0.05
    END AS DiscountRate,

    ROUND(
        AVG(il.UnitPrice) * 
        CASE 
            WHEN SUM(il.Quantity) > 100000 THEN 0.85
            WHEN SUM(il.Quantity) BETWEEN 50000 AND 100000 THEN 0.90
            ELSE 0.95
        END, 2
    ) AS DiscountedPrice

FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
GROUP BY si.StockItemID, si.StockItemName
ORDER BY TotalQuantitySold DESC;

--------------------------------------------------------------------------------------------------


				-- 8. Subqueries


-- 8.1 Show total amount spent by each customer (subquery in SELECT)
SELECT c.CustomerID, c.CustomerName,
		(	SELECT SUM(il.Quantity * il.UnitPrice)
			FROM Sales.Invoices i
			JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
			WHERE i.CustomerID = c.CustomerID
		) AS TotalSpent
FROM Sales.Customers c
ORDER BY TotalSpent DESC;


-- 8.2 Identify customers who spent more than average (subquery in HAVING)
SELECT c.CustomerID, 
	   c.CustomerName,
	   SUM(il.Quantity * il.UnitPrice) AS TotalSpent
FROM Sales.Customers c
JOIN Sales.Invoices i ON c.CustomerID = i.CustomerID
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerID,c.CustomerName
HAVING SUM(il.Quantity * il.UnitPrice) > (
	SELECT AVG(CustomerTotal)
	FROM (
		SELECT SUM(il2.Quantity * il2.UnitPrice) AS CustomerTotal
		FROM Sales.Invoices i2
		JOIN Sales.InvoiceLines il2 ON i2.InvoiceID = il2.InvoiceID
		GROUP BY i2.CustomerID
	) AS SubAvg
)
ORDER BY TotalSpent



-- Declare a variable to hold average spend per customer
DECLARE @AverageSpend DECIMAL(18,2);

-- Calculate the average spend per customer
SELECT @AverageSpend = AVG(CustomerTotal)
FROM (
    SELECT SUM(il.Quantity * il.UnitPrice) AS CustomerTotal
    FROM Sales.Invoices i
    JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    GROUP BY i.CustomerID
) AS SubAvg;

-- Main query: list customers who spent more than that average
SELECT 
    c.CustomerID,
    c.CustomerName,
    SUM(il.Quantity * il.UnitPrice) AS TotalSpent,
    @AverageSpend AS AverageCustomerSpend
FROM Sales.Customers c
JOIN Sales.Invoices i ON c.CustomerID = i.CustomerID
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerID, c.CustomerName
HAVING SUM(il.Quantity * il.UnitPrice) > @AverageSpend
ORDER BY TotalSpent DESC;



-- 8.3 Use a derived table to list top 5 products by sales
SELECT TOP 5
	Derived.StockItemID,
	Derived.StockItemName, 
	CAST(Derived.TotalSales / 1000000.0 AS decimal(10,1)) AS TotalSalesInMillions
FROM(
	SELECT si.StockItemID,StockItemName, SUM(il.Quantity*il.UnitPrice) AS TotalSales
	FROM Sales.InvoiceLines il
	JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
	GROUP BY si.StockItemID,si.StockItemName
) AS Derived
ORDER BY Derived.TotalSales DESC;

--------------------------------------------------------------------------------------------------


				-- 9. Window Functions with CTE

/*
------------------------------------------
-  What is a Window Function?
------------------------------------------
 window function is a function that:

- Looks at a row (like usual),
- But also looks around at other rows (the “window”),
- And then calculates something based on that group,
  without grouping or hiding any rows.

------------------------------------------
-  Why Use Window Functions?
------------------------------------------

- Rank rows
- Sum values across related rows
- Compare one row to another (e.g., running total, previous row)
- Divide data into parts (tiles, quartiles, etc.)

(In all the cases window function increase the readability of the output)

------------------------------------------
- Syntax:

<function_name>() OVER ([PARTITION BY ...] ORDER BY ...)

------------------------------------------
*/

---------------------------------------------------------------------------------------------------------------------------------------


-- ========================================
-- WINDOW FUNCTION TYPES IN SQL SERVER
-- ========================================

-- 1. Aggregate Window Functions:
-- Apply aggregate functions over a window of rows without collapsing them.
-- Examples: SUM(), AVG(), MIN(), MAX(), COUNT() used with OVER().
-- Useful for running totals, moving averages, etc.

-- 2. Ranking Window Functions:
-- Assign a unique or shared ranking number within a partition.
-- ROW_NUMBER(): Unique row number per partition.
-- RANK(): Shared rank with gaps for ties.
-- DENSE_RANK(): Shared rank without gaps.
-- NTILE(n): Divides rows into n equal buckets.

-- 3. Offset (Value) Window Functions:
-- Access values from other rows relative to the current row.
-- LAG(): Value from the previous row.
-- LEAD(): Value from the next row.
-- FIRST_VALUE(): First value in the window frame.
-- LAST_VALUE(): Last value in the window frame.

-- Note:
-- All window functions use the OVER() clause to define partitioning and ordering.
-- The OVER() clause can include:
   -- 1.PARTITION BY: Splits data into groups.
   -- 2. ORDER BY: Orders rows within each partition.
   -- 3. ROWS/RANGE clause (optional): Defines a frame of rows to operate over.

---------------------------------------------------------------------------------------------------------------------------------------


-- 9.1 Rank salespeople by total sales using RANK()
SELECT 
	i.SalespersonPersonID,
	p.FullName AS SalespersonName,
	SUM(il.Quantity * il.UnitPrice/1000000) AS TotalSalesInMillions,
	RANK() OVER (ORDER BY SUM(il.Quantity * il.UnitPrice/1000000) DESC) AS SalesRank
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
JOIN Application.People p ON i.SalespersonPersonID = p.PersonID
GROUP BY i.SalespersonPersonID, p.FullName;

-------------
WITH SalesTotals AS (
    SELECT 
        i.SalespersonPersonID,
        p.FullName AS SalespersonName,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales
    FROM Sales.Invoices i
    JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    JOIN Application.People p ON i.SalespersonPersonID = p.PersonID
    GROUP BY i.SalespersonPersonID, p.FullName
)
SELECT 
    SalespersonPersonID,
    SalespersonName,
    ROUND(TotalSales, 2) AS TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM SalesTotals;


-- 9.2 Assign a row number to each order using ROW_NUMBER()
SELECT 
	i.InvoiceID,
	i.CustomerID,
	SUM(il.Quantity * il.UnitPrice) AS TotalSales,
	ROW_NUMBER() OVER (ORDER BY i.Invoicedate) As RowNumb
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY i.InvoiceID, i.CustomerID, i.InvoiceDate;


-- 9.3 Compare current vs next month sales using LEAD()
SELECT 
	MONTH(i.InvoiceDate) AS SalesMonth,
	YEAR(i.InvoiceDate) AS SalesYear,
	SUM(il.Quantity * il.UnitPrice) AS TotalSales,
	LEAD(SUM(il.Quantity * il.UnitPrice)) OVER (ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)) AS NextMonthSales
FROM Sales.Invoices i
JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate);


WITH MonthlySales AS (
    SELECT 
        MONTH(i.InvoiceDate) AS SalesMonth,
        YEAR(i.InvoiceDate) AS SalesYear,
        SUM(il.Quantity * il.UnitPrice) AS TotalSales
    FROM Sales.Invoices i
    JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
)
SELECT 
    SalesMonth,
    SalesYear,
    TotalSales,
    LEAD(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) AS NextMonthSales
FROM MonthlySales
ORDER BY SalesYear, SalesMonth;


-- 9.4 Divide salespeople into quartiles using NTILE()
-- (Mostly we use it for performance analysis)

WITH SalesTotal As (
	SELECT 
		i.SalespersonPersonID,
		p.FullName AS SalespersonName,
		SUM(il.Quantity * il.UnitPrice/1000000) AS TotalSalesInMillions,
		NTILE(4) OVER (ORDER BY SUM(il.Quantity * il.UnitPrice/1000000) DESC) AS SalesQuartile
	FROM Sales.Invoices i
	JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
	JOIN Application.People p ON i.SalespersonPersonID = p.PersonID
	GROUP BY i.SalespersonPersonID, p.FullName 
);
--------------------------------------------------------------------------------------------------


			-- 10. Recursive CTEs




/*

=================================================================================
- What is a CTE (Common Table Expression)?
=================================================================================
A CTE is like a temporary result set (or a named subquery) that you can reference 
within a `SELECT`, `INSERT`, `UPDATE`, or `DELETE` query.

It's helpful for:
- Breaking complex queries into readable parts
- Avoiding subquery repetition
- Improving query clarity and maintenance

------------------------------------------
- Basic CTE Syntax:

WITH CTE_Name AS (
    SELECT ...
)
SELECT * FROM CTE_Name;

=================================================================================
- What is a Recursive CTE?
=================================================================================
A Recursive CTE is a CTE that refers to itself. It's used for hierarchical or 
sequential data, such as:

- Organization charts (employee-manager)
- Tree structures (categories/subcategories)
- Time-based sequences (e.g., next invoice, date ranges)

------------------------------------------
-  Recursive CTE Structure:

WITH RecursiveCTE AS (
    -- Anchor member (starting point)
    SELECT ...

    UNION ALL

    -- Recursive member (refers to itself)
    SELECT ...
    FROM RecursiveCTE
    JOIN ...
    WHERE ...
)
SELECT * FROM RecursiveCTE
OPTION (MAXRECURSION 0);  -- Prevents limit errors if many levels exist
*/



-- 10.1 What is the sequence of all items purchased by Customer ID 1, invoice by invoice, in chronological order — and label each with a level number to show the order?


/*
WITH RecursiveInvoice AS (
    -- Anchor Member: Select the first invoice for the customer
    SELECT 
        i.InvoiceID,
        i.CustomerID,
        il.StockItemID,
        il.Quantity,
        il.UnitPrice,
        1 AS Level,  -- Starting from Level 1 for the first invoice
        i.InvoiceDate  -- Added to ensure ordering
    FROM Sales.Invoices i
    JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    WHERE i.CustomerID = 1  -- Replace with a specific customer ID

    UNION ALL

    -- Recursive Member: Select subsequent invoices for the same customer, ordered by InvoiceDate
    SELECT 
        i.InvoiceID,
        i.CustomerID,
        il.StockItemID,
        il.Quantity,
        il.UnitPrice,
        ri.Level + 1 AS Level,  -- Increment the level for subsequent invoices
        i.InvoiceDate
    FROM Sales.Invoices i
    JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
    INNER JOIN RecursiveInvoice ri ON i.InvoiceDate > ri.InvoiceDate  -- Use InvoiceDate to get the next invoice
    WHERE i.CustomerID = 1  -- Replace with the same customer ID
)

-- Final select to get the results
SELECT 
    InvoiceID,
    StockItemID,
    Quantity,
    UnitPrice,
    Level
FROM RecursiveInvoice
ORDER BY Level, InvoiceID
OPTION (MAXRECURSION 0);
*/