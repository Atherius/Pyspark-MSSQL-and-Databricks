use AdventureWorks2022

--My Queries
--select * from HumanResources.Department 
--select *from HumanResources.Department where Name='Sales'
--select Name, GroupName from HumanResources.Department group by Name,GroupName
--select * from HumanResources.EmployeeDepartmentHistory
--select*from HumanResources.Department d INNER JOIN HumanResources.EmployeeDepartmentHistory h ON  d.DepartmentID=h.DepartmentID
--select d.Name,d.GroupName,h.BusinessEntityID into taba1 from HumanResources.Department d INNER JOIN HumanResources.EmployeeDepartmentHistory h ON  d.DepartmentID=h.DepartmentID
--select*from HumanResources.Employee where BusinessEntityID >= 11 and BusinessEntityID <= 18
--select count(*) as count from HumanResources.Department where GroupName='Sales and Marketing'
--select count(*) as Total_count from HumanResources.Department 
--select*from HumanResources.Employee
--select count(*) as Count_of_married_male_employees from HumanResources.Employee where MaritalStatus='M' and Gender='M'
--select*from HumanResources.Employee where VacationHours>70
--select*from HumanResources.Employee where VacationHours>70 and VacationHours<90
--select*from HumanResources.Employee where VacationHours between 70 and 90 
--select*from HumanResources.Employee where JobTitle like '%Designer%'
--select count(*) as Total_technician_Count from HumanResources.Employee where JobTitle like '%Technician%'
--select*from HumanResources.Employee where JobTitle like '%Technician%'
--select NationalIDNumber,JobTitle,MaritalStatus,Gender from HumanResources.Employee where JobTitle like '%Marketing%'
--select NationalIDNumber,JobTitle,MaritalStatus,Gender from HumanResources.Employee where JobTitle like('%Marketing%')
--select * from HumanResources.Employee where VacationHours=(select MAX(VacationHours) from HumanResources.Employee) and SickLeaveHours=(select MIN(SickLeaveHours) from HumanResources.Employee)
--select * from HumanResources.Employee where VacationHours=(select MAX(VacationHours) from HumanResources.Employee)
--select * from HumanResources.Employee where SickLeaveHours=(select MIN(SickLeaveHours) from HumanResources.Employee)
--select max(VacationHours) from HumanResources.Employee
--select min(SickLeaveHours) from HumanResources.Employee
--exec.sp_help 'HumanResources.Department'
--select * from HumanResources.Department where Name='Production'
--select * from HumanResources.Employee where BusinessEntityID in (select BusinessEntityID from HumanResources.EmployeeDepartmentHistory where DepartmentID=7)

--Assessment/Practice

--Count of departments with group name as research and development
select Count(*) from HumanResources.Department where GroupName in 
(select GroupName from HumanResources.Department where GroupName like '%Research and Development%')



--Count of employees with group name as research and development
select count(*) from HumanResources.Employee where BusinessEntityID in 
(select BusinessEntityID from HumanResources.EmployeeDepartmentHistory where DepartmentID in 
(select DepartmentID from HumanResources.Department where GroupName like '%Research and Development%'))



--Count of Day Shift employees
select Count(*) as Day_shift_count from HumanResources.Employee where BusinessEntityID IN 
(SELECT BusinessEntityID from HumanResources.EmployeeDepartmentHistory where ShiftID in 
( select ShiftID from HumanResources.Shift where ShiftID=1))



--Payfrequency as 1
select count(*) as Pay_Frequency_as_1 from HumanResources.Employee where BusinessEntityID in 
(select BusinessEntityID from HumanResources.EmployeePayHistory where PayFrequency=1)



--count of candidates not placed
--SELECT COUNT(*) FROM HumanResources.Employee e WHERE NOT EXISTS (SELECT 1 FROM HumanResources.JobCandidate jc WHERE e.BusinessEntityID = jc.BusinessEntityID);
select count(*) from HumanResources.JobCandidate where BusinessEntityID is null



--find address
select concat(AddressLine1,',',City,',',PostalCode) as Address from Person.Address where AddressID in 
(select AddressID from Person.BusinessEntityAddress WHERE BusinessEntityID in 
(select BusinessEntityID from HumanResources.Employee))



--find first name
select FirstName,LastName from Person.Person where BusinessEntityID in 
(select BusinessEntityID from HumanResources.EmployeeDepartmentHistory where DepartmentID in 
(select DepartmentID from HumanResources.Department where GroupName='Research and Development'))



--correlated subquery
select BusinessEntityID,NationalIDNumber,JobTitle, 
(select firstname from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)fname 
from HumanResources.Employee e



--add personal details of emp middle name and last name
select BusinessEntityID,NationalIDNumber,JobTitle, 
(select firstname from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)fname,
(select MiddleName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)Mname,
(select LastName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)lname 
from HumanResources.Employee e



--concat
select CONCAT(FirstName,'  ',MiddleName,'  ',LastName)as FullName from Person.Person

--concat word separator
select CONCAT_WS('-',FirstName,MiddleName,LastName)as FullName from Person.Person

--for all emp disply  firstame,lastname,national id, departmentname,department group as details.
select (select NationalIDNumber from HumanResources.Employee emp where emp.BusinessEntityID=e.BusinessEntityID)as NationalID,
(select FirstName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as FirstName,
(select LastName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as LastName,
(select Name from HumanResources.Department d  where d.DepartmentID=e.DepartmentID)as DepartmentName,
(select GroupName from HumanResources.Department d where d.DepartmentID=e.DepartmentID)as GroupName 
from HumanResources.EmployeeDepartmentHistory e



--fname,lname,depname,shiptime
select (select FirstName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as FirstName,
(select LastName from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as LastName,
(select Name from HumanResources.Department d  where d.DepartmentID=e.DepartmentID)as DepartmentName,
(select CONCAT_WS('-',StartTime,EndTime) from HumanResources.Shift s where s.ShiftID=e.ShiftID)as ShiftTime 
from HumanResources.EmployeeDepartmentHistory e



--display product name and product review based on product schema(Left for Joins)
--find emp_name,job title,credit card details,when it expire
select(select concat(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=pc.BusinessEntityID)as Name,
(select JobTitle from HumanResources.Employee emp where emp.BusinessEntityID=pc.BusinessEntityID)as JobTitle,
(select CardNumber from sales.CreditCard sc where sc.CreditCardID=pc.CreditCardID)as CardNumber,
(select ExpMonth from sales.CreditCard sc where sc.CreditCardID=pc.CreditCardID)as CardExpireMonth,
(select ExpYear from sales.CreditCard sc where sc.CreditCardID=pc.CreditCardID)as CardExpireYear from Sales.PersonCreditCard pc



--disp records from currency rate from usd to aud
select* from sales.CurrencyRate where CurrencyRateID in (select CurrencyRateID from Sales.Currency where FromCurrencyCode='USD' and ToCurrencyCode='AUD')



--diap all terrritory name, group, sales last year, sales quota , bonus
select TerritoryID,
(Select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus 
from sales.SalesPerson sp



--diap all terrritory name, group, sales last year, sales quota , bonus whre teritorry is uk and germany
select TerritoryID,
(Select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
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
);



--diap all terrritory name, group, sales last year, sales quota , bonus whre teritorry Group is North America
select TerritoryID,
(Select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus
from sales.SalesPerson sp
WHERE sp.TerritoryID IN (
    SELECT TerritoryID 
    FROM Sales.SalesTerritory 
    WHERE [Group] IN ('North America')
);



--find all details of product in cart
select
(Select Name from Production.Product pp where pp.ProductID=sc.ProductID)as ProductName,
(Select ProductNumber from Production.Product pp where pp.ProductID=sc.ProductID)as ProductNumber,
Quantity
from Sales.ShoppingCartItem sc



--find all products with special offers
select Name from Production.Product pp
where pp.ProductID in (
select ProductID from sales.SpecialOfferProduct sop
where SpecialOfferID in (
select SpecialOfferID from Sales.SpecialOffer where Type='No Discount'
))



--find the average currency rate conversion from USD to Algerian Dinar and Australian Doller 
select AVG(AverageRate)as Average from Sales.CurrencyRate
group by ToCurrencyCode
having ToCurrencyCode='AUD'
