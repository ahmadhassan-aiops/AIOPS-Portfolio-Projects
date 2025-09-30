Select ReviewID,CustomerID,ProductID,ReviewDate,Rating,REPLACE(ReviewText,'  ',' ') AS ReviewText
From dbo.customer_reviews;
