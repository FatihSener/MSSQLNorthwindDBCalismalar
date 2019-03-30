
--1.	T�m cirom ne kadar? 

select sum(Quantity*UnitPrice*(1-Discount)) from [Order Details]

--2.	1997'de t�m cirom ne kadar? 
select sum(Quantity*UnitPrice*(1-Discount)) Y�ll�kCiro from [Order Details] od
join Orders o on o.OrderID=od.OrderID
where o.OrderDate between '1997-01-01' and '1997-12-31'

--3.	Bug�n do�umg�n� olan �al��anlar�m kimler? 

select*from Employees
where ( DATEPART(month,BirthDate)=DATEPART(month,GETDATE())) and( DATEPART(day,BirthDate)=DATEPART(day,GETDATE()) ) 

--4.	Hangi �al��an�m hangi �al��am�na ba�l�?

select 
	RaporVeren.FirstName,
	RaporVeren.LastName,
	RaporAlan.FirstName,
	RaporAlan.LastName 
from Employees RaporVeren
		left join Employees RaporAlan on RaporVeren.ReportsTo=RaporAlan.EmployeeID

--5.	�al��anlar�m ne kadarl�k sat�� yapm��lar? 

select e.EmployeeID,e.FirstName,
cast(sum(od.Quantity*od.UnitPrice*(1-od.Discount))as decimal(18,2)) Cirosu
from Employees e
	left join Orders o on o.EmployeeID=e.EmployeeID
	left join [Order Details] od on od.OrderID=o.OrderID
group by e.EmployeeID,e.FirstName

--6.	Hangi �lkelere ihracat yap�yorum? 

select distinct  
Country from Customers 
where Country is not null and Country != 'USA'

--7.	�r�nlere g�re sat���m nas�l? 

select p.ProductName,
cast(sum(od.Quantity*od.UnitPrice*(1-od.Discount))as decimal(18,2)) UrunCirosu
from Products p
left join [Order Details] od on p.ProductID=od.ProductID
group by p.ProductID,p.ProductName

--8.	�r�n kategoilerine g�re sat��lar�m nas�l? (para baz�nda)

select  c.CategoryName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount))KataorilereGoreCiro
 from Products p
join Categories c on c.CategoryID=p.CategoryID
join [Order Details] od on od.ProductID=p.ProductID
group by c.CategoryName

--9.	�r�n kategoilerine g�re sat��lar�m nas�l? (say� baz�nda)

select  c.CategoryName,
sum(od.Quantity)KacAdetSatt�m
 from Products p
join Categories c on c.CategoryID=p.CategoryID
join [Order Details] od on od.ProductID=p.ProductID
group by c.CategoryName

--10.	�al��anlar �r�n baz�nda ne kadarl�k sat�� yapm��lar?

select e.FirstName+' '+e.LastName FullName,e.EmployeeID,
sum(od.Quantity)KacAdetSatt�m
from Employees e
	join Orders o on e.EmployeeID=o.EmployeeID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by e.EmployeeID,e.FirstName+' '+e.LastName

---11.	�al��anlar�m para olarak en fazla hangi �r�n� satm��lar? Ki�i baz�nda bir rapor istiyorum. 

select e.FirstName+' '+e.LastName FullName,
p.ProductName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount))KacAdetSatt�m
from Employees e
	join Orders o on e.EmployeeID=o.EmployeeID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by e.FirstName+' '+e.LastName,p.ProductName

--12.	Hangi kargo �irketine toplam ne kadar �deme yapm���m? 

select  s.CompanyName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount)) ToplamKargoUcreti
from Orders o
join [Order Details] od on od.OrderID=o.OrderID
join Shippers s on s.ShipperID=o.ShipVia
group by s.CompanyName

--13.	Tost yapmay� seven �al��an�m hangisi? 

select FirstName+' '+LastName as calisan,
	Notes as Bilgi
from Employees 
where Notes like '%Toast%' 

--14.	Hangi tedark�iden ald���m �r�nlerden ne kadar satm���m? (Sat�� bilgisi order details tablosundan al�nacak)

select s.CompanyName,p.ProductName,
sum(od.Quantity)KacAdetSatt�m
from Suppliers s
	join Products p on p.SupplierID=s.SupplierID
	join [Order Details] od on od.ProductID=p.ProductID
group by s.CompanyName,p.ProductName

---15.	En de�erli m��terim hangisi? (en fazla sat�� yapt���m m��teri) 

select top 1 c.CompanyName,
sum(od.Quantity*od.UnitPrice*(1-od.Discount))Al�nanUrun
from Customers c
	join Orders o on  c.CustomerID=o.CustomerID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by c.CompanyName

---16.	Hangi m��teriler para baz�nda en fazla hangi �r�n� alm��lar? 

select c.CompanyName,p.ProductName,
p.UnitPrice,
sum(od.Quantity)Al�nanUrun
from Customers c
	join Orders o on  c.CustomerID=o.CustomerID
	join [Order Details] od on o.OrderID=od.OrderID
	join Products p on p.ProductID=od.ProductID
group by p.ProductName,c.CompanyName,p.UnitPrice order by c.CompanyName


--17.	Hangi �lkelere ne kadarl�k sat�� yapm���m?

select distinct  c.Country,
sum(od.Quantity*od.UnitPrice*(1-od.Discount)) ToplamSatisUcreti 
from Customers c
	join Orders o on c.CustomerID=o.CustomerID
	join [Order Details] od on od.OrderID=o.OrderID
group by c.Country

--18.	Zaman�nda teslim edemedi�im sipari�lerim ID�leri  nelerdir ve ka� g�n ge� g�ndermi�im?

select RequiredDate,ShippedDate,
(
case
when RequiredDate>ShippedDate then DATEDIFF(day,ShippedDate,RequiredDate)
end)GecKal�nanZaman
from Orders 

--19.	Ortalama sat�� miktar�n�n �zerine ��kan sat��lar�m hangisi?

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

--20.	Sat��lar�m� ka� g�nde teslim etmi�im?

select
DATEDIFF(day,OrderDate,ShippedDate) TeslimS�resi
from Orders

--21.	Sipari� verilip de sto�umun yetersiz oldu�u �r�nler hangisidir? Bu �r�nlerden ka� tane eksi�im vard�r?
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
	
