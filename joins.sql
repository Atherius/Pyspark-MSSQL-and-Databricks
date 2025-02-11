use AdventureWorks2022

select BusinessEntityID,ShiftID,GroupName,Name
from HumanResources.EmployeeDepartmentHistory as ed     --where ever we want to apply condition put in join 
full join HumanResources.Department as d               --otherwise use in subquery
on ed.DepartmentID=d.DepartmentID                       --if we want the particular rec or data then use subquery
                                                        --if we want rec from multiple columns then use joins


--find the employee working in group R and D


--find all records from production,production control ,executive,
--who are having bithdate more than 1970,display 1st name, 
--address details, jobtitle and department of this persons

select 
(select FirstName from Person.Person p where p.BusinessEntityID=ed.BusinessEntityID) as EmployeeName,
d.Name as Department,e.BirthDate,e.BusinessEntityID,e.JobTitle,
(select a.AddressLine1 from Person.Address a where a.AddressID = 
(select ba.AddressID from Person.BusinessEntityAddress ba 
where ba.BusinessEntityID = e.BusinessEntityID)) as EmployeeAddress
from 
HumanResources.EmployeeDepartmentHistory ed ,
HumanResources.Department d ,
HumanResources.Employee e 
where d.DepartmentID=ed.DepartmentID
and e.BusinessEntityID=ed.BusinessEntityID
and e.BirthDate>'01-01-1970'
and d.Name in('Production','Production Control','Executive')


--find all product scrapped more
--find most frequent purchased product

select * from Production.WorkOrder where ScrappedQty>0

--Highest Scrapped product
select p.Name from Production.Product p
where p.ProductID=(select wo.ProductID from Production.WorkOrder wo
where wo.ScrappedQty=(SELECT MAX(ScrappedQty) FROM Production.WorkOrder))

--Count of No of produts Scrapped
select COUNT(p.Name)as CountOfProduct from Production.Product p where p.ProductID IN (
    select wo.ProductID from Production.WorkOrder wo group by wo.ProductID
    Having COUNT(wo.ScrappedQty) > 1
)

--most frequent purchased product
select p.Name 
from Production.Product p 
where p.ProductID = (
    select top 1 pd.ProductID 
    from Purchasing.PurchaseOrderDetail pd
    group by pd.ProductID
    order by SUM(pd.OrderQty) DESC
);


--which product requires more inventory
select p.Name 
from Production.Product p 
where p.ProductID = (
    select top 1 pi.ProductID 
    from Production.ProductInventory pi
    group by pi.ProductID
    order by SUM(pi.Quantity) DESC
);


--find the most used ship mode
select* from Purchasing.ShipMethod
select* from Purchasing.PurchaseOrderHeader

--using subquery
select sm.Name from Purchasing.ShipMethod sm
where ShipMethodID = (
select top 1 ph.ShipMethodID
from Purchasing.PurchaseOrderHeader ph
group by ph.ShipMethodID
order by sum(ph.ShipMethodID) desc
)

--using join
select top 1 sm.Name 
from Purchasing.ShipMethod sm
full join Purchasing.PurchaseOrderHeader ph 
    on sm.ShipMethodID = ph.ShipMethodID
group by sm.Name
order by COUNT(ph.ShipMethodID) DESC;


--which currency consversion is more average End of Date Rate
select*from sales.Currency
select*from sales.CurrencyRate
select*from sales.CountryRegionCurrency

select Top 1 FromCurrencyCode,ToCurrencyCode,AVG(EndOfDayRate)as average
from Sales.CurrencyRate 
group by FromCurrencyCode,ToCurrencyCode
order by average desc


-- which currency consversion is with top values
select top 1 cr.FromCurrencyCode,cr.ToCurrencyCode,max(cr.EndOfDayRate) as topvalue
from Sales.CurrencyRate cr
group by  cr.FromCurrencyCode,cr.ToCurrencyCode
order by topvalue desc



-- which currency consversion is with least values
select top 1 cr.FromCurrencyCode,cr.ToCurrencyCode,max(cr.EndOfDayRate) as leastvalue
from Sales.CurrencyRate cr
group by  cr.FromCurrencyCode,cr.ToCurrencyCode
order by leastvalue asc

--what special offer was having more duration
select*from sales.SpecialOffer
select*from sales.SpecialOfferProduct

select top 1 sop.ProductID,
       (so.EndDate - so.StartDate) as diff
from sales.SpecialOffer so
full join Sales.SpecialOfferProduct sop 
    on so.SpecialOfferID = sop.SpecialOfferID
group by sop.ProductID, so.Description, so.StartDate, so.EndDate
order by diff desc;


--what are those products having moreSpecialOfferProduct
select*from sales.SpecialOffer
select*from sales.SpecialOfferProduct
select*from Production.Product

select top 1 sop.ProductID,p.Name as Product_Name,
COUNT(sop.ProductID) AS SpecialOfferCount
from sales.SpecialOfferProduct sop
full join Production.Product p
    on sop.ProductID=p.ProductID
group by sop.ProductID,p.Name
order by SpecialOfferCount desc


--Important functions
-- math fun 

select  ABS (-12.33),
		ceiling(12.33),
		floor(12.33),
		exp(1),
		power(2,4),
		RADIANS(90),
		ROUND(12.33,1),
		ascii('A')

select char(65),
       CHARINDEX('a','happy'),
	   DIFFERENCE('ABC','abc'),
	   DATALENGTH('abssaa')
