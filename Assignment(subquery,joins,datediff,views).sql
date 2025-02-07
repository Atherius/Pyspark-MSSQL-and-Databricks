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

select pv.BusinessEntityID,
	(select v.Name 
	from Purchasing.Vendor v 
	where v.BusinessEntityID=pv.BusinessEntityID) 
	VendorName,
	(select p.Name
	from Production.Product p 
	where pv.ProductID=p.ProductID) 
	ProductName
from Purchasing.ProductVendor pv
where pv.ProductID in 
(select p.ProductID 
from  Production.Product p 
where p.Name like '%paint%' or 
	  p.Name like '%Blade%' or 
	  p.Name ='Adjustable Race')


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


--Q13. display employee name, territory name, sales last year, sales quota and bonus
select TerritoryID,
(Select concat(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus 
from sales.SalesPerson sp



--Q14. display employee name, territory name, sales last year, sales quota and bonus from germany and united kingdom
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


--Q15. find all employees who worked in all north american territory
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


--Q16. find all produccts in the cart
select
(Select Name from Production.Product pp where pp.ProductID=sc.ProductID)as ProductName,
(Select ProductNumber from Production.Product pp where pp.ProductID=sc.ProductID)as ProductNumber,
Quantity
from Sales.ShoppingCartItem sc


--Q17. find all products with special offer
select Name from Production.Product pp
where pp.ProductID in (
select ProductID from sales.SpecialOfferProduct sop
where SpecialOfferID in (
select SpecialOfferID from Sales.SpecialOffer where Type='No Discount'
))


--Q18. find all employees name, job title, card details of those whose creedit card expired in the month 11 and year 2008
select(select concat_ws(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select concat_ws(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)Card_detail
from Sales.PersonCreditCard pc where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc 
where cc.ExpMonth=11 and cc.ExpYear=2008)


--Q19.  Find the employee whose payment might be revised  (Hint : Employee payment history) 
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



--Q20. Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type) 
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


--Q21. Find the name of employees working in group of North America territory 
select* from sales.SalesTerritoryHistory

select distinct
concat_ws(' ',FirstName,LastName)as Employee_Name
from Person.Person p 
join  Sales.SalesTerritoryHistory sth
on p.BusinessEntityID=sth.BusinessEntityID
join Sales.SalesTerritory st
on st.TerritoryID=sth.TerritoryID
where st.[Group] in ('North America')


--Q22.  Find the employee whose payment is revised for more than once 
select e.BusinessEntityID, p.FirstName, p.LastName, count(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
join Person.Person p 
on e.BusinessEntityID = p.BusinessEntityID
group by e.BusinessEntityID, p.FirstName, p.LastName
having count(eph.RateChangeDate) > 1;


--Q23. display the personal details of  employee whose payment is revised for more than once.
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


--Q24. find the duration of payment revision on every interval  (inline view) Output must be as given format 
SELECT 
    d.BusinessEntityID,
    DATEDIFF_BIG(MONTH, d.Penultimate, d.Ultimate) AS MonthDifference
FROM ( 
    SELECT 
        t.BusinessEntityID,
        (SELECT RateChangeDate 
         FROM (SELECT BusinessEntityID, RateChangeDate, ROW_NUMBER() OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate DESC) AS rankNumber
               FROM HumanResources.EmployeePayHistory) AS sub
         WHERE sub.rankNumber = 1 AND sub.BusinessEntityID = t.BusinessEntityID
        ) AS Ultimate,
        (SELECT RateChangeDate 
         FROM (SELECT BusinessEntityID, RateChangeDate, ROW_NUMBER() OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate DESC) AS rankNumber
               FROM HumanResources.EmployeePayHistory) AS sub
         WHERE sub.rankNumber = 2 AND sub.BusinessEntityID = t.BusinessEntityID
        ) AS Penultimate
    FROM (SELECT DISTINCT BusinessEntityID FROM HumanResources.EmployeePayHistory) AS t
) AS d  
WHERE d.Penultimate IS NOT NULL;


--Q25.  check if any employee from jobcandidate table is having any payment revisions 
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


--Q26. check the department having more salary revision 
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


--Q27.  check the employee whose payment is not yet revised 
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


--Q28. find the job title having more revised payments
select* from HumanResources.Employee

select distinct e.JobTitle as Job_Title, 
count(eph.RateChangeDate) as PayRevisions
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e 
on eph.BusinessEntityID = e.BusinessEntityID
group  by e.JobTitle
having count(eph.RateChangeDate) > 1
order by PayRevisions desc


--Q29.  find the employee whose payment is revised in shortest duration (inline view) 
select BusinessEntityID, FirstName, LastName, min(datediff(day,StartDate, EndDate)) 
as ShortestRevisionDuration
from (
    select e.BusinessEntityID, p.FirstName, p.LastName, eph.StartDate, eph.EndDate
    from HumanResources.EmployeeDepartmentHistory eph
    join HumanResources.Employee e on eph.BusinessEntityID = e.BusinessEntityID
    join Person.Person p on e.BusinessEntityID = p.BusinessEntityID
) as PaymentRevisions
group by  BusinessEntityID, FirstName, LastName;


--Q30.  find the colour wise count of the product (tbl: product) 
select Color, count(*) AS Color_Count from Production.Product where Color is not null
group by Color
order by Color_Count desc

--Q31.  find out the product who are not in position to sell (hint: check the sell start and end date) 
select*from Production.Product

select ProductID, Name
from Production.Product
where SellEndDate is not null
and 
SellEndDate < getdate() --if the sellend date is lesser than current datetime or in the past then
or 
SellStartDate is not null


--Q32. find the class wise, style wise average standard cost 
select class Class,style Style,avg(StandardCost)Avg_Cost from Production.Product where
class is not null and Style is not null
group by Class,Style 
order by Avg_Cost 


--Q33. check colour wise standard cost 
 select * from Production.Product

 select color Color,avg(StandardCost)Color_AvgCost from Production.Product
 where color is not null 
 group by Color
 order by Color_AvgCost


 --Q34. find the product line wise standard cost 
 select Productline Product_line,avg(StandardCost)P_Std from Production.Product
 where ProductLine is not null
 group by ProductLine
 order by P_Std


 --Q35. Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 
select sp.Name as StateName,avg(str.TaxRate)as Tax
from Sales.SalesTaxRate str
join Person.StateProvince sp 
on str.StateProvinceID = sp.StateProvinceID
group by sp.Name
order by sp.Name


--Q36. Find the department wise count of employees 
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


--Q37. Find the department which is having more employees 
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


--Q38. Find the job title having more employees 
select JobTitle as Job_Title,count(BusinessEntityID)as EmployeeCount
from HumanResources.Employee
group by JobTitle
order by EmployeeCount desc


--Q39. Check if there is mass hiring of employees on single day
select top 1 HireDate,count(BusinessEntityID)as HiringCount
from HumanResources.Employee
group by HireDate
order by HiringCount desc


--Q40. Which product is purchased more? (purchase order details) 
select* from Production.Product
select* from Purchasing.PurchaseOrderDetail

select top 1 p.Name as ProductName, max(pod.OrderQty)as PurchaseQty
from Production.Product p
join Purchasing.PurchaseOrderDetail pod
on p.ProductID=pod.ProductID
group by p.Name
order by PurchaseQty desc


--Q41. Find the territory wise customers count(hint: customer) 
select*from sales.Customer
select*from sales.SalesTerritory

select t.Name as TerritoryName,count(c.CustomerID)as CustomerCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name


--Q42. Which territory is having more customers (hint: customer) 
select top 1 t.Name as TerritoryName,count(c.CustomerID)as CustomerCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name
order by CustomerCount desc


--Q43. Which territory is having more stores (hint: customer)
select* from sales.Customer

select top 1 t.Name as TerritoryName,count(c.StoreID)as StoreCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name
order by StoreCount desc


--Q44. Is there any person having more than one credit card (hint: PersonCreditCard)
select*from Person.Person
select* from Sales.PersonCreditCard

select concat_ws(' ',p.FirstName,p.LastName)as PersonName,
count(pc.CreditCardID)as CreditCardCount
from Person.Person p
join sales.PersonCreditCard pc
on p.BusinessEntityID=pc.BusinessEntityID
group by p.FirstName,p.LastName
having count(pc.CreditCardID)>1


--Q45. Find the product wise sale price (sales order details)
select*from Production.Product
select*from sales.SalesOrderDetail

select p.Name as ProductName,
avg(sd.UnitPrice) as SalePrice
from Production.Product p
join sales.SalesOrderDetail sd
on p.ProductID=sd.ProductID
group by p.ProductID,p.Name


--Q46. Find the total values for line total product having maximum order
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


--Q47. No Question in Question Bank
--Q48.	Calculate the age of employees 
select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.BirthDate)as Age
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Q49. Calculate the year of experience of the employee based on hire date
select concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(getdate())-year(e.HireDate)as Experience_inYears
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Q50.	Find the age of employee at the time of joining 
select*from HumanResources.Employee

SELECT BusinessEntityID,BirthDate, HireDate, 
datediff(year, BirthDate, HireDate) AS AgeAtJoining
FROM HumanResources.Employee

select  e.BusinessEntityID,concat_ws(' ',p.FirstName,p.LastName)as EmployeeName,
year(e.HireDate)-year(e.BirthDate)Age_at_joining
from HumanResources.Employee e
join Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Q51.	Find the average age of male and female
--Q51.	Find the average age of male and female
select e.Gender as Gender,
Avg(year(getdate())-year(e.BirthDate))as Average_of_age
from HumanResources.Employee e
group by e.Gender



--Q52. Which product is the oldest product as on the date (refer  the product sell start date)
select*from Production.Product

select top 1 Name as ProductName,
year(getdate())-year(SellStartDate)as ProductAge
from Production.Product
order by ProductAge desc
