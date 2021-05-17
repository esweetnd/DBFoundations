--*************************************************************************--
-- Title: Assignment06
-- Author: ErinSweet
-- Desc: This file demonstrates how to use Views
--2021/05/14 ErinSweet
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_ErinSweet')
	 Begin 
	  Alter Database [Assignment06DB_ErinSweet] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_ErinSweet;
	 End
	Create Database Assignment06DB_ErinSweet;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_ErinSweet;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--Create -- Drop 
--View Customers With SchemaBinding
--AS 
 --Select CustomerID, CustomerName From dbo.tblCustomers;
--go

--QUESTION 1 TABLES***************************************************
GO
CREATE 
VIEW vCategories 
WITH SchemaBinding
AS
SELECT CategoryID, CategoryName 
FROM dbo.Categories;
GO

SELECT * FROM vCategories;
GO

--**********************************************************
GO
CREATE 
VIEW vProducts
WITH SchemaBinding
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;
GO

SELECT * FROM vProducts;
GO

--************************************************
GO
CREATE 
VIEW vEmployees
WITH SchemaBinding
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;
GO

SELECT * FROM vEmployees;
GO

--******************************************************
GO
CREATE 
VIEW vInventories
WITH SchemaBinding
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, (Count)
FROM dbo.Inventories;
GO

SELECT * FROM vInventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO PUBLIC;
GRANT SELECT ON vCategories TO PUBLIC;

DENY SELECT ON dbo.Products TO PUBLIC;
GRANT SELECT ON vProducts TO PUBLIC;

DENY SELECT ON dbo.Employees TO PUBLIC;
GRANT SELECT ON vEmployees TO PUBLIC;

DENY SELECT ON dbo.Inventories TO PUBLIC;
GRANT SELECT ON vInventories TO PUBLIC;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

GO
CREATE VIEW vCategoryNameProductNameUnitPrice
AS 
SELECT CategoryName, ProductName, UnitPrice
FROM dbo.Categories
JOIN dbo.Products
ON Categories.CategoryID = Products.CategoryID;
GO

SELECT * FROM vCategoryNameProductNameUnitPrice ORDER BY CategoryName, ProductName ASC;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

GO
CREATE VIEW vProductNameCountInventoryDate
AS 
SELECT ProductName, (Count), InventoryDate
FROM dbo.Products
JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID;
GO

SELECT * FROM vProductNameCountInventoryDate ORDER BY ProductName, InventoryDate, (Count) ASC;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

GO
CREATE VIEW vInventoryDateEmployeeFirstNameEmployeeLastName
AS
SELECT DISTINCT InventoryDate, Employees.EmployeeFirstName+ ' ' + EmployeeLastName AS EmployeeName
FROM dbo.Employees
JOIN dbo.Inventories
ON Employees.EmployeeID = Inventories.EmployeeID;
GO

SELECT * FROM vInventoryDateEmployeeFirstNameEmployeeLastName ORDER BY InventoryDate;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

GO
CREATE VIEW vCategoriesProductsInventoryDateCount
AS
SELECT CategoryName, ProductName, InventoryDate, (Count)
FROM dbo.Categories
JOIN dbo.Products
ON Categories.CategoryID =Products.CategoryID
JOIN.Inventories
ON Products.ProductID = Inventories.ProductID;
GO

SELECT * FROM vCategoriesProductsInventoryDateCount ORDER BY CategoryName, ProductName, InventoryDate, (Count);
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

CREATE VIEW vCategoriesProductsDateCountEmployee
AS
SELECT CategoryName, ProductName, InventoryDate, (Count), Employees.EmployeeFirstName+ ' ' + EmployeeLastName AS EmployeeName
FROM dbo.Categories
JOIN dbo.Products
ON Categories.CategoryID =Products.CategoryID
JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees
ON Employees.EmployeeID = Inventories.EmployeeID;	
GO

SELECT * FROM vCategoriesProductsDateCountEmployee ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

GO
CREATE VIEW vCategoriesProductsDateCountEmployeeChaiChang
AS
SELECT CategoryName, ProductName, InventoryDate, (Count), Employees.EmployeeFirstName+ ' ' + EmployeeLastName AS EmployeeName
FROM dbo.Categories
JOIN dbo.Products
ON Categories.CategoryID =Products.CategoryID
JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees
ON Employees.EmployeeID = Inventories.EmployeeID
WHERE Inventories.ProductID IN(SELECT ProductID FROM PRODUCTS WHERE ProductName IN ('Chai', 'Chang'));
GO

SELECT * FROM vCategoriesProductsDateCountEmployeeChaiChang ORDER BY InventoryDate, CategoryName, ProductName;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

GO
CREATE VIEW vEmployeeManager
AS
SELECT
M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager,
E.EmployeeFirstName + ' ' + E.EmployeeFirstName AS Employee
FROM Employees AS E
JOIN Employees AS M
ON E.ManagerID = M.EmployeeID
GO

SELECT * FROM vEmployeeManager ORDER BY 1,2;  
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

GO
CREATE VIEW vAll
AS
SELECT Categories.CategoryID, CategoryName, Products.ProductID, ProductName, UnitPrice, Employees.EmployeeID, Employees.EmployeeFirstName+ ' ' + EmployeeLastName AS EmployeeName, ManagerID, InventoryID, InventoryDate, (Count)
FROM dbo.Categories
JOIN dbo.Products
ON Categories.CategoryID = Products.ProductID
JOIN dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN dbo.Employees
ON Inventories.EmployeeID = Employees.EmployeeID;
GO

SELECT * FROM vAll;
GO

-- Test your Views (NOTE: You must change the names to match yours as needed!)
SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vEmployees;
SELECT * FROM vInventories;

SELECT * FROM vCategoryNameProductNameUnitPrice ORDER BY CategoryName, ProductName ASC;
SELECT * FROM vProductNameCountInventoryDate ORDER BY ProductName, InventoryDate, (Count) ASC;
SELECT * FROM vInventoryDateEmployeeFirstNameEmployeeLastName ORDER BY InventoryDate;
SELECT * FROM vCategoriesProductsInventoryDateCount ORDER BY CategoryName, ProductName, InventoryDate, (Count);
SELECT * FROM vCategoriesProductsDateCountEmployee ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
SELECT * FROM vCategoriesProductsDateCountEmployeeChaiChang ORDER BY InventoryDate, CategoryName, ProductName;
SELECT * FROM vEmployeeManager ORDER BY 1,2;   
SELECT * FROM vAll;
/***************************************************************************************/