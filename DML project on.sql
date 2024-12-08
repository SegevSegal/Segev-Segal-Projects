------------------------------------------------------------------------------------------
---------------------------------------1
--Write a query to display information on products not purchased in the orders table.
--Display columns: ProductID, ProductName, Color, ListPrice, and Size, sorted by ProductID.
------------------------------------------------------------------------------------------

SELECT S1.ProductID,Name,Color,ListPrice,Size
FROM Production.Product AS S1 
JOIN
	(SELECT ProductID
	FROM Production.Product
	EXCEPT
	SELECT ProductID
	FROM SALES.SalesOrderDetail) AS S2
ON S1.ProductID=S2.ProductID
ORDER BY ProductID





------------------------------------------------------------------------------------------
---------------------------------------2
--Write a query to display customers who have not placed any orders.
--Display: CustomerID, LastName. If the customer lacks a first or last name, display "Unknown". Sort by CustomerID.
------------------------------------------------------------------------------------------

SELECT CustomerID,
	ISNULL(LastName, 'Unknown') AS LastName,
	ISNULL(FirstName, 'Unknown') AS FirstName  
FROM Person.Person AS P 
RIGHT JOIN Sales.Customer AS S
ON P.BusinessEntityID=S.CustomerID
WHERE S.CustomerID IN
	(SELECT CustomerID
	FROM Sales.Customer
	EXCEPT
	SELECT CustomerID
	FROM Sales.SalesOrderHeader)
ORDER BY S.CustomerID




------------------------------------------------------------------------------------------
---------------------------------------3
--Write a query to display the top 10 customers with the most orders.
--Display: CustomerID, FirstName, LastName, and the total number of orders, sorted by the total in descending order.
------------------------------------------------------------------------------------------

SELECT TOP 10 
	SH.CustomerID,
	P.FirstName, P.LastName,
	COUNT(*) Orders
FROM SALES.SalesOrderHeader AS SH 
JOIN Sales.Customer AS C
ON SH.CustomerID=C.CustomerID
JOIN Person.Person AS P
ON C.PersonID=P.BusinessEntityID
GROUP BY SH.CustomerID,P.FirstName,P.LastName
ORDER BY COUNT(*) DESC




------------------------------------------------------------------------------------------
---------------------------------------4
--Write a query to display information on employees, their job titles, hire dates,
--and the total number of employees holding the same title.
------------------------------------------------------------------------------------------

SELECT 
	P.FirstName, P.LastName,
	E.JobTitle, E.HireDate,
	COUNT(*) OVER(PARTITION BY E.JobTitle) AS CountOfTitle
FROM HumanResources.Employee AS E 
JOIN Person.Person AS P
ON E.BusinessEntityID=P.BusinessEntityID
order by E.JobTitle



------------------------------------------------------------------------------------------
---------------------------------------5
--Write a query to display the last and second-last order date for each customer.
--Include: SalesOrderID, CustomerID, FirstName, LastName, Last Order Date, and Second-Last Order Date.
------------------------------------------------------------------------------------------

WITH cte1 AS
	(SELECT * 
	FROM (
		SELECT SalesOrderID,CustomerID,OrderDate,
			ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY ORDERDATE DESC ) AS OrderPos
		FROM SALES.SalesOrderHeader
	) AS LastOrder_tlb
	WHERE OrderPos=1
) ,cte2 AS
	(SELECT * 
	FROM (
		SELECT CustomerID,OrderDate,
			ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY ORDERDATE DESC ) AS OrderPos
		FROM SALES.SalesOrderHeader
	) AS PrevOrder_tlb
	WHERE OrderPos=2
)

SELECT cte1.SalesOrderID,cte1.CustomerID,
	P.LastName, P.FirstName, 
	cte1.OrderDate AS 'LastOrder',
	cte2.OrderDate as 'PreviousOrder'
FROM cte1 LEFT JOIN cte2
ON cte1.CustomerID=cte2.CustomerID
JOIN Sales.Customer AS S
ON cte1.CustomerID=S.CustomerID
JOIN Person.Person AS P
ON S.PersonID=P.BusinessEntityID




------------------------------------------------------------------------------------------
---------------------------------------6
--Write a query to display the total cost of the most expensive orders per year, including the customer details. 
--Calculation: UnitPrice * OrderQty. Format the total as shown in the example diagram.
------------------------------------------------------------------------------------------

WITH cte1 AS
(
	SELECT SH.OrderDate, SH.SalesOrderID,
		SUM(UnitPrice*OrderQty) AS TOTAL,
		P1.FirstName,P1.LastName
	FROM SALES.SalesOrderDetail AS SO 
	JOIN SALES.SalesOrderHeader AS SH
	ON SO.SalesOrderID=SH.SalesOrderID
	JOIN SALES.Customer AS SC
	ON SH.CustomerID=SC.CustomerID
	JOIN Person.Person AS P1
	ON SC.PersonID=P1.BusinessEntityID 
	GROUP BY SH.OrderDate,SH.SalesOrderID,P1.FirstName,P1.LastName
)
,cte2 AS
(
	SELECT Total,
	ROW_NUMBER() OVER (PARTITION BY year(cte1.OrderDate) order by cte1.Total desc)  AS rn
	FROM cte1
)
SELECT YEAR(cte1.OrderDate) AS Year,cte1.SalesOrderID,cte1.LastName,cte1.FirstName,cte2.Total
FROM cte2 JOIN cte1
ON cte1.TOTAL=cte2.TOTAL
WHERE rn = 1



------------------------------------------------------------------------------------------
---------------------------------------7
--Display a matrix showing the number of orders made in each month of the year.
------------------------------------------------------------------------------------------

select Month,[2011],[2012],[2013],[2014] FROM
(SELECT SalesOrderID,YEAR(OrderDate) as Year , MONTH(OrderDate) as Month FROM Sales.SalesOrderHeader ) o
PIVOT(COUNT(SalesOrderID) FOR Year in([2011],[2012],[2013],[2014])) o2
ORDER BY Month



------------------------------------------------------------------------------------------
---------------------------------------8
--Write a query to display the total products ordered per month and the cumulative total for the year.
--Ensure the report is well-formatted with a summary row for the year.
------------------------------------------------------------------------------------------


WITH cte1 AS
(
	SELECT YEAR(SH.OrderDate) AS 'YEAR',MONTH(SH.OrderDate) AS 'MONTH',
	SUM(S1.UnitPrice) OVER(PARTITION BY YEAR(SH.OrderDate) ORDER BY YEAR(SH.OrderDate)
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TOTAL
	FROM SALES.SalesOrderDetail AS S1 JOIN Sales.SalesOrderHeader AS SH
	ON S1.SalesOrderID=SH.SalesOrderID
)
,cte2 AS
(
	SELECT YEAR(SH.OrderDate) AS 'YEAR',MONTH(SH.OrderDate) AS 'MONTH',SUM(S1.UnitPrice) AS 'TOTAL'
	FROM SALES.SalesOrderDetail AS S1 JOIN Sales.SalesOrderHeader AS SH
	ON S1.SalesOrderID=SH.SalesOrderID
	GROUP BY GROUPING SETS ((YEAR(SH.OrderDate),MONTH(SH.OrderDate)),YEAR(SH.OrderDate))
)
SELECT cte2.YEAR AS Year,ISNULL(CAST(cte2.Month AS VARCHAR),'Grand Total') AS Month,
	cte2.TOTAL AS Sum_Price, MAX(cte1.TOTAL) AS CumSum
FROM cte1 RIGHT JOIN cte2
ON cte1.YEAR=cte2.YEAR AND cte1.MONTH=cte2.MONTH
GROUP BY cte1.YEAR,cte1.MONTH,cte2.YEAR,cte2.MONTH,cte2.TOTAL
ORDER BY cte2.YEAR,cte2.MONTH





------------------------------------------------------------------------------------------
---------------------------------------9
--Write a query to display employees sorted by their hire dates within departments, from the most recent to the earliest.
--Include columns for department name, employee full name, hire date, tenure, and time elapsed between hires.
------------------------------------------------------------------------------------------

WITH cte AS
(
	SELECT D.DepartmentID,D.Name,P.FirstName,P.LastName,E.HireDate,
		LAG(E.HireDate,1) OVER (PARTITION BY D.DepartmentID ORDER BY E.HireDate) 'Prev_HireDate',
		LAG(P.FirstName+' '+P.LastName,1) OVER (PARTITION BY D.DepartmentID ORDER BY E.HireDate) 'Prev_EmpName'
	FROM HumanResources.Employee AS E JOIN HumanResources.EmployeeDepartmentHistory AS EH
	ON E.BusinessEntityID= EH.BusinessEntityID
	JOIN HumanResources.Department AS D
	ON EH.DepartmentID=D.DepartmentID
	JOIN Person.Person AS P
	ON E.BusinessEntityID=P.BusinessEntityID
)

SELECT cte.Name,cte.FirstName,cte.LastName,cte.HireDate,
	DATEDIFF(MONTH,cte.HireDate,GETDATE()) AS Seniority,
	cte.[Prev_HireDate],
	cte.[Prev_EmpName],DATEDIFF(DAY,CTE.[Prev_HireDate],cte.HireDate) AS DaysDiff
FROM cte
ORDER BY cte.Name,cte.HireDate desc


























