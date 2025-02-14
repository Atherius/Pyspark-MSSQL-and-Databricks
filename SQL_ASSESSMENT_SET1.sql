use AdventureWorks2022

--A.  Find first 20 employees who joined very early in the company
select*from HumanResources.Employee
select*from Person.Person

select top 20 CONCAT_WS(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName,
concat_ws('/',DAY(e.HireDate),MONTH(e.HireDate),YEAR(e.HireDate))as JoiningDate
from Person.Person p
join HumanResources.Employee e
on p.BusinessEntityID=e.BusinessEntityID
order by year(e.HireDate) asc



--B. Find all employees name , job title, 
--card details whose credit card expired in the month 9 and year as 2009
select*from HumanResources.Employee
select*from Person.Person
select*from sales.PersonCreditCard
select*from sales.CreditCard

select(select concat_ws(' ',FirstName,LastName)from Person.Person p 
where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e 
where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select concat_ws(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc 
where cc.CreditCardID=pc.CreditCardID)Card_detail
from Sales.PersonCreditCard pc 
where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc 
where cc.ExpMonth=9 and cc.ExpYear=2009)



--C. Find the store address and contact number based on tables store and 
--Business entity  check if any other table is required.
select * from Sales.Store  --bussiness entity id,nameofstore,salespersonid
select * from sales.vStoreWithAddresses --bussinessentiity id,addressline 1
select * from Sales.vStoreWithContacts --bussiensseentiid,phonenumber

select s.Name,sa.AddressLine1,sc.PhoneNumber from sales.store s,sales.vStoreWithAddresses sa,Sales.vStoreWithContacts sc where
s.BusinessEntityID=sa.BusinessEntityID and sa.BusinessEntityID=sc.BusinessEntityID



--D. check if any employee from job candidate table is having any payment revisions
select*from HumanResources.JobCandidate

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



--E. check colour wise standard cost
 select * from Production.Product

 select color Color,avg(StandardCost)Color_AvgCost from Production.Product
 where color is not null 
 group by Color
 order by Color_AvgCost



--F. Which product is purchased more? (purchase order details)
select* from Production.Product
select*from sales.SalesOrderDetail
select*from Sales.SalesOrderHeader

select top 1 p.Name as ProductName,
sum(sd.OrderQty)as Product_Purchase_Qty
from
Production.Product p
join sales.SalesOrderDetail sd
on p.ProductID=sd.ProductID
group by p.Name
order by Product_Purchase_Qty desc

--G.  Find the total values for line total product having maximum order
select*from Production.Product
select*from sales.SalesOrderDetail
select*from sales.SalesOrderHeader

select top 1 p.Name as ProductName,
sum(sd.OrderQty) as OrderQty,
sum(sd.LineTotal)as TotalLine_Total
from Production.Product p
join sales.SalesOrderDetail sd
on p.ProductID=sd.ProductID
group by p.ProductID,p.Name
order by OrderQty desc


--H.  Which product is the oldest product as on the date (refer  the product sell start date)
select*from Production.Product

select top 1 Name as ProductName,
year(getdate())-year(SellStartDate)as ProductAge
from Production.Product
order by ProductAge desc

--I. Find all the employees whose salary is more than the average salary
select * from HumanResources.EmployeePayHistory  --beid,rate
select * from Person.Person  -- beid,Name

select eph.Rate,
(select concat_ws(' ',FirstName,LastName) from Person.Person p where p.BusinessEntityID=eph.BusinessEntityID)Name,
(select p.BusinessEntityID from Person.Person p where p.BusinessEntityID=eph.BusinessEntityID)Beid
from HumanResources.EmployeePayHistory eph
where eph.Rate>(select avg(Rate) from HumanResources.EmployeePayHistory)



--J. Display country region code, 
--group, average sales quota based on territory id 
select*from sales.SalesTerritory
select*from sales.SalesTerritoryHistory
select*from sales.SalesPerson

select
t.CountryRegionCode,
t.[Group],
avg(p.SalesQuota)as Average_salesQuota
from
sales.SalesPerson p
join sales.SalesTerritoryHistory h
on p.BusinessEntityID=h.BusinessEntityID
join sales. SalesTerritory t
on t.TerritoryID=h.TerritoryID
group by t.TerritoryID,t.[Group],t.CountryRegionCode

--k. Find the average age of male and female
select*from HumanResources.Employee

select e.Gender as Gender,
Avg(year(getdate())-year(e.BirthDate))as Average_of_age
from HumanResources.Employee e
group by e.Gender

--L. Which terrritory is having more stores? (purchase order details)
select* from sales.Customer

select top 1 t.Name as TerritoryName,count(c.StoreID)as StoreCount
from sales.Customer c
join sales.SalesTerritory t
on c.TerritoryID=t.TerritoryID
group by t.Name
order by StoreCount desc


--M. Check for sales person details  which are working in Stores (find the sales person ID)
select*from Sales.Store
select*from sales.SalesPerson
select*from sales.SalesOrderHeader

select distinct s.BusinessEntityID,s.Name from
Sales.Store s
join sales.SalesOrderHeader o
on o.SalesPersonID=s.SalesPersonID
join sales.SalesPerson p
on p.TerritoryID=o.TerritoryID
group by s.BusinessEntityID,s.Name


--N.  display the product name and product price 
--and count of product cost revised (productcost history)
select*from Production.Product
select*from Production.ProductCostHistory

select p.Name as ProductName,
p.ListPrice as Price
from
Production.Product p
join Production.ProductCostHistory h
on p.ProductID=h.ProductID
group by p.ProductID,p.Name,p.ListPrice
having count(h.StandardCost) > 1

--O.  check the department having more salary revision
select* from HumanResources.Department
select* from HumanResources.Employee
select* from HumanResources.EmployeeDepartmentHistory
select*from HumanResources.EmployeeDepartmentHistory

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
