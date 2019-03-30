
--1.	Tüm cirom ne kadar? 

select sum(Quantity*UnitPrice*(1-Discount)) from [Order Details]

--2.	1997'de tüm cirom ne kadar? 
select sum(Quantity*UnitPrice*(1-Discount)) YýllýkCiro from [Order Details] od
join Orders o on o.OrderID=od.OrderID
where o.OrderDate between '1997-01-01' and '1997-12-31'

--3.	Bugün doðumgünü olan çalýþanlarým kimler? 

select*from Employees
where ( DATEPART(month,BirthDate)=DATEPART(month,GETDATE())) and( DATEPART(day,BirthDate)=DATEPART(day,GETDATE()) ) 

--4.	Hangi çalýþaným hangi çalýþamýna baðlý?

select 
	RaporVeren.FirstName,
	RaporVeren.LastName,
	RaporAlan.FirstName,
	RaporAlan.LastName 
from Employees RaporVeren
		left join Employees RaporAlan on RaporVeren.ReportsTo=RaporAlan.EmployeeID

--5.	Çalýþanlarým ne kadarlýk satýþ yapmýþlar? 

select e.EmployeeID,e.FirstName,
cast(sum(od.Quantity*od.UnitPrice*(1-od.Discount))as decimal(18,2)) Cirosu
from Employees e
	left join Orders o on o.EmployeeID=e.EmployeeID
	left join [Order Details] od on od.OrderID=o.OrderID
group by e.EmployeeID,e.FirstName

--6.	Hangi ülkelere ihracat yapýyorum? 

select distinct  
Country from Customers 
where Country is not null and Country != 'USA'

--7.	Ürünlere göre satýþým nasýl? 

select p.ProductName,
cast(sum(od.Quantity*od.UnitPrice*(1-od.Discount))as decimal(18,2)) UrunCirosu
from Products p
left join [Order Details] od on p.ProductID=od.ProductID
group by p.ProductID,p.ProductName

--8.	Ürün kategoilerine göre satýþlarým nasýl? (para bazýnda)

select  c.CategoryName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount))KataorilereGoreCiro
 from Products p
join Categories c on c.CategoryID=p.CategoryID
join [Order Details] od on od.ProductID=p.ProductID
group by c.CategoryName

--9.	Ürün kategoilerine göre satýþlarým nasýl? (sayý bazýnda)

select  c.CategoryName,
sum(od.Quantity)KacAdetSattým
 from Products p
join Categories c on c.CategoryID=p.CategoryID
join [Order Details] od on od.ProductID=p.ProductID
group by c.CategoryName

--10.	Çalýþanlar ürün bazýnda ne kadarlýk satýþ yapmýþlar?

select e.FirstName+' '+e.LastName FullName,e.EmployeeID,
sum(od.Quantity)KacAdetSattým
from Employees e
	join Orders o on e.EmployeeID=o.EmployeeID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by e.EmployeeID,e.FirstName+' '+e.LastName

---11.	Çalýþanlarým para olarak en fazla hangi ürünü satmýþlar? Kiþi bazýnda bir rapor istiyorum. 

select e.FirstName+' '+e.LastName FullName,
p.ProductName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount))KacAdetSattým
from Employees e
	join Orders o on e.EmployeeID=o.EmployeeID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by e.FirstName+' '+e.LastName,p.ProductName

--12.	Hangi kargo þirketine toplam ne kadar ödeme yapmýþým? 

select  s.CompanyName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount)) ToplamKargoUcreti
from Orders o
join [Order Details] od on od.OrderID=o.OrderID
join Shippers s on s.ShipperID=o.ShipVia
group by s.CompanyName

--13.	Tost yapmayý seven çalýþaným hangisi? 

select FirstName+' '+LastName as calisan,
	Notes as Bilgi
from Employees 
where Notes like '%Toast%' 

--14.	Hangi tedarkçiden aldýðým ürünlerden ne kadar satmýþým? (Satýþ bilgisi order details tablosundan alýnacak)

select s.CompanyName,p.ProductName,
sum(od.Quantity)KacAdetSattým
from Suppliers s
	join Products p on p.SupplierID=s.SupplierID
	join [Order Details] od on od.ProductID=p.ProductID
group by s.CompanyName,p.ProductName

---15.	En deðerli müþterim hangisi? (en fazla satýþ yaptýðým müþteri) 

select top 1 c.CompanyName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount))AlýnanUrun
from Customers c
	join Orders o on  c.CustomerID=o.CustomerID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by c.CompanyName

---16.	Hangi müþteriler para bazýnda en fazla hangi ürünü almýþlar? 

select c.CompanyName,p.ProductName,
p.UnitPrice,
sum(od.Quantity)AlýnanUrun
from Customers c
	join Orders o on  c.CustomerID=o.CustomerID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by p.ProductName,c.CompanyName,p.UnitPrice order by c.CompanyName


--17.	Hangi ülkelere ne kadarlýk satýþ yapmýþým?

select distinct  c.Country,
sum(od.Quantity*od.UnitPrice*(1-od.Discount)) ToplamSatisUcreti 
from Customers c
	join Orders o on c.CustomerID=o.CustomerID
	join [Order Details] od on od.OrderID=o.OrderID
group by c.Country

--18.	Zamanýnda teslim edemediðim sipariþlerim ID’leri  nelerdir ve kaç gün geç göndermiþim?

select RequiredDate,ShippedDate,
(
case
when RequiredDate>ShippedDate then DATEDIFF(day,ShippedDate,RequiredDate)
end)GecKalýnanZaman
from Orders 

--19.	Ortalama satýþ miktarýnýn üzerine çýkan satýþlarým hangisi?

 declare @SiparisSayisi as int
select @SiparisSayisi=count(*) from Orders

declare @ToplamCiro as decimal(18,2)
select @ToplamCiro=sum(Quantity*UnitPrice*(1-Discount)) from [Order Details]

declare @OrtalamaSatisTutari as decimal(18,2)
set @OrtalamaSatisTutari=@ToplamCiro/@SiparisSayisi
select @OrtalamaSatisTutari

select OrderID,sum(Quantity*UnitPrice*(1-Discount)) from [Order Details]
group by OrderID
having sum(Quantity*UnitPrice*(1-Discount))>@OrtalamaSatisTutari

--20.	Satýþlarýmý kaç günde teslim etmiþim?

select
DATEDIFF(day,OrderDate,ShippedDate) TeslimSüresi
from Orders

--21.	Sipariþ verilip de stoðumun yetersiz olduðu ürünler hangisidir? Bu ürünlerden kaç tane eksiðim vardýr?
select
	p.ProductName,
	sum(od.Quantity) SiparisEdilen,
	p.UnitsInStock Stok,
	 sum(od.Quantity)-p.UnitsInStock Eksik
from  [Order Details] od
	join Products p on od.ProductID=p.ProductID
	join Orders o on od.OrderID=o.OrderID

where o.ShippedDate is null
group by p.ProductID,p.ProductName,p.UnitsInStock
having sum(od.Quantity)>p.UnitsInStock
	
