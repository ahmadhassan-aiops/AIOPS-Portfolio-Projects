Select ProductID,ProductName,Price,Category,
	CASE 
		WHEN Price < 50 Then 'Low'
		WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
		ELSE 'High'
	END AS PriceCategory
From dbo.products
Order by Price Desc;


