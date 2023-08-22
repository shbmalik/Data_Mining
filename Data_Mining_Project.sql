SELECT * FROM data_mining_project.onlineretail_final_1;
use data_mining_project;


#•	What is the distribution of order values across all customers in the dataset?
SELECT CustomerID,
       COUNT(DISTINCT InvoiceNo) AS TotalOrders,
       SUM(Quantity * UnitPrice) AS TotalOrderValue
FROM onlineretail_final_1
GROUP BY CustomerID
ORDER BY TotalOrderValue DESC;



#•	How many unique products has each customer purchased?
SELECT CustomerID, COUNT(DISTINCT Description) AS UniqueProductsPurchased
FROM onlineretail_final_1
GROUP BY CustomerID;


#•	Which customers have only made a single purchase from the company?
SELECT CustomerID
FROM onlineretail_final_1
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) = 1;


#•	Which products are most commonly purchased together by customers in the dataset?
SELECT a.StockCode AS Product1, b.StockCode AS Product2, COUNT(*) AS Frequency
FROM onlineretail_final_1 AS a
JOIN onlineretail_final_1 AS b ON a.CustomerID = b.CustomerID AND a.InvoiceNo = b.InvoiceNo AND a.StockCode < b.StockCode
GROUP BY a.StockCode, b.StockCode
ORDER BY Frequency DESC
LIMIT 10;





      # Advance Queries 
#1.	Customer Segmentation by Purchase Frequency
      #Group customers into segments based on their purchase frequency, such as high, medium, and low-frequency customers. This can help you identify your most loyal customers and those who need more attention.
      #-- Calculate purchase frequency for each customer
SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
FROM onlineretail_final_1
GROUP BY CustomerID
ORDER BY CustomerID;

-- Categorize customers into segments
SELECT CustomerID,
       CASE
           WHEN PurchaseFrequency > 100 THEN 'High Frequency'
           WHEN PurchaseFrequency > 50 THEN 'Medium Frequency'
           ELSE 'Low Frequency'
       END AS CustomerSegment
FROM (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS PurchaseFrequency
    FROM onlineretail_final_1
    GROUP BY CustomerID
) AS PurchaseFrequencyTable
ORDER BY CustomerID;


#2. Average Order Value by Country
			#Calculate the average order value for each country to identify where your most valuable customers are located.

SELECT Country, 
       AVG(Quantity * UnitPrice) AS AvgOrderValue
FROM onlineretail_final_1
GROUP BY Country
ORDER BY AvgOrderValue DESC;


#3. Customer Churn Analysis
			#Identify customers who haven't made a purchase in a specific period (e.g., last 6 months) to assess churn.
SELECT CustomerID,
       MAX(InvoiceDate) AS LastPurchaseDate
FROM onlineretail_final_1
GROUP BY CustomerID
HAVING LastPurchaseDate <= DATE_SUB(NOW(), INTERVAL 6 MONTH);



#4. Product Affinity Analysis
			#Determine which products are often purchased together by calculating the correlation between product purchases.

			# 1st step:- Create a table that represents the co-occurrence of products in the same invoices.
CREATE TABLE ProductCoOccurrence AS
SELECT A.StockCode AS Product1,
       B.StockCode AS Product2,
       COUNT(DISTINCT A.InvoiceNo) AS CoOccurrenceCount
FROM onlineretail_final_1 A
JOIN onlineretail_final_1 B ON A.InvoiceNo = B.InvoiceNo AND A.StockCode < B.StockCode
GROUP BY Product1, Product2;


			#2nd Step:- Calculate the correlation between products based on the co-occurrence count.

SELECT Product1,
       Product2,
       CoOccurrenceCount / SQRT((TotalCountProduct1 * TotalCountProduct2)) AS Correlation
FROM ProductCoOccurrence
JOIN (
    SELECT StockCode,
           COUNT(DISTINCT InvoiceNo) AS TotalCountProduct1
    FROM onlineretail_final_1
    GROUP BY StockCode
) AS Counts1 ON Product1 = Counts1.StockCode
JOIN (
    SELECT StockCode,
           COUNT(DISTINCT InvoiceNo) AS TotalCountProduct2
    FROM onlineretail_final_1
    GROUP BY StockCode
) AS Counts2 ON Product2 = Counts2.StockCode
ORDER BY Correlation DESC;




#5. Time-based Analysis
		#Explore trends in customer behavior over time, such as monthly or quarterly sales patterns.
		#For Monthly Sales Patterns:
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
       SUM(Quantity) AS TotalQuantity,
       SUM(UnitPrice * Quantity) AS TotalRevenue
FROM onlineretail_final_1
GROUP BY Month
ORDER BY Month;


	    #For Quarterly Sales Patterns:
SELECT CONCAT(YEAR(InvoiceDate), ' Q', QUARTER(InvoiceDate)) AS Quarter,
       SUM(Quantity) AS TotalQuantity,
       SUM(UnitPrice * Quantity) AS TotalRevenue
FROM onlineretail_final_1
GROUP BY Quarter
ORDER BY Quarter;
