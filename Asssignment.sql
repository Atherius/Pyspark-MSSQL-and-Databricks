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
    avg(DATEDIFF(DAY, ph.OrderDate, ph.ShipDate)) as Avg_Shipping_Days
from Purchasing.PurchaseOrderHeader ph
join Purchasing.ShipMethod ps 
    on ph.ShipMethodID = ps.ShipMethodID
where ph.ShipDate is not null
group by ps.Name
order by Avg_Shipping_Days desc;



--Q8. Find the name of employees working in day shift 
select CONCAT_WS(' ',FirstName,LastName)as EmployeeName from Person.Person  where BusinessEntityID IN 
(SELECT BusinessEntityID from HumanResources.EmployeeDepartmentHistory where ShiftID in 
( select ShiftID from HumanResources.Shift where ShiftID=1))


--Q9. based on product and product cost history find the name, service provider time, and average standard cost
select* from Production.Product
select* from Production.ProductCostHistory

select 
p.Name as Product_Name,
DATEDIFF_BIG(DAY,MIN(StartDate),MAX(EndDate)) as service_provider_time,
AVG(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name


--Q10. find products with average cost more than 500
select 
p.Name as Product_Name,
AVG(ph.StandardCost)as Average_Standard_Cost
from Production.ProductCostHistory ph
join Production.Product p on
ph.ProductID=p.ProductID
group by p.Name
having AVG(ph.StandardCost)>500


--Q11. find the employees who worked in mulitple territories
select* from Person.Person
select*from HumanResources.Employee
select*from sales.SalesTerritory
select* from Sales.SalesTerritoryHistory

select
e.BusinessEntityID,
count(st.TerritoryID) as Territory_Count,
(select CONCAT_WS(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=e.BusinessEntityID)as Employee_Name
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
(Select CONCAT(FirstName,' ',LastName) from Person.Person pp where pp.BusinessEntityID=sp.BusinessEntityID)as EmployeeName,
(Select Name from sales.SalesTerritory st where st.TerritoryID=sp.TerritoryID)as TerritoryName,
(Select [Group] from Sales.SalesTerritory sl where sl.TerritoryID=sp.TerritoryID)as GroupName,
SalesLastYear,
SalesQuota,
Bonus 
from sales.SalesPerson sp



--Q14. display employee name, territory name, sales last year, sales quota and bonus from germany and united kingdom
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
)


--Q15. find all employees who worked in all north american territory
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
select(select CONCAT_WS(' ',FirstName,LastName)from Person.Person p where p.BusinessEntityID=pc.BusinessEntityID)EmpName,
(select JobTitle from HumanResources.Employee  e where e.BusinessEntityID=pc.BusinessEntityID)Job_Description,
(select CONCAT_WS(' : ',ExpMonth,ExpYear )from Sales.CreditCard cc where cc.CreditCardID=pc.CreditCardID)Card_detail
from Sales.PersonCreditCard pc where pc.CreditCardID in(select CreditCardID from Sales.CreditCard cc 
where cc.ExpMonth=11 and cc.ExpYear=2008)


--Q19. find tthe employees whose payment might be revised 
select 
    (select p.FirstName from Person.Person p where p.BusinessEntityID = e.BusinessEntityID) as FirstName,
    (select p.LastName from Person.Person p where p.BusinessEntityID = e.BusinessEntityID) as LastName,
    e.BusinessEntityID,
    (select COUNT(RateChangeDate) 
     from HumanResources.EmployeePayHistory eph 
     where eph.BusinessEntityID = e.BusinessEntityID) as PayRevisions
from HumanResources.Employee e
where (select COUNT(RateChangeDate) 
       from HumanResources.EmployeePayHistory eph 
       where eph.BusinessEntityID = e.BusinessEntityID) > 1
