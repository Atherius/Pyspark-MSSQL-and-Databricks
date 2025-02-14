use AdventureWorks2022

--A. Find employee having highest rate or highest pay frequency

select * from HumanResources.EmployeePayHistory
select * from Person.Person

select top 1 max(eph.Rate)Rate,concat_ws(' ',p.FirstName,p.LastName)Name
from HumanResources.EmployeePayHistory eph
join Person.Person p
on p.BusinessEntityID=eph.BusinessEntityID
group by eph.BusinessEntityID,p.FirstName,p.LastName
order by rate desc 

-- B. Analyze the inventory based on the shelf wise count of the product and their quantity

select * from Production.Product
select * from Production.ProductInventory

select sum(pi.Quantity)qty,pi.shelf,count(pi.ProductID)cnt
from Production.Product p
join Production.ProductInventory pi
on p.ProductID=pi.ProductID
group by pi.shelf
order by pi.shelf 

-- C. Find the personal details with address and address type

select * from Person.Person       
select * from Person.Address      
select * from Person.AddressType  
select* from Person.BusinessEntityAddress  

select p.FirstName,a.AddressLine1,at.Name
from Person.BusinessEntityAddress beid
join  Person.AddressType at
on beid.AddressTypeID=at.AddressTypeID
join Person.Address  a
on a.AddressID=beid.AddressID
join Person.Person p
ON p.BusinessEntityID=beid.BusinessEntityID

-- D. Find the job title having more revised payments

select * from HumanResources.EmployeePayHistory
select * from HumanResources.Employee

select top 1 e.JobTitle, count(eph.RateChangeDate)rate_change_cnt
from HumanResources.EmployeePayHistory eph
join HumanResources.Employee e
on eph.BusinessEntityID=e.BusinessEntityID
group by e.JobTitle
order by rate_change_cnt desc

-- E. Display special offer description, category and avg (discount pct) per the month

select * from Sales.SpecialOffer

select Category,Description,avg(DiscountPct)disc,month(StartDate)months
from Sales.SpecialOffer 
group by Category,Description,StartDate

-- G. Using rank and dense rank find territory wise top sales person

select CONCAT_WS(' ',p.FirstName,p.LastName)as name,sp.TerritoryID,rank()over (order by st.TerritoryID),
DENSE_RANK()over(order by st.TerritoryID) from person.Person p,Sales.SalesTerritory st,Sales.SalesPerson sp
where p.BusinessEntityID=sp.BusinessEntityID and st.TerritoryID=sp.TerritoryID

-- H. Calculate total years of experience of the employee and 
--    find out employees those who server for more than 20 years

select * from HumanResources.Employee

select BusinessEntityID,HireDate from HumanResources.Employee 
where year(GETDATE())-year(HireDate)>20                       

-- I. Find the employee who is having more vacations than 
--    the average vacation taken by all employees

select * from HumanResources.Employee
select * from Person.Person

select e.VacationHours,
(select concat_ws(' ',FirstName,LastName) from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)Name,
(select p.BusinessEntityID from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)Beid
from HumanResources.Employee e
where e.VacationHours>(select avg(e.VacationHours) from HumanResources.Employee e)

-- k. Find the department name having more employees

select * from HumanResources.Department  
select * from HumanResources.Employee    
select * from HumanResources.EmployeeDepartmentHistory  

select top 1 d.Name,count(e.BusinessEntityID)emp_cnt
from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Employee e
on e.BusinessEntityID=edh.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=edh.DepartmentID
group by d.Name
order by emp_cnt desc

-- L. Is there any person having more than one credit card (hint: PersonCreditCard)

select * from sales.PersonCreditCard
select * from Person.Person

select  count(CreditCardID)cnt,pcc.BusinessEntityID,p.FirstName
from Sales.PersonCreditCard pcc,Person.Person p
where pcc.BusinessEntityID=p.BusinessEntityID
group by pcc.BusinessEntityID,p.FirstName
having count(CreditCardID)>1

-- M. Find how many subcategories are available per category. (product sub category)

select * from Production.ProductSubcategory  

select  ProductCategoryID,count(ProductSubcategoryID)subcatID from Production.ProductSubcategory
group by ProductcategoryID

-- N. Find total standard cost for the active Product 
--    where end date is not updated. (Productcost history)

select * from Production.ProductCostHistory

select ProductID,StandardCost from Production.ProductCostHistory
where EndDate IS NULL

-- O. Which territory is having more customers (hint: customer)

select * from Sales.Customer
select * from sales.SalesTerritory

select top 1 st.Name,st.TerritoryID,count(c.CustomerID)cnt
from Sales.Customer c
join sales.SalesTerritory st 
on st.TerritoryID=c.TerritoryID
group by st.Name,st.TerritoryID
order by cnt desc 
