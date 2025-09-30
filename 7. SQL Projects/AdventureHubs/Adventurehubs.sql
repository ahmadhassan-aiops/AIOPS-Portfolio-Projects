
					-- AdventureWorks Sales Analysis

USE AdventureWorks2017;
GO

-- 1. Retrieve Top 5 customers by total purchases (TotalDue) between July 1, 2013 and June 30, 2014
SELECT TOP 5
	soh.CustomerID,
	p.FirstName + ' ' + p.LastName AS CustomerName,
	SUM(soh.TotalDue) AS TotalPurchasedAmount
FROM Sales.SalesOrderHeader As soh
JOIN Sales.Customer As c ON soh.CustomerID = c.CustomerID
JOIN Person.Person As p On c.PersonID = p.BusinessEntityID
WHERE soh.OrderDate BETWEEN '2013-07-01' AND  '2014-06-30'
GROUP BY soh.CustomerID, p.FirstName, p.LastName
ORDER BY TotalPurchasedAmount DESC;

-- 2. Find the average discount given per product across all sales orders.
SELECT
	p.Name AS ProductName,
	AVG(sod.UnitPriceDiscount * 100) AS AverageDiscount
FROM Sales.SalesOrderDetail As sod
JOIN Production.Product As p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY AverageDiscount DESC;



-- 3. Identify products that were part of more than three different special offers.
--(Without distinct we are getting the same results but to be on the safe side we must use the distinct keyword to aviod any duplication of values 

SELECT
	p.ProductID,
	p.Name AS ProductName,
	COUNT(DISTINCT so.SpecialOfferID) AS SpecialOfferCount
FROM Sales.SpecialOfferProduct AS sop
JOIN Production.Product AS p ON p.ProductID = sop.ProductID
JOIN Sales.SpecialOffer AS so ON sop.SpecialOfferID = so.SpecialOfferID
GROUP BY p.ProductID,p.Name
HAVING COUNT(DISTINCT so.SpecialOfferID) > 3
ORDER BY SpecialOfferCount DESC;

-- 4. Show the order trend (number of orders per month) for the past two years.
SELECT
	YEAR(OrderDate) AS OrderYear,
	COUNT(SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE OrderDate > DATEADD(YEAR, -2, (SELECT MAX(OrderDate)FROM Sales.SalesOrderHeader))
GROUP BY YEAR(OrderDate);

SELECT
	YEAR(OrderDate) AS OrderYear,
	MONTH(OrderDate) AS OrderMonth,
	COUNT(SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE OrderDate > DATEADD(YEAR, -2, (SELECT MAX(OrderDate)FROM Sales.SalesOrderHeader))
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear;

-- 5. Find customers who placed an order in every quarter of the year 2012.

SELECT CustomerID
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2012
GROUP BY CustomerID
HAVING COUNT(DISTINCT DATEPART (QUARTER, OrderDate)) = 4;

-- 6. Identify the top 5 products that have contributed the most to the total revenue in 2012 (based on the SalesOrderDetail and Product tables).
SELECT TOP 5
	p.ProductID,
	p.Name AS ProductName,
	SUM(sod.LineTotal/1000000) AS TotalRevenueInMillion
FROM Sales.SalesOrderDetail as sod 
JOIN Production.Product As p On sod.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = sod.SalesOrderID
WHERE YEAR(soh.OrderDate) = 2012
GROUP BY p.ProductID, p.Name
ORDER BY TotalRevenueInMillion DESC;

-- 7. For each sales order, calculate the total line discount applied and filter orders where total discount exceeded $500.
SELECT
	soh.SalesOrderID,
	SUM(sod.LineTotal * sod.UnitPriceDiscount) AS TotalLinediscount
FROM Sales.SalesOrderDetail AS sod
JOIN Sales.SalesOrderHeader As soh ON sod.SalesOrderID = soh.SalesOrderID 
GROUP BY soh.SalesOrderID
HAVING SUM(sod.LineTotal * sod.UnitPriceDiscount) > 500
ORDER BY TotalLinediscount DESC;

-- 8.Identify which salespersons generated at least $1,000,000 in sales in any single territory..

SELECT
	so.SalesPersonID,
	so.TerritoryID,
	p.FirstName + ' ' + p.LastName AS SalesPersonName,
	SUM(so.TotalDue/1000000) AS TotalSalesInMillions
FROM Sales.SalesOrderHeader so
JOIN Sales.SalesTerritory st ON so.TerritoryID = st.TerritoryID
JOIN Person.Person p ON p.BusinessEntityID = so.SalesPersonID
GROUP BY so.SalesPersonID, so.TerritoryID, p.FirstName,p.LastName
HAVING SUM(so.TotalDue) >= 1000000
ORDER BY TotalSalesInMillions DESC;


-- 9. Identify the top 5 most popular products based on total sales quantity and total revenue.
SELECT TOP 5
	p.ProductID,
	p.Name AS ProductName,
	SUM(sod.OrderQty) AS TotalQuantitySold,
	SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail as sod 
JOIN Production.Product As p On sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalQuantitySold DESC,TotalRevenue DESC;

-- 10. Detect potential fraudulent activity by finding customers who placed more than 10 high-value orders (> $10,000 each) within a single month.
SELECT
	p.BusinessEntityID AS CustomerID,
	p.FirstName + ' ' + p.LastName AS CustomerName,
	YEAR(soh.OrderDate) AS OrderYear,
	MONTH(soh.OrderDate) AS OrderMonth,
	COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE soh.TotalDue > 100000
GROUP BY p.BusinessEntityID,p.FirstName,p.LastName,YEAR(soh.OrderDate),MONTH(soh.OrderDate)
HAVING COUNT(*) > 9

-- 11. List all stores that haven’t made any purchases.

SELECT
	s.BusinessEntityID,
	s.Name AS Storename
FROM Sales.Store s
LEFT JOIN Sales.Customer c ON s.BusinessEntityID = c.StoreID 
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY s.BusinessEntityID, s.Name
HAVING MAX(soh.OrderDate) IS NULL

-- 12. Analyze which product categories (based on Product table join) perform best in each territory.

WITH CategorySales AS (
SELECT
	st.Name AS Territory,
	pc.Name AS ProductCategory,
	SUM(sod.LineTotal/1000000000) AS TotalSales
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = sod.SalesOrderID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc On psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY st.Name, pc.Name
),

RankedSales AS (
SELECT *,
	RANK() OVER (PARTITION BY Territory ORDER BY TotalSales DESc) AS RankOfTerritory
FROM CategorySales
)

SELECT *
FROM RankedSales
WHERE RankOfTerritory = 1


-- 13. What are the total sales amounts for each product category in each sales territory?
SELECT
	st.Name AS Territory,
	pc.Name AS ProductCategory,
	SUM(sod.LineTotal/1000000000) AS TotalSales
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = sod.SalesOrderID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON psc.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc On psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY st.Name, pc.Name
ORDER BY Territory, TotalSales DESC;

-- 14. List all salespersons who exceeded their SalesQuota in any month of the year 2013.

WITH MonthlySales AS (
SELECT 
	soh.SalesPersonID,
	YEAR(soh.OrderDate) AS SalesYear,
	MONTH(soh.OrderDate) AS SalesMonth,
	SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader AS soh
WHERE 
	soh.SalesPersonID IS NOT NULL AND
	YEAR(soh.OrderDate) = 2013
GROUP BY soh.SalesPersonID,YEAR(soh.OrderDate),MONTH(soh.OrderDate)
),

Quota AS (
SELECT 
	spq.BusinessEntityID AS SalesPersonID,
	YEAR(spq.QuotaDate) AS QuotaYear,
	MONTH(spq.QuotaDate) AS QuotaMonth,
	spq.SalesQuota
FROM Sales.SalesPersonQuotaHistory AS spq
WHERE YEAR(spq.QuotaDate) =2013
)

SELECT
	ms.SalesPersonID,
	ms.SalesMonth,
	ms.SalesYear,
	ms.TotalSales,
	q.SalesQuota,
	(ms.TotalSales - q.SalesQuota) AS Difference
FROM MonthlySales ms
JOIN Quota AS q ON ms.SalesPersonID = q.SalesPersonID
	AND ms.SalesYear = q.QuotaYear
	AND ms.SalesMonth = q.QuotaMonth
ORDER BY ms.SalesPersonID, ms.SalesMonth;


-- 15. For each territory, calculate the percentage change in SalesYTD (Year to date) from the previous year.
WITH TerritorySales AS (
    SELECT 
        th.TerritoryID,
        YEAR(th.StartDate) AS SalesYear,
        sp.SalesYTD
    FROM Sales.SalesTerritoryHistory th
    JOIN Sales.SalesPerson sp ON th.BusinessEntityID = sp.BusinessEntityID
    WHERE sp.SalesYTD IS NOT NULL
),
RankedSales AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY TerritoryID ORDER BY SalesYear) AS rn
    FROM TerritorySales
),
SalesWithLag AS (
    SELECT 
        curr.TerritoryID,
        curr.SalesYear,
        curr.SalesYTD AS CurrentYTD,
        prev.SalesYTD AS PreviousYTD,
        CAST(curr.SalesYTD - prev.SalesYTD AS FLOAT) / NULLIF(prev.SalesYTD, 0) * 100 AS PercentChange
    FROM RankedSales curr
    JOIN RankedSales prev
        ON curr.TerritoryID = prev.TerritoryID
        AND curr.rn = prev.rn + 1
)
SELECT 
    t.Name AS TerritoryName,
    swl.TerritoryID,
    swl.SalesYear,
    swl.CurrentYTD,
    swl.PreviousYTD,
    ROUND(swl.PercentChange, 2) AS PercentChange
FROM SalesWithLag swl
JOIN Sales.SalesTerritory t ON swl.TerritoryID = t.TerritoryID
ORDER BY swl.TerritoryID, swl.SalesYear;
