--DDL
use supply_chain;

create table customer (
    cust_id int identity(1,1) primary key,  -- auto-incremented primary key
    customer_name varchar(100) not null check (customer_name not like '%[^a-za-z ]%'),
    aadhar_card char(12) unique not null check (aadhar_card like '[0-9]{12}'),  
    mobile_number char(10) unique not null check (mobile_number like '[6-9][0-9]{9}'), 
    date_of_birth date not null check (datediff(year, date_of_birth, getdate()) > 15), 
    address nvarchar(255) not null,
    address_type_code char(1) not null check (address_type_code in ('b', 'h', 'o')), 
    state_code char(2) not null check (state_code in ('mh', 'ka'))  
);

create table addresstype (
    address_type_code char(1) primary key check (address_type_code in ('b', 'h', 'o')),  
    address_type_desc varchar(50) not null  
);

create table state_info(
    state_id int primary key,
    state_name varchar(100),
    country_code char(2) unique  -- add a unique constraint on `country_code`
);

alter table customer 
add constraint fk_customer_addresstype foreign key (address_type_code) 
references addresstype(address_type_code);

alter table customer 
add constraint fk_customer_state foreign key (state_code) 
references state_info(country_code); 


--Based on adventurework solve the following questions
use AdventureWorks2022
--Q1.find the average currency conversion rate from USD to Algerian Dinar and Australian Dollar
select*from sales.Currency
select*from sales.CurrencyRate
select*from sales.CountryRegionCurrency

select concat_ws('  To  ',FromCurrencyCode,ToCurrencyCode)as Currency_Conversion,
avg(AverageRate) as Average_Currency_Rate
from sales.CurrencyRate 
where FromCurrencyCode='USD'
and ToCurrencyCode in ('DZD','AUD')
group by FromCurrencyCode,ToCurrencyCode

--Q2. Find the products having offer on it and display product name, safety stock level,listprice,
--and product model id, type of discount, percentage of discount,offer start date and offer end date.
select*from  Production.Product
select*from Sales.SpecialOffer
select*from Sales.SpecialOfferProduct

select
(select p.ProductModelID from Production.Product p where p.ProductID=sop.ProductID)as Product_ModelID,
(select p.Name from Production.Product p where p.ProductID=sop.ProductID)as Product_Name,
(select p.SafetyStockLevel from Production.Product p where p.ProductID=sop.ProductID)as Safety_Stock_Level,
(select p.ListPrice from Production.Product p where p.ProductID=sop.ProductID)as List_Price,
(select sp.DiscountPct from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Percentage_of_discount,
(select sp.Type from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Type_of_discount,
(select concat_ws('  and  ',sp.StartDate,sp.EndDate) from sales.SpecialOffer sp where sp.SpecialOfferID=sop.SpecialOfferID)as Start_and_end_date
from sales.SpecialOfferProduct sop

--Q3. create view to display product name and product review
select*from Production.Product
select*from Production.ProductReview

create view ProductReviews1 as
SELECT p.Name,r.Comments
FROM Production.Product p
JOIN Production.ProductReview r ON p.ProductID = r.ProductID;

SELECT * FROM ProductReviews1;

--Q4. find out the vendor for the product paint,Adjustable Race and blade
select*from Production.Product
select*from Purchasing.Vendor
select*from Purchasing.ProductVendor

select distinct v.Name,p.Name
from Production.Product p,
	 Purchasing.ProductVendor pv,
	 Purchasing.Vendor v
where p.ProductID=pv.ProductID and 
	  pv.BusinessEntityID=v.BusinessEntityID and
	  p.Name like '%paint%' or 
	  p.Name like '%Blade%' or 
	  p.Name ='Adjustable Race'
group by v.Name,p.Name,pv.BusinessEntityID

--Q5. find product details shipped through ZY-EXPRESS
select* from Purchasing.ShipMethod
select*from Production.Product
select* from Purchasing.PurchaseOrderDetail
select*from Purchasing.PurchaseOrderHeader

select
(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
(select p.ProductNumber from Production.Product p where p.ProductID=pd.ProductID)as ProductNumber,
(select sm.ShipMethodID from Purchasing.ShipMethod sm where sm.ShipMethodID=ph.ShipMethodID)as ShipID,
(select sm.Name from Purchasing.ShipMethod sm where sm.ShipMethodID=ph.ShipMethodID)as ShipName
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
    on pd.PurchaseOrderID = ph.PurchaseOrderID
where ph.ShipMethodID = (
    select s.ShipMethodID 
    from Purchasing.ShipMethod s 
    where s.Name LIKE 'ZY - EXPRESS'
)

--Q6. find the tax amount for products where order date and ship date are on the same day
select * from Production.Product
select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.PurchaseOrderDetail

select 
(select p.Name from Production.Product p where p.ProductID=pd.ProductID)as ProductName,
ph.TaxAmt as Tax_Amount
from Purchasing.PurchaseOrderDetail pd
join Purchasing.PurchaseOrderHeader ph 
on pd.PurchaseOrderID = ph.PurchaseOrderID
where day(ph.OrderDate)=day(ph.ShipDate)

--Q7. find the average days required to ship the product based on shipment type.
select* from Purchasing.ShipMethod
select* from Production.Product
select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.PurchaseOrderDetail

select 
    ps.Name as Shipment_Type, 
    avg(datediff(day, ph.OrderDate, ph.ShipDate)) as Avg_Shipping_Days
from Purchasing.PurchaseOrderHeader ph
join Purchasing.ShipMethod ps 
    on ph.ShipMethodID = ps.ShipMethodID
where ph.ShipDate is not null
group by ps.Name
order by Avg_Shipping_Days desc;

--Q8. Find the name of employees working in day shift 
select concat_ws(' ',FirstName,LastName)as EmployeeName from Person.Person  where BusinessEntityID IN 
(SELECT BusinessEntityID from HumanResources.EmployeeDepartmentHistory where ShiftID in 
( select ShiftID from HumanResources.Shift where ShiftID=1))

--Q9. based on product and product cost history find the name, service provider time, and average standard cost
select* from Production.Product
select* from Production.ProductCostHistory

select 
p.Name as Product_Name,
datediff_big(day,min(StartDate),max(EndDate)) as service_provider_time,
avg(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name


--Q10. find products with average cost more than 500
select 
p.Name as Product_Name,
avg(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name
having avg(ph.StandardCost)>500

--Q11. find the employees who worked in mulitple territories
select* from Person.Person
select*from HumanResources.Employee
select*from sales.SalesTerritory
select* from Sales.SalesTerritoryHistory

select
e.BusinessEntityID,
count(st.TerritoryID) as Territory_Count,
(select concat_ws(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as Employee_Name
from HumanResources.Employee e
join
sales.SalesTerritoryHistory sth
on
e.BusinessEntityID=sth.BusinessEntityID
join
sales.SalesTerritory st
on
st.TerritoryID=sth.TerritoryID
group by e.BusinessEntityID
having count(st.TerritoryID)>1

--Q12. find out the product model name, product description for culture as Arabic
select* from Production.ProductModel
select* from Production.ProductDescription
select* from Production.Culture
select* from Production.ProductModelProductDescriptionCulture

select pm.Name as Product_Model_Name,
pd.Description as Product_Description
from Production.ProductModel pm
join Production.ProductModelProductDescriptionCulture pdc
on pm.ProductModelID=pdc.ProductModelID
join Production.ProductDescription pd
on pd.ProductDescriptionID=pd.ProductDescriptionID
join Production.Culture pc
on pc.CultureID=pdc.CultureID
where pc.Name like 'Arabic'
group by pm.Name,pd.Description

--13.	 Find first 20 employees who joined very early in the company
select*from HumanResources.Employee
select*from Person.Person

select top 20 CONCAT_WS(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName,
concat_ws('/',DAY(e.HireDate),MONTH(e.HireDate),YEAR(e.HireDate))as JoiningDate
from Person.Person p
join HumanResources.Employee e
on p.BusinessEntityID=e.BusinessEntityID
order by year(e.HireDate) asc

--14. Find most trending product based on sales and purchase.
select*from Production.Product
select*from sales.SalesOrderDetail
select*from Purchasing.PurchaseOrderDetail

select top 1 p.name as productname, 
sum(sod.orderqty) + sum(pod.orderqty) as trendscore
from production.product p
left join sales.salesorderdetail sod on p.productid = sod.productid
left join purchasing.purchaseorderdetail pod on p.productid = pod.productid
group by p.name
order by trendscore desc;

--15.	 display EMP name, territory name, saleslastyear salesquota and bonus
select TerritoryID,
(Select concat(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus 
from sales.SalesPerson sp

--16.	 display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom
select TerritoryID,
(Select concat(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus
from sales.SalesPerson sp
WHERE sp.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE Name IN ('United Kingdom', 'Germany')
)

--17.	 Find all employees who worked in all North America territory
select TerritoryID,
(Select concat(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sth.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sth.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sth.TerritoryID)as GroupName
from sales.SalesTerritoryHistory sth
WHERE sth.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE [Group] IN ('North America')
)

--18.	 find all products in the cart
select
(Select Name from Production.Product pp where pp.ProductID=sc.ProductID)as ProductName,
(Select ProductNumber from Production.Product pp where pp.ProductID=sc.ProductID)as ProductNumber,
Quantity
from Sales.ShoppingCartItem sc

--19.	 find all the products with special offer
select Name from Production.Product pp
where pp.ProductID in (
select ProductID from sales.SpecialOfferProduct sop
where SpecialOfferID in (
select SpecialOfferID from Sales.SpecialOffer where Type='No Discount'
))

--20.	 find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008
select(select concat_ws(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select concat_ws(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)Card_detail
from Sales.PersonCreditCard pc where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc 
where cc.ExpMonth=11 and cc.ExpYear=2008)

--21.	 Find the employee whose payment might be revised  (Hint : Employee payment history)
select 
    (select concat_ws(' ',p.FirstName,p.LastName) from Person.Person p where p.BusinessEntityID = e.BusinessEntityID) as EmployeeName,
    e.BusinessEntityID,
    (select count(RateChangeDate) 
     from HumanResources.EmployeePayHistory eph 
     where eph.BusinessEntityID = e.BusinessEntityID) as PayRevisions
from HumanResources.Employee e
where (select count(RateChangeDate) 
       from HumanResources.EmployeePayHistory eph 
       where eph.BusinessEntityID = e.BusinessEntityID) > 1

--22.	 Find total standard cost for the active Product. (Product cost history)
select * from Production.ProductCostHistory
select * from Production.Product

select 
    pch.ProductID,
    p.Name AS ProductName,
    SUM(pch.StandardCost) OVER (PARTITION BY pch.ProductID) AS TotalStandardCost
from Production.ProductCostHistory pch
join Production.Product p ON pch.ProductID = p.ProductID
where p.DiscontinuedDate IS NULL  
order by TotalStandardCost desc

--23.	Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type)
select* from person.BusinessEntityAddress
select* from Person.Address
select* from Person.AddressType
select* from Person.Person

select
concat_ws(' ',p.FirstName,p.LastName)as Employee_Name,
a.AddressLine1 as _Address_,
at.Name as Address_Type
from person.person p
join Person.BusinessEntityAddress ba
on p.BusinessEntityID=ba.BusinessEntityID
join Person.Address a
on a.AddressID=ba.AddressID
join Person.AddressType at
on at.AddressTypeID=ba.AddressTypeID

--24.	 Find the name of employees working in group of North America territory
select TerritoryID,
(Select concat(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sth.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sth.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sth.TerritoryID)as GroupName
from sales.SalesTerritoryHistory sth
WHERE sth.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE [Group] IN ('North America')
)


--25.	 Find the employee whose payment is revised for more than once                                  
select e.businessentityid, p.firstname, p.lastname, count(eph.ratechangedate) as payrevisions
from humanresources.employeepayhistory eph
join humanresources.employee e 
on eph.businessentityid = e.businessentityid
join person.person p 
on e.businessentityid = p.businessentityid
group by e.businessentityid, p.firstname, p.lastname
having count(eph.ratechangedate) > 1;


--26.	 display the personal details of  employee whose payment is revised for more than once.
select* from Person.Address
select*from Person.Person
select*from person.BusinessEntityAddress

select e.BusinessEntityID,concat_ws(' ',p.FirstName,p.LastName)as Name_of_Employee, 
a.AddressLine1 as Address
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
join Person.BusinessEntityAddress ba
on ba.BusinessEntityID=p.BusinessEntityID
join Person.Address a
on a.AddressID=ba.AddressID
group by e.BusinessEntityID, p.FirstName, p.LastName,a.AddressLine1
having count(eph.RateChangeDate) > 1;


--27.	Which shelf is having maximum quantity (product inventory)
Select * from Production.ProductInventory

select top 1  shelf,
sum(quantity) as totalquantity
from production.productinventory
group by shelf
order by totalquantity desc

--28.	Which shelf is using maximum bin(product inventory)
select * from production.productinventory

--Method 1
select top 1  shelf,
max(bin) max_use_bin
from production.productinventory
group by shelf
order by max_use_bin desc

--Method 2
select top 1  shelf,
count(distinct bin) max_use_bin
from production.productinventory
group by shelf
order by max_use_bin desc

--29.	Which location is having minimum bin (product inventory)
select top 1 locationid,
min(bin) min_use_bin
from production.productinventory
group by locationid
order by min_use_bin desc


--30.	Find out the product available in most of the locations (product inventory)
select * from production.product
select * from production.productinventory

select top 1
p.name as productname,
count(distinct pi.locationid) as totallocations
from production.productinventory pi
join production.product p on p.productid = pi.productid
group by p.name
order by totallocations desc

--31.	Which sales order is having most order qualtity.

select * from sales.salesorderdetail

select top 1
sod.salesorderid,
sum(sod.orderqty) as totalorderquantity
from sales.salesorderdetail sod
group by sod.salesorderid
order by totalorderquantity desc

--32.	 find the duration of payment revision on every interval  (inline view) Output must be as given format
--## revised time  count of revised salries
--## duration  last duration of revision e.g there are two revision date 01-01-2022 and revised in 01-01-2024   so duration here is 2years  
select * from HumanResources.Employee
select * from HumanResources.EmployeePayHistory

select * from humanresources.employee
select * from humanresources.employeepayhistory

 select p.firstname, p.lastname, salaryrevisions.revisedtime, 
       datediff(year, salaryrevisions.firstrevisiondate, salaryrevisions.lastrevisiondate) as duration
from (
    select eph.businessentityid, 
           count(eph.ratechangedate)  revisedtime, 
           min(eph.ratechangedate)  firstrevisiondate, 
           max(eph.ratechangedate)  lastrevisiondate
    from humanresources.employeepayhistory eph
    group by eph.businessentityid
) as salaryrevisions
join person.person p on p.businessentityid = salaryrevisions.businessentityid
order by revisedtime desc


--33.	 check if any employee from jobcandidate table is having any payment revisions
select * from humanresources.jobcandidate
select * from humanresources.employee
select * from humanresources.employeepayhistory

--Method 1
select * from humanresources.jobcandidate j where j.businessentityid
in(select businessentityid from humanresources.employee e where e.businessentityid in 
(select eph.businessentityid from humanresources.employeepayhistory eph group by eph.businessentityid
having count(eph.ratechangedate)>0))

--Method 2
select e.BusinessEntityID, p.FirstName, p.LastName, count(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
join HumanResources.JobCandidate j
on j.BusinessEntityID=p.BusinessEntityID
group by e.BusinessEntityID, p.FirstName, p.LastName
having count(eph.RateChangeDate) > 0

--34.	check the department having more salary revision
select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory
select * from HumanResources.EmployeePayHistory

--department with highest salary revision
select top 1 d.name as Department_with_More_Salary,count(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory edh 
on e.BusinessEntityID = edh.BusinessEntityID
join HumanResources.Department d 
on edh.DepartmentID = d.DepartmentID
group by d.name
order by PayRevisions Desc

--department salary revision list in descending order
select d.name as Department_with_More_Salary,count(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory edh 
on e.BusinessEntityID = edh.BusinessEntityID
join HumanResources.Department d 
on edh.DepartmentID = d.DepartmentID
group by d.name
order by PayRevisions Desc

--35.	 check the employee whose payment is not yet revised
select p.FirstName from Person.Person p where p.BusinessEntityID =
(select e.BusinessEntityID from HumanResources.Employee e where e.BusinessEntityID
not in (
select distinct eph.BusinessEntityID from HumanResources.EmployeePayHistory eph)
)--output is zero rows(query for verification purpose)

select e.BusinessEntityID, concat_ws(' ',p.FirstName, p.LastName)as EmployeeName
from HumanResources.Employee e
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
where e.BusinessEntityID not in 
(select distinct BusinessEntityID from HumanResources.EmployeePayHistory)

--36.	 find the job title having more revised payments
select* from HumanResources.Employee

select distinct e.JobTitle as Job_Title, 
count(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
group  by e.JobTitle
having count(eph.RateChangeDate) > 1
order by PayRevisions desc

--37.	 find the employee whose payment is revised in shortest duration (inline view)
select top 1 BusinessEntityID, FirstName, LastName, min(datediff(day,StartDate, EndDate)) 
as ShortestRevisionDuration
from (
    select e.BusinessEntityID, p.FirstName, p.LastName, eph.StartDate, eph.EndDate
    from HumanResources.EmployeeDepartmentHistory eph
    join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
    join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
) as PaymentRevisions
group by  BusinessEntityID, FirstName, LastName
order by ShortestRevisionDuration asc

--38.	 find the colour wise count of the product (tbl: product)
select Color, count(*) AS Color_Count from Production.Product where Color is not null
group by Color
order by Color_Count desc

--39.	 find out the product who are not in position to sell (hint: check the sell start and end date)
select*from Production.Product

select ProductID, Name
from Production.Product
where SellEndDate is not null
and 
SellEndDate < getdate() --if the sellend date is lesser than current datetime or in the past then
or 
SellStartDate is not null

--40.	  find the class wise, style wise average standard cost
select class Class,style Style,avg(StandardCost)Avg_Cost from Production.Product where
class is not null and Style is not null
group by Class,Style 
order by Avg_Cost 


--41.	 check colour wise standard cost
select * from Production.Product

select color Color,avg(StandardCost)Color_AvgCost from Production.Product
where color is not null 
group by Color
order by Color_AvgCost

--42.	 find the product line wise standard cost
select Productline Product_line,avg(StandardCost)P_Std from Production.Product
where ProductLine is not null
group by ProductLine
order by P_Std

--43.	Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince)
select sp.Name as StateName,avg(str.TaxRate)as Tax
from Sales.SalesTaxRate str
join Person.StateProvince sp 
on str.StateProvinceID = sp.StateProvinceID
group by sp.Name
order by sp.Name

--44.	Find the department wise count of employees
select* from HumanResources.Employee
select*from HumanResources.Department
select*from HumanResources.EmployeeDepartmentHistory

select d.Name as DepartmentName,count(e.BusinessEntityID) as EmployeeCount
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory edh
on e.BusinessEntityID=edh.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=edh.DepartmentID
group by d.Name

--45.	Find the department which is having more employees
select* from HumanResources.Employee
select*from HumanResources.Department
select*from HumanResources.EmployeeDepartmentHistory

select top 1 d.Name as DepartmentName,count(e.BusinessEntityID) as EmployeeCount
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory edh
on e.BusinessEntityID=edh.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=edh.DepartmentID
group by d.Name
order by EmployeeCount desc

--46.	Find the job title having more employees
select top 1 JobTitle as Job_Title,count(BusinessEntityID)as EmployeeCount
from HumanResources.Employee
group by JobTitle
order by EmployeeCount desc

--47.	Check if there is mass hiring of employees on single day
--highest mass hiring a day
select top 1 HireDate,count(BusinessEntityID)as HiringCount
from HumanResources.Employee
group by HireDate
order by HiringCount desc

--list of mass hiring
select HireDate,count(BusinessEntityID)as HiringCount
from HumanResources.Employee
group by HireDate
order by HiringCount desc

--48.	Which product is purchased more? (purchase order details)
select* from Production.Product
select* from Purchasing.PurchaseOrderDetail

--Product purchased most
select top 1 p.Name as ProductName, sum(pod.OrderQty)as PurchaseQty
from Production.Product p
join Purchasing.PurchaseOrderDetail pod
on p.ProductID=pod.ProductID
group by p.Name
order by PurchaseQty desc

--list of product purchased in descending order
select p.Name as ProductName, sum(pod.OrderQty)as PurchaseQty
from Production.Product p
join Purchasing.PurchaseOrderDetail pod
on p.ProductID=pod.ProductID
group by p.Name
order by PurchaseQty desc

--49.	Find the territory wise customers count   (hint: customer)
select*from sales.Customer
select*from sales.SalesTerritory

select t.Name as TerritoryName,count(c.CustomerID)as CustomerCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name

--50.	Which territory is having more customers (hint: customer)
select top 1 t.Name as TerritoryName,count(c.CustomerID)as CustomerCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name
order by CustomerCount desc

--51.	Which territory is having more stores (hint: customer)
select* from sales.Customer

select top 1 t.Name as TerritoryName,count(c.StoreID)as StoreCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name
order by StoreCount desc

--52.	 Is there any person having more than one credit card (hint: PersonCreditCard)
select*from Person.Person
select* from Sales.PersonCreditCard

select concat_ws(' ',p.FirstName,p.LastName)as PersonName,
count(pc.CreditCardID)as CreditCardCount
from Person.Person p
join sales.PersonCreditCard pc
on p.BusinessEntityID=pc.BusinessEntityID
group by p.FirstName,p.LastName
having count(pc.CreditCardID)>1

--53.	Find the product wise sale price (sales order details)
select*from Production.Product
select*from sales.SalesOrderDetail

select p.Name as ProductName,
avg(sd.UnitPrice) as SalePrice
from Production.Product p
join sales.SalesOrderDetail sd
on p.ProductID=sd.ProductID
group by p.ProductID,p.Name

--54.	Find the total values for line total product having maximum order
select*from Production.Product
select*from sales.SalesOrderDetail
select*from sales.SalesOrderHeader

select top 1 p.Name as ProductName,
avg(sd.UnitPrice) as SalePrice,
sum(sd.LineTotal)as TotalLine_Total
from Production.Product p
join sales.SalesOrderDetail sd
on p.ProductID=sd.ProductID
group by p.ProductID,p.Name
order by SalePrice desc

--55.	Calculate the age of employees
select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.BirthDate)as Age
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--56.	Calculate the year of experience of the employee based on hire date
select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.HireDate)as Experience_inYears
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--57.	Find the age of employee at the time of joining
select*from HumanResources.Employee

--Method 1
select businessentityid,birthdate, hiredate, 
datediff(year, birthdate, hiredate) as ageatjoining
from humanresources.employee

--Method 2
select  e.BusinessEntityID,concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(e.HireDate)-year(e.BirthDate)Age_at_joining
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--58.	Find the average age of male and female
select e.Gender as Gender,
Avg(year(getdate())-year(e.BirthDate))as Average_of_age
from HumanResources.Employee e
group by e.Gender


--59.	 Which product is the oldest product as on the date (refer  the product sell start date)
select*from Production.Product

select top 1 Name as ProductName,
year(getdate())-year(SellStartDate)as ProductAge
from Production.Product
order by ProductAge desc

--60.	 Display the product name, standard cost, and time duration for the same cost. (Product cost history)
select * from Production.ProductCostHistory

  select p.Name,
         ph.StandardCost,
	     DATEDIFF(YEAR,ph.EndDate,ph.StartDate)Time_duration,
         avg(ph.Standardcost)over(partition by DATEDIFF(YEAR,ph.EndDate,ph.StartDate))Avg_StandardCost
  from Production.ProductCostHistory ph
  join Production.Product p
  on p.ProductID=ph.ProductID
  where ph.EndDate is not null and
  ph.StartDate is not null

--61.	Find the purchase id where shipment is done 1 month later of order date  
 select * from purchasing.shipmethod
 select * from purchasing.purchaseorderheader

 select purchaseorderid    
 from purchasing.purchaseorderheader 
 where datediff(month,orderdate,shipdate)=1 

--62.	Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)
select sum(totaldue)total
from purchasing.purchaseorderheader where datediff(month,orderdate,shipdate)=1 


 --63.find the average difference in due date and ship date based on  online order flag
select onlineorderflag, 
avg(datediff(day, shipdate, duedate)) as avg_days_difference
from sales.salesorderheader
group by onlineorderflag


--64.	Display business entity id, marital status, gender, vacationhr, average vacation based on marital status
select * from HumanResources.Employee
select * from HumanResources.Department

select BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by maritalstatus)Vac_Mari_Status
from HumanResources.Employee

--65.	Display business entity id, marital status, gender, vacationhr, average vacation based on gender
select BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by gender)Avg_Based_Gender
from HumanResources.Employee

--66.	Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level
 select  BusinessEntityId,
        MaritalStatus,
		Gender,
		VacationHours,
	    avg(vacationhours)over(partition by Organizationlevel )Vac__Org_level
from HumanResources.Employee

--67.	Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept
select*from HumanResources.Department
select*from HumanResources.EmployeeDepartmentHistory
select*from HumanResources.Employee

--Method 1 (Joins only)
select e.BusinessEntityID,e.HireDate,Name as Department_Name,
count(e.BusinessEntityID) over (partition by d.Name) as Employee_Count1,
count(e.OrganizationLevel) over (partition by d.Name,e.organizationlevel) as Employee_Count2
from HumanResources.Department d
join HumanResources.EmployeeDepartmentHistory dh
on d.DepartmentID=dh.DepartmentID
join HumanResources.Employee e
on e.BusinessEntityID=dh.BusinessEntityID

--Method 2 (wih group by)
select e.BusinessEntityID,e.HireDate,Name as Department_Name,
count(e.BusinessEntityID) over (partition by d.Name) as Employee_Count1,
count(e.OrganizationLevel) over (partition by d.Name,e.organizationlevel) as Employee_Count2
from HumanResources.Department d
join HumanResources.EmployeeDepartmentHistory dh
on d.DepartmentID=dh.DepartmentID
join HumanResources.Employee e
on e.BusinessEntityID=dh.BusinessEntityID
group by d.Name, e.OrganizationLevel, e.BusinessEntityID, e.HireDate
order by d.Name, e.OrganizationLevel


--Method 3 (without joins)
select e.BusinessEntityID,e.HireDate,Name as Department_Name,
count(e.BusinessEntityID) over (partition by d.Name) as Employee_Count1,
count(e.OrganizationLevel) over (partition by d.Name,e.organizationlevel) as Employee_Count2
from HumanResources.Department d,
HumanResources.EmployeeDepartmentHistory dh,
HumanResources.Employee e
where d.DepartmentID=dh.DepartmentID
and
e.BusinessEntityID=dh.BusinessEntityID

--68.	Display department name, average sick leave and sick leave per department
select distinct
	   d.Name DepartmentName,
	   avg (SickLeaveHours) over(Partition by d.departmentID)Depart_Wise_Sickleave,
	   count(SickLeaveHours) over(Partition by d.departmentid)Org_lev_Sickleave
	   from HumanResources.Employee e join HumanResources.EmployeeDepartmentHistory eh
	   on e.BusinessEntityID=eh.BusinessEntityID
	   join HumanResources.Department d on 
	   d.DepartmentID=eh.DepartmentID

--69.Display the employee details first name, last name,  with total count 
--of various shift done by the person and shifts count per department

Select * from Person.Person
select * from HumanResources.Shift
select * from HumanResources.Employee
select * from HumanResources.Department
select * from HumanResources.EmployeeDepartmentHistory

select p.FirstName,
       p.LastName,
	   Count(s.ShiftID)TotalShift,
	   count(*)over(partition by d.departmentid)Dept_Shift_count
from Person.Person p
join HumanResources.Employee e
on p.BusinessEntityID=e.BusinessEntityID
join HumanResources.EmployeeDepartmentHistory ed
on ed.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=ed.DepartmentID
join HumanResources.Shift s
on s.ShiftID=ed.ShiftID
group by e.BusinessEntityID,p.FirstName,p.LastName,d.DepartmentID,d.Name

--70.Display country region code, group average sales quota based on territory id
select * from Sales.SalesPerson
select * from Sales.SalesTerritory

select st.CountryRegionCode,
       st.[Group],
	   avg(sp.SalesQuota) as Avg_SalesQuota
from Sales.SalesTerritory st
join Sales.SalesPerson sp
on sp.TerritoryID=st.TerritoryID
where SalesQuota is not null
group by st.CountryRegionCode,st.[Group]
order by st.CountryRegionCode,Avg_SalesQuota Desc




--71.	Display special offer description, category and avg(discount pct) per the category


Select * from Sales.SpecialOfferProduct
Select * from Sales.SpecialOffer

select distinct description,
        Category,
		avg(DiscountPct)over(partition by  category)Avg_By_Dispt_Cat
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct
sp
on sp.SpecialOfferID=so.SpecialOfferID


--72.	Display special offer description, category and avg(discount pct) per the month
select distinct
    description, 
    category, 
    month(startdate) as offermonth,
    avg(discountpct) over (partition by month(startdate)) as avg_discount_by_year
from sales.specialoffer so
join sales.specialofferproduct sp 
on sp.specialofferid = so.specialofferid;

--73.	Display special offer description, category and avg(discount pct) per the year
select distinct
    description, 
    category, 
    year(startdate) as offeryear,
	
    avg(so.discountpct) over (partition by year(so.startdate),year(so.enddate)) as avg_discount_by_year
from sales.specialoffer so
join sales.specialofferproduct sp 
    on sp.specialofferid = so.specialofferid;

--74.	Display special offer description, category and avg(discount pct) per the type
select distinct description,
        Category,
		avg(DiscountPct)over(partition by  type)Avg_By_Dispt_Type
from Sales.SpecialOffer so
join Sales.SpecialOfferProduct
sp
on sp.SpecialOfferID=so.SpecialOfferID

--75.	Using rank and dense rank find territory wise top sales person
select * from sales.salesterritory
select * from humanresources.employee

select 
    sp.businessentityid,
    st.territoryid,
    st.name as territoryname,
    sp.salesytd,
    rank() over (partition by st.territoryid order by sp.salesytd desc) as rank_ytd,
    dense_rank() over (partition by st.territoryid order by sp.salesytd desc) as dense_rank_ytd
from sales.salesperson sp
join humanresources.employee e on sp.businessentityid = e.businessentityid
join sales.salesterritory st on sp.territoryid = st.territoryid
where sp.salesytd is not null
order by st.territoryid, rank_ytd;
