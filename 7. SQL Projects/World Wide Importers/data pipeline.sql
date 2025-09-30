
-- 1. Product Count per Category
CREATE VIEW vw_ProductCountPerCategory AS
SELECT sgr.StockGroupName, COUNT(si.StockItemID) AS ProductCount
FROM Warehouse.StockItems si
JOIN Warehouse.StockItemStockGroups sg ON sg.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sgr ON sgr.StockGroupID = sg.StockGroupID
GROUP BY sgr.StockGroupName;
GO

-- 2. Number of Orders per Customer
CREATE VIEW vw_OrdersPerCustomer AS
SELECT c.CustomerID, c.CustomerName, COUNT(o.OrderID) AS OrderCount
FROM Sales.Customers c
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName;
GO

-- 3. Top 10 Products by Sales in Last Year
CREATE VIEW vw_Top10ProductsBySalesLastYear AS
SELECT TOP 10 
    si.StockItemName AS Product,
    SUM(il.ExtendedPrice) AS TotalSales
FROM Sales.InvoiceLines il
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
WHERE i.InvoiceDate >= DATEADD(YEAR, -1, GETDATE())
GROUP BY si.StockItemName
ORDER BY TotalSales DESC;
GO

-- 4. Total Sales per Product Category > $10,000
CREATE VIEW vw_TotalSalesPerCategory AS
SELECT sg.StockGroupName AS Product_Category, SUM(il.ExtendedPrice) AS TotalSales
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sgr ON sgr.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sg ON sg.StockGroupID = sgr.StockGroupID
GROUP BY sg.StockGroupName
HAVING SUM(il.ExtendedPrice) > 10000;
GO

-- 5. Average Sales per Product Category > $10,000
CREATE VIEW vw_AvgSalesPerCategory AS
SELECT sg.StockGroupName AS Product_Category, AVG(il.ExtendedPrice) AS AvgSales
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Warehouse.StockItemStockGroups sgr ON sgr.StockItemID = si.StockItemID
JOIN Warehouse.StockGroups sg ON sg.StockGroupID = sgr.StockGroupID
GROUP BY sg.StockGroupName
HAVING SUM(il.ExtendedPrice) > 10000;
GO

-- 6. Customers with Orders (INNER JOIN)
CREATE VIEW vw_CustomersWithOrders AS
SELECT c.CustomerID, c.CustomerName, o.OrderID, o.OrderDate
FROM Sales.Customers c
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;
GO

-- 7. All Customers and Their Orders (LEFT JOIN)
CREATE VIEW vw_CustomersWithOrWithoutOrders AS
SELECT c.CustomerID, c.CustomerName, o.OrderID, o.OrderDate
FROM Sales.Customers c
LEFT JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;
GO

-- 8. Stock Items with Same Price (No Duplicates)
CREATE VIEW vw_StockItemsSamePrice AS
SELECT 
    A.StockItemID AS ItemA_ID,
    A.StockItemName AS ItemA_Name,
    B.StockItemID AS ItemB_ID,
    B.StockItemName AS ItemB_Name,
    A.UnitPrice
FROM Warehouse.StockItems A
JOIN Warehouse.StockItems B ON A.UnitPrice = B.UnitPrice AND A.StockItemID < B.StockItemID;
GO

-- 9. Employees and Their Managers
CREATE VIEW vw_EmployeesWithManagers AS
SELECT e1.EmployeeID AS EmployeeID, 
       e1.FirstName + ' ' + e1.LastName AS EmployeeName, 
       e2.FirstName + ' ' + e2.LastName AS ManagerName
FROM Employees e1
LEFT JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID;
GO

-- 10. Products Sold in January and February
CREATE VIEW vw_ProductsSoldJanAndFeb AS
SELECT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices il ON il1.InvoiceID = il.InvoiceID
    WHERE MONTH(il.InvoiceDate) = 1
)
AND si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices il ON il1.InvoiceID = il.InvoiceID
    WHERE MONTH(il.InvoiceDate) = 2
);
GO

-- 11. Products Sold in January but Not in July
CREATE VIEW vw_ProductsJanNotJuly AS
SELECT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices il ON il1.InvoiceID = il.InvoiceID
    WHERE MONTH(il.InvoiceDate) = 1
)
AND si.StockItemID NOT IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices il ON il1.InvoiceID = il.InvoiceID
    WHERE MONTH(il.InvoiceDate) = 7
);
GO

-- 12. Products Sold in Jan but Not in July (EXCEPT method)
CREATE VIEW vw_ProductsJanNotJuly_Except AS
SELECT DISTINCT il1.StockItemID
FROM Sales.InvoiceLines il1
JOIN Sales.Invoices i1 ON il1.InvoiceID = i1.InvoiceID
WHERE MONTH(i1.InvoiceDate) = 1
EXCEPT
SELECT DISTINCT il2.StockItemID
FROM Sales.InvoiceLines il2
JOIN Sales.Invoices i2 ON il2.InvoiceID = i2.InvoiceID
WHERE MONTH(i2.InvoiceDate) = 7;
GO

-- 13. Unique Products Sold in Jan or July
CREATE VIEW vw_UniqueProductsJanOrJuly AS
SELECT DISTINCT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices i1 ON il1.InvoiceID = i1.InvoiceID
    WHERE MONTH(i1.InvoiceDate) = 1
    UNION
    SELECT il2.StockItemID
    FROM Sales.InvoiceLines il2
    JOIN Sales.Invoices i2 ON il2.InvoiceID = i2.InvoiceID
    WHERE MONTH(i2.InvoiceDate) = 7
);
GO

-- 14. Products Sold in Both Jan and July (INTERSECT)
CREATE VIEW vw_ProductsJanAndJuly AS
SELECT DISTINCT si.StockItemID, si.StockItemName
FROM Warehouse.StockItems si
WHERE si.StockItemID IN (
    SELECT il1.StockItemID
    FROM Sales.InvoiceLines il1
    JOIN Sales.Invoices i1 ON il1.InvoiceID = i1.InvoiceID
    WHERE MONTH(i1.InvoiceDate) = 1
    INTERSECT
    SELECT il2.StockItemID
    FROM Sales.InvoiceLines il2
    JOIN Sales.Invoices i2 ON il2.InvoiceID = i2.InvoiceID
    WHERE MONTH(i2.InvoiceDate) = 7
);
GO

-- 15. Product Sales Category Based on Quantity
CREATE VIEW vw_SalesCategoryByQuantity AS
SELECT 
    si.StockItemID,
    si.StockItemName,
    SUM(il.Quantity) AS TotalQuantitySold,
    CASE 
        WHEN SUM(il.Quantity) > 100000 THEN 'High'
        WHEN SUM(il.Quantity) BETWEEN 50000 AND 100000 THEN 'Medium'
        ELSE 'Low'
    END AS SalesCategory
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
GROUP BY si.StockItemID, si.StockItemName;
GO

-- 16. Discount Pricing Based on Quantity Sold
CREATE VIEW vw_DiscountedPricingModel AS
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
GROUP BY si.StockItemID, si.StockItemName;
GO
