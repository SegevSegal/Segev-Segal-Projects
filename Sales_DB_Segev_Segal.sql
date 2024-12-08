





--------------------Create Database----------------------------------------------------------------------------------------------------
CREATE DATABASE SALES
USE SALES


-----------------------Data Type Definition---------------------------------------------------------

CREATE TYPE AccountNumber
FROM VARCHAR(255)

CREATE TYPE OrderNumber
FROM VARCHAR(255)

CREATE TYPE name
FROM VARCHAR(50)


CREATE TYPE Flag
FROM BIT



-----------------------Table Definition---------------------------------------------------------

CREATE TABLE CurrencyRate
(CurrencyRateID INT,CurrencyRateDate DATETIME NOT NULL,FromCurrencyCode nchar(3) NOT NULL,
ToCurrencyCode nchar(3) NOT NULL,AvargeRate money NOT NULL,EndOfDayRate money NOT NULL,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_CurrencyRateID PRIMARY KEY(CurrencyRateID))


CREATE TABLE ShipMathod
(ShipMathodID INT,Name name NOT NULL,ShipBase money NOT NULL,
ShipRate money NOT NULL,rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_ShipMathodID PRIMARY KEY(ShipMathodID))










CREATE TABLE Address
(AddressID INT,AddressLine1 nvarchar(60) NOT NULL,AddressLine2 nvarchar(60),
City nvarchar(30) NOT NULL,StateProvincelID INT NOT NULL,PostalCode nvarchar(15) NOT NULL,
rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_AddressID PRIMARY KEY(AddressID))





CREATE TABLE CreditCard
(CreditCardID INT,CardType nvarchar(50) NOT NULL,CardNumber nvarchar(25) NOT NULL,
ExpMonth tinyint NOT NULL,ExpYear smallint NOT NULL,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_CreditCardID PRIMARY KEY(CreditCardID))






CREATE TABLE Territory
(TerritoryId INT,Name name NOT NULL,CountyRegionCode NVARCHAR(3) NOT NULL,
[Group] NVARCHAR(50) NOT NULL,SalesYTD MONEY NOT NULL,CostYTD MONEY NOT NULL,CostLastYear MONEY NOT NULL,
rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_TerritoryId PRIMARY KEY(TerritoryId))


CREATE TABLE SalesPerson
(BusinessEntityid INT,TerritoryId INT,SalesQuota money,Bonus money NOT NULL,
 CommissionPct smallmoney NOT NULL,SalesYTD money NOT NULL,SalesLastYear money NOT NULL,
 rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_BusinessEntityid PRIMARY KEY(BusinessEntityid),
CONSTRAINT FK_TerritoryId_SalesPerson_TerritoryId FOREIGN KEY(TerritoryId)
REFERENCES Territory(TerritoryId))



CREATE TABLE Customer
(CustomerId INT,PersonId INT,StoreId INT,TerritoryId INT,
AccountNumber VARCHAR(255) NOT NULL,rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_CustomerId PRIMARY KEY(CustomerId),CONSTRAINT FK_TerritoryId_Customer_TerritoryId FOREIGN KEY(TerritoryId)
REFERENCES Territory(TerritoryId))




CREATE TABLE SpecialOfferProduct
(SpecialOfferProductID INT,ProductID INT,rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_SpecialOfferProductID_PK_ProductID PRIMARY KEY(SpecialOfferProductID,ProductID))










CREATE TABLE SalesOrderHeader
(SalesOrderID INT,RevisionNumber tinyint NOT NULL,OrderDate DATETIME NOT NULL,DueDate DATETIME NOT NULL,ShipDate DATETIME,
Status tinyint NOT NULL,OnlineOrderFlag Flag NOT NULL,SalesOrderNumber VARCHAR(255) NOT NULL,PurchaseOrderNumber OrderNumber,
AccountNumber AccountNumber,CustomerID INT NOT NULL,SalesPersonID INT,TerritoryID INT,BillToAddressID INT NOT NULL,
ShipToAddressID INT NOT NULL,ShipMathodID INT NOT NULL,CreditCardID INT,CrdeitCardApprovelCode VARCHAR(15),CurrencyRateID INT,
SubTotal money NOT NULL,TaxAMT money NOT NULL,Freight money NOT NULL,
CONSTRAINT PK_SalesOrderID_PK PRIMARY KEY(SalesOrderID),
CONSTRAINT FK_CustomerID_Customer FOREIGN KEY(CustomerID)
REFERENCES Customer(CustomerID),
CONSTRAINT FK_TerritoryID_Territory FOREIGN KEY(TerritoryID)
REFERENCES Territory(TerritoryID),
CONSTRAINT FK_CreditCardID_CreditCard FOREIGN KEY(CreditCardID)
REFERENCES CreditCard(CreditCardID),
CONSTRAINT FK_CurrencyRateID_CurrencyRate FOREIGN KEY(CurrencyRateID)
REFERENCES CurrencyRate(CurrencyRateID),
CONSTRAINT FK_SalesPersonID_SalesPerson FOREIGN KEY(SalesPersonID)
REFERENCES SalesPerson(BusinessEntityid),
CONSTRAINT FK_ShipMathodID_ShipMathod FOREIGN KEY(ShipMathodID)
REFERENCES ShipMathod(ShipMathodID),
CONSTRAINT FK_BillToAddressID_Address FOREIGN KEY(BillToAddressID)
REFERENCES Address(AddressID))



CREATE TABLE SalesOrderDetail
(SalesOrderID INT,SalesOrderDetailID INT,CarrierTrackingNumber nvarchar(25),OrderQty smallint NOT NULL,
ProductID INT NOT NULL,SpecialOfferProductID INT NOT NULL,UnitPrice money NOT NULL,UnitPriceDiscount money NOT NULL,
LineTotal INT NOT NULL,rowguid uniqueidentifier,ModifiedDate DATETIME NOT NULL,
CONSTRAINT PK_SalesOrderID_PK_SalesOrderDetailID PRIMARY KEY(SalesOrderID,SalesOrderDetailID),
CONSTRAINT FK_ProductID_SalesOrderDetailID_SpecialOfferProduct_ProductID_SalesOrderDetailID FOREIGN KEY(SpecialOfferProductID,ProductID)
REFERENCES SpecialOfferProduct(SpecialOfferProductID,ProductID),
CONSTRAINT FK_FOREIGN_SalesOrderID FOREIGN KEY(SalesOrderID)
REFERENCES SalesOrderHeader(SalesOrderID))




-----------------------Data Insert---------------------------------------------------------


INSERT INTO SpecialOfferProduct VALUES
(1234,2345,newid(),'2020/01/01')
INSERT INTO SpecialOfferProduct VALUES
(2345,5678,newid(),'2021/01/01')
INSERT INTO SpecialOfferProduct VALUES
(5678,1234,newid(),'2024/01/01')





INSERT INTO CurrencyRate VALUES
(1234,2020/01/01,123,321,400,600,'2021/01/01')
INSERT INTO CurrencyRate VALUES
(2345,2020/01/02,234,432,500,700,'2024/01/01')
INSERT INTO CurrencyRate VALUES
(5678,2021/01/02,345,543,600,900,'2024/01/09')




INSERT INTO ShipMathod VALUES
(1234,'FEDEXPRESS',400,200,newid(),'2020/01/01')
INSERT INTO ShipMathod VALUES
(2345,'ONLINE',600,400,newid(),'2021/01/01')
INSERT INTO ShipMathod VALUES
(5678,'ONLINE',600,200,newid(),'2024/01/01')




INSERT INTO Address VALUES
(1234,'HACHEZ 1','DERECH HABNIM','PARDES-HANA KARKUR',39,'3678',newid(),'2020/01/01')
INSERT INTO Address VALUES
(2345,'HHAKALIA 2','HAMEYASDIM','BINYAMINA',29,'6769',newid(),'2021/01/01')
INSERT INTO Address VALUES
(5678,'KENET 3','HABONIM','HADERA',69,'6869',newid(),'2024/01/01')




INSERT INTO CreditCard VALUES
(1234,'VISA','83478-734-7878',04,2039,'2020/01/01')
INSERT INTO CreditCard VALUES
(2345,'MASTERCARD','78656-890-7979',05,2029,'2021/01/01')
INSERT INTO CreditCard VALUES
(5678,'MASTERCARD','98767-980-9999',06,2039,'2024/01/01')




INSERT INTO Territory VALUES
(10,'KARKUR',367,'TRI-REGION',8000,5000,6000,newid(),'1999/01/01')
INSERT INTO Territory VALUES
(20,'PARDES-HANA',376,'TRI-REGION',9000,6000,7000,newid(),'2000/01/01')
INSERT INTO Territory VALUES
(30,'EINIRON',369,'TRI-REGION',4000,8000,9000,newid(),'2021/01/01')



INSERT INTO SalesPerson VALUES
(1234,10,800,20,60,1000,2000,newid(),'1999/01/01')
INSERT INTO SalesPerson VALUES
(2345,20,900,30,70,2000,4000,newid(),'2000/01/01')
INSERT INTO SalesPerson VALUES
(5678,30,600,60,79,4000,9000,newid(),'2021/01/01')


INSERT INTO Customer VALUES
(1234,201034600,34,10,'DADA',newid(),'1999/01/01')
INSERT INTO Customer VALUES
(2345,200143900,39,20,'BABA',newid(),'2000/01/01')
INSERT INTO Customer VALUES
(5678,900800600,29,30,'VAVA',newid(),'2021/01/01')

INSERT INTO SalesOrderHeader VALUES
(5678,39,'2020/01/01','2021/01/01','2020/09/01',39,0,'3900B','1000D','2000',1234,1234,10,1234,1234,1234,1234,'3579B',1234,800,1.17,200)

INSERT INTO SalesOrderHeader VALUES
(1234,29,'2021/01/01','2021/02/01','2021/04/01',29,1,'2900B','3000D','3000',2345,2345,20,2345,2345,2345,2345,'3679B',2345,600,1.17,400)

INSERT INTO SalesOrderHeader VALUES
(2345,79,'2021/01/09','2021/09/01','2021/06/01',29,1,'7900B','7000D','7000',5678,5678,30,5678,5678,5678,5678,'3979B',5678,900,1.17,800)



INSERT INTO SalesOrderDetail VALUES
(5678,0765,'20B',10,2345,1234,39,9,30,newid(),'2020/01/01')

INSERT INTO SalesOrderDetail VALUES
(1234,0776,'30B',20,5678,2345,29,19,39,newid(),'2021/01/01')

INSERT INTO SalesOrderDetail VALUES
(2345,0796,'90B',30,1234,5678,79,29,79,newid(),'2024/01/01')







