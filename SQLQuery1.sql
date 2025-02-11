use Supply_Chain

create schema BIZM

CREATE TABLE BIZM.stores
(
  StoreId INT IDENTITY,
  StoreNumber Varchar(50),
  ContactNumber Varchar(10),
  Email Varchar(50),
  Address Varchar(120),
  City Varchar(40)
);

alter table BIZM.stores alter column Email varchar(6)

alter table BIZM.stores add vendorID int

alter table BIZM.stores drop column Address

exec sp_rename 'BIZM.stores.ContactNumber','mobile','column'

exec sp_rename 'BIZM.stores','dealer','object'    -- rename the table name store with dealer

create index id_Email on BIZM.dealer(Email)       -- creating email as id_Email as index

create table BIZM.regions(
rid int primary key Identity(1,1),
rname varchar (40)unique,
conti_name varchar(40),
modified_date datetime,
mod_user varchar(40))

insert into BIZM.regions(rname,conti_name,modified_date,mod_user)
values ('East Asia','Asia',GETDATE(),'Harry'),
       ('North Asia','Asia',GETDATE(),'Puttar')


select * from BIZM.regions

alter table BIZM.dealer add constraint con_name check (len(mobile)=10)

alter table BIZM.dealer add constraint id_pri_name primary key (StoreID)

-- alter table  tbname add constraint cname foreign key references tbl2()
ALTER TABLE BIZM.dealer ADD CONSTRAINT unq_vendorID UNIQUE (vendorID)

CREATE TABLE BIZM.new_table (
    new_id INT IDENTITY PRIMARY KEY,
    dealerID INT,
    FOREIGN KEY (dealerID) REFERENCES BIZM.dealer(vendorID)
)


SELECT*FROM BIZM.dealer
/*
create table BIZM.customers as
select*from AdventureWorks2022.Person.Person
where 1=0
*/

-- Create table BIZM.customers with the same structure as AdventureWorks2022.Person.Person but with no data
-- Create the BIZM.customers table without the problematic XML columns
CREATE TABLE BIZM.customers
(
    BusinessEntityID INT,
    PersonType NVARCHAR(2),
    NameStyle BIT,
    Title NVARCHAR(8),
    FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50),
    LastName NVARCHAR(50),
    Suffix NVARCHAR(10),
    EmailPromotion INT,
    rowguid UNIQUEIDENTIFIER,
    ModifiedDate DATETIME
)

-- Insert data into BIZM.customers from AdventureWorks2022.Person.Person excluding XML columns
INSERT INTO BIZM.customers (BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, rowguid, ModifiedDate)
SELECT BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix, EmailPromotion, rowguid, ModifiedDate
FROM AdventureWorks2022.Person.Person

-- Select all rows from BIZM.customers to verify the import
SELECT * FROM BIZM.customers


--CREATE TABLE by copyning names of the columns from another table
SELECT p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,p.PersonType,
p.Suffix,p.NameStyle,p.ModifiedDate,p.Title
INTO BIZM.customers1 from
AdventureWorks2022.Person.Person p
where 1=0

select*from BIZM.customers1

insert into BIZM.customers1(BusinessEntityID,FirstName,MiddleName,LastName,PersonType,
Suffix,NameStyle,ModifiedDate,Title) 
SELECT BusinessEntityID,FirstName,MiddleName,LastName,PersonType,Suffix,NameStyle,
ModifiedDate,Title
FROM AdventureWorks2022.Person.Person



--Self Join
select top 10 CONCAT_WS(' ',c1.FirstName,c1.MiddleName,c1.LastName)as Name1_Table1,
concat_ws(' ',c2.FirstName,c2.MiddleName,c2.LastName)as Name2_Table2
from BIZM.customers1 c1
join BIZM.customers1 c2
on c1.BusinessEntityID=c2.BusinessEntityID

--Inner Join
select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName 
from AdventureWorks2022.HumanResources.Employee e
inner join AdventureWorks2022.Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--Left Join
select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName 
from AdventureWorks2022.HumanResources.Employee e
left join AdventureWorks2022.Person.Person p
on e.BusinessEntityID=p.BusinessEntityID

--Right Join
select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName 
from AdventureWorks2022.HumanResources.Employee e
right join AdventureWorks2022.Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Full Join
select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName 
from AdventureWorks2022.HumanResources.Employee e
full join AdventureWorks2022.Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Inner Join(Default)
select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName 
from AdventureWorks2022.HumanResources.Employee e
join AdventureWorks2022.Person.Person p
on e.BusinessEntityID=p.BusinessEntityID


--Cross Join
select concat_ws(' ',p.FirstName,p.MiddleName,p.LastName)as EmployeeName 
from AdventureWorks2022.HumanResources.Employee e
cross join AdventureWorks2022.Person.Person p


--Window Function
use AdventureWorks2022

select FirstName,MiddleName,
LastName,JobTitle,
(select avg(rate) from [HumanResources].[EmployeePayHistory]
where BusinessEntityID=p.BusinessEntityID)avg_rate_per_person
from Person.Person p,HumanResources.Employee e
where p.BusinessEntityID=e.BusinessEntityID

select e.BusinessEntityID,JobTitle,
avg(rate) over (partition by jobtitle)avg_rate_per_job_title
from [HumanResources].[EmployeePayHistory] ep,HumanResources.Employee e
where ep.BusinessEntityID=e.BusinessEntityID

select*from HumanResources.EmployeePayHistory
where BusinessEntityID in (248,245)

--find out the std cost year wise
select year(StartDate) as Years,
avg(StandardCost)as average_of_StandardCost
from Production.ProductCostHistory
group by year(StartDate)

select year(StartDate) as Years,
sum(StandardCost)as sum_of_StandardCost
from Production.ProductCostHistory
group by StartDate

--ProductID wise sum
select ProductID,
year(StartDate) as Years,
sum(StandardCost) over(partition by productid)sum_of_StandardCost
from Production.ProductCostHistory

--Year wise sum
select ProductID,
year(StartDate) as Years,
sum(StandardCost) over(partition by year(StartDate))sum_of_StandardCost
from Production.ProductCostHistory

select *
from Production.ProductCostHistory
where ProductID=707

--ProductID year wise sum
select ProductID,
year(StartDate) as Years,
sum(StandardCost) over(partition by year(StartDate),productid)sum_of_StandardCost
from Production.ProductCostHistory

select ProductID,
year(StartDate) as Years,
sum(StandardCost) over(partition by productid,year(StartDate))sum_of_StandardCost
from Production.ProductCostHistory

select ProductID,
year(StartDate) as Years,
sum(StandardCost)as sum_of_StandardCost
from Production.ProductCostHistory
group by ProductID,year(StartDate)

select ProductID,
year(StartDate) as Years,
sum(StandardCost)as sum_of_StandardCost
from Production.ProductCostHistory
group by year(StartDate),ProductID


/* -- display business entity id, marital status, gender,
 vacationhr, average vacation based on marital status -- */
select BusinessEntityID,MaritalStatus,Gender,avg(VacationHours)as avg_Vacation_hours
from HumanResources.Employee
group by MaritalStatus,BusinessEntityID,gender

select BusinessEntityID,MaritalStatus,Gender,
avg(VacationHours) over (partition by maritalstatus)avg_Vacation_hours
from HumanResources.Employee

/* -- display business entity id, marital status, gender,
 vacationhr, average vacation based on organizational level -- */
select BusinessEntityID,MaritalStatus,Gender,OrganizationLevel,
avg(VacationHours) over (partition by organizationlevel)avg_Vacation_hours
from HumanResources.Employee

/* -- display business entity id,hire date,department and department wise count
of employees based on organizational level of employees in each department-- */
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

--department wise average sick leave hours
select * from HumanResources.Department --departmentid,department name
select * from HumanResources.Employee -- busienss entityid,sickleave hrs
select * from HumanResources.EmployeeDepartmentHistory--business entity id,department id

--Attempt 1 (without joins)
select d.Name,e.SickLeaveHours,
avg(e.SickLeaveHours) over (partition by d.name)avg_sick_leave_per_dept
from HumanResources.EmployeeDepartmentHistory edh,
HumanResources.Employee e,HumanResources.Department d 
where edh.BusinessEntityID=e.BusinessEntityID and edh.DepartmentID=d.DepartmentID

--Attempt 2 (with joins)
select d.Name,e.SickLeaveHours,
avg(e.SickLeaveHours) over (partition by d.name)avg_sick_leave_per_dept
from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Employee e
on edh.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d 
on d.DepartmentID=edh.DepartmentID

--Attempt 3 (sub-query,joins)
select DepartmentName,
avg(SickLeaveHours) AS avg_sick_leave_per_dept
from (select d.Name AS DepartmentName,e.SickLeaveHours
from HumanResources.EmployeeDepartmentHistory edh
join HumanResources.Employee e 
on edh.BusinessEntityID = e.BusinessEntityID
join HumanResources.Department d 
on d.DepartmentID = edh.DepartmentID) as EmployeeData
group by DepartmentName;

--Final Answer
select distinct d.Name,
(select avg(SickLeaveHours) from HumanResources.Employee),
avg(e.SickLeaveHours) over (partition by d.name)
from HumanResources.EmployeeDepartmentHistory edh,
HumanResources.Employee e,HumanResources.Department d 
where edh.BusinessEntityID=e.BusinessEntityID and edh.DepartmentID=d.DepartmentID

--diplay department name and geneder count of employees based on department
select distinct d.Name AS DepartmentName, e.Gender, 
count(e.BusinessEntityID) over(partition by d.DepartmentID, e.Gender) as GenderCount
from HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory edh 
on e.BusinessEntityID = edh.BusinessEntityID
join HumanResources.Department d 
on edh.DepartmentID = d.DepartmentID;

-- check the person details with total count of various shifts working per department and count per department
select*from Person.Person
select*from HumanResources.EmployeeDepartmentHistory
select*from HumanResources.Department

select distinct p.BusinessEntityID,p.FirstName,
count(sh.ShiftID) over(partition by e.businessEntityID)Person_in_various,
count(sh.ShiftID) over(partition by d.departmentid)Shit_count_Department
from HumanResources.EmployeeDepartmentHistory eph
join HumanResources.Employee e
on e.BusinessEntityID=eph.BusinessEntityID
join HumanResources.Shift sh
on sh.ShiftID=eph.ShiftID
join Person.Person p
on p.BusinessEntityID=eph.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID=eph.DepartmentID

--display country region code,group,average sales quota based on territory id
select * from sales.SalesTerritory
select * from Sales.SalesPerson

select distinct st.TerritoryID,st.CountryRegionCode,st.Name,st.[Group],
avg(sp.SalesQuota) over (partition by st.territoryid)as AverageSalesQuota
from Sales.SalesPerson sp
join sales.SalesTerritory st
on sp.TerritoryID=st.TerritoryID

-- display special offer description, category and avg discount pct as per the category
select*from sales.SpecialOffer
select*from Sales.SpecialOfferProduct

select SpecialOfferID,Description,Category,
avg(DiscountPct) over (partition by Category)as Average_DiscountPCT
from Sales.SpecialOffer

-- display special offer description, category and avg discount pct as per the year
select*from sales.SpecialOffer
select*from Sales.SpecialOfferProduct

select distinct SpecialOfferID,Description,Category,
avg(DiscountPct) over (partition by month(EndDate))as Average_DiscountPCT
from Sales.SpecialOffer

-- display special offer description, category and avg discount pct as per the year
select*from sales.SpecialOffer
select*from Sales.SpecialOfferProduct

select SpecialOfferID,Description,Category,
avg(DiscountPct) over (partition by year(EndDate))as Average_DiscountPCT
from Sales.SpecialOffer

-- display special offer description, category and avg discount pct as per the type
select*from sales.SpecialOffer
select*from Sales.SpecialOfferProduct

select SpecialOfferID,Description,Category,
avg(DiscountPct) over (partition by type)as Average_DiscountPCT
from Sales.SpecialOffer

-----
select top 10 BusinessEntityID,
NationalIDNumber,
max(VacationHours) over (order by vacationhours asc)max_vacationhours
from HumanResources.Employee

select top 10 businessentityid,nationalidnumber,
max(vacationhours) over (order by vacationhours asc) as max_vacationhours,
avg(vacationhours) over (order by vacationhours rows between 1 preceding and 1 following) as avg_vacationhours
from humanresources.employee

select top 10 businessentityid,nationalidnumber,
max(vacationhours) over (order by vacationhours asc) as max_vacationhours,
avg(vacationhours) over (order by vacationhours rows between unbounded preceding and unbounded following) as avg_vacationhours
from humanresources.employee

select top 10 businessentityid,nationalidnumber,
max(vacationhours) over (partition by gender order by vacationhours asc) as max_vacationhours,
avg(vacationhours) over (order by vacationhours rows between 2 preceding and 2 following) as avg_vacationhours
from humanresources.employee
-- dense-rank
select top 10
NationalIDNumber,
Gender,VacationHours,
RANK() over (order by vacationhours)as rank_vacationhours,
dense_rank() over (order by vacationhours)as dense_rank_vacationhours
from HumanResources.Employee 

--lag
select top 10
businessentityid,
vacationhours,
lag(vacationhours, 1, 0) over (order by hiredate) as previousvacationhours
from humanresources.employee

--lead
select top 10
businessentityid,
vacationhours,
lead(vacationhours, 1, 0) over (order by hiredate) as previousvacationhours
from humanresources.employee

select BusinessEntityID,
VacationHours,
avg(VacationHours) over (),
gender,
avg(VacationHours) over(partition by gender),
maritalstatus,
avg(VacationHours) over(partition by maritalstatus),
VacationHours,
avg(VacationHours) over(partition by vacationhours)
from HumanResources.Employee

select BusinessEntityID,
VacationHours,
avg(VacationHours) over (),
avg(VacationHours) over(partition by BusinessEntityID)
from HumanResources.Employee

/*
update HumanResources.Employee
set VacationHours=0
where BusinessEntityID=1
*/
select*from BIZM.regions

--delete from BIZM.regions where mod_user = 'amal';
