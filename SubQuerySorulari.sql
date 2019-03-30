------------------------------------SubQuery Soruları-------------------------
--1- Chai ürününden toplam 50 adetten fazla sipariþ vermiþ müþterilerimin listesi nedir.

select 
(select CompanyName from Customers where CustomerID=o.CustomerID)CompanyName ,
sum(t.Quantity) ToplamAdet 
from
	(select OrderID, Quantity 
	from [Order Details]
	where ProductID = (select ProductID from Products 
							where ProductName='Chai'))t
join Orders o on t.OrderID=o.OrderID
group by o.CustomerID
having sum(t.Quantity)>50

--2- Sipariþler tablosunda 4 ten az kaydý olan firmalar

select count(*),
(select CompanyName from Customers where CustomerID=o.CustomerID) CompanyName
from Orders o
group by CustomerID
having count(*)<4

--3- Müþterilerin ilk gerçekleþtirdikleri sipariþ tarihleri

select 
(select CompanyName from Customers where CustomerID=o.CustomerID) CompanyName,
	min(o.OrderDate) 
from Orders o
group by CustomerID

--4- 10249 Id li sipariþi hangi müþteri almýþtýr.

select*from Customers
where CustomerID=
		(select CustomerID from Orders where OrderID=10249)

--5- Ortalama satýþ miktarýnýn üzerine çýkan satýþlarým hangileridir

declare @toplamCiro as money
select @toplamCiro= sum(Quantity*UnitPrice*(1-Discount)) from [Order Details] 

declare @ToplamSiparisAdeti as int 
select @ToplamSiparisAdeti=count(*) from Orders

declare @OrtalamaSatisTutari as money 
set @OrtalamaSatisTutari =@toplamCiro/@ToplamSiparisAdeti

select OrderID,
@OrtalamaSatisTutari OrtalamaTutar,
sum(Quantity*UnitPrice*(1-Discount)) ToplamTutar
 from [Order Details]
group by OrderID
having sum(Quantity*UnitPrice*(1-Discount)) >@OrtalamaSatisTutari

--subquery ile 
select 
	OrderID ,
	sum(Quantity*UnitPrice*(1-Discount)) ToplamTutar 
from [Order Details]
group by OrderID 
having sum(Quantity*UnitPrice*(1-Discount))>
(select 
	avg(ToplamTutar)
 from
(select OrderID ,
sum(Quantity*UnitPrice*(1-Discount)) ToplamTutar 
from [Order Details]
group by OrderID )t)

--6- Çalýþanlarýmdan çalýþan yaþ ortalamasýnýn üzerinde olan çalýþanlarýmý listeleyiniz.
select 
	FirstName,
	LastName,
	DATEDIFF(YEAR,BirthDate,GETDATE()) Yas 
from Employees
where DATEDIFF(YEAR,BirthDate,GETDATE())>
(select
avg(DATEDIFF(YEAR,BirthDate,GETDATE()))
from Employees)

--7- En pahalý üründen daha yüksek kargo ücreti olan sipariþleri listeleyiniz.

select*from Orders
where Freight>(select max (UnitPrice)from Products)

--8- Ortalama ürün fiyatý 40 tan büyük olan kategorileri listeleyiniz

select 
(select CategoryName from Categories where CategoryID=p.CategoryID) CategoryName
from Products p
group by CategoryID
having avg(UnitPrice)>40

--9- 50 sipariþten fazla satýþ yapmýþ çalýþanlarýmý listeleyiniz

select FirstName,LastName from Employees
where EmployeeID in (select
EmployeeID
from Orders o
group by EmployeeID
having count(*)>50)

--10- Kategori adýnýn ilk harfi B ile D arasýnda olan fiyatý 30 liradan fazla olan ürünler

select * from Products
where CategoryID in
(select CategoryID from Categories where CategoryName like'[b-d]%')
and UnitPrice>30

--11- Çalýþanlarýmýn sipariþ bazýnda yaptýklarý en yüksek satýþlarý nelerdir. (adet bazýnda) (FullName,OrderID,ToplamUrunAdeti)

create table #temp
(
EmployeeID int,
OrderID int,
Adet int,
)

insert into #temp
select o.EmployeeID,od.OrderID,sum(od.Quantity) Adet from Orders o 
	join [Order Details] od on o.OrderID=od.OrderID
group by o.EmployeeID,od.OrderID

select 
	(select FirstName+' '+LastName from Employees where EmployeeID=t.EmployeeID) FullName,	
	(select top 1 OrderID from #temp where EmployeeID=t.EmployeeID and Adet=t.MaxAdet) OrderID,
	t.MaxAdet
from
(select EmployeeID,max(Adet) MaxAdet from #temp
group by EmployeeID)t

if(OBJECT_ID('tempdp..#temp') is not null)
begin
drop table #temp
end

--12- Hangi müþterilerimin verdiði sipariþ toplam tutarý 10000 den fazladýr.

select distinct
	(select CompanyName from Customers where CustomerID=o.CustomerID)CompanyName
from Orders o where OrderID in
(select 
OrderID
from [Order Details] od
group by od.OrderID
having sum(Quantity*UnitPrice*(1-Discount)) >10000)

---13- Hangi kargo þirketi hangi üründen en fazla taþýmýþtýr.

create table #temp
(
ShipperID int,
ProductID int,
SirketlerinTasidikleriUrunMiktari Decimal(18,2)
)

insert into #temp
select
o.ShipVia,od.ProductID,
sum(od.Quantity) SirketlerinTasidikleriUrunMiktari
from Orders o
	join [Order Details] od on od.OrderID=o.OrderID
	join Products p on p.ProductID=od.ProductID
group by o.ShipVia,od.ProductID

select 
	t2.ShipperID,
	(Select CompanyName from Shippers where ShipperID=t2.ShipperID) CompanyName,
	t2.ProductID,
	(Select ProductName from Products where ProductID=t2.ProductID) ProductName,
	t2.MaxUrun
(select
	t.ShipperID,
	(select ProductID from #temp
	where ShipperID=t.ShipperID and SirketlerinTasidikleriUrunMiktari=t.MaxUrun) ProductID,
	t.MaxUrun
from
	(select
		ShipperID,
		Max(SirketlerinTasidikleriUrunMiktari) MaxUrun
	from #temp
	group by ShipperID)t)t2

 If(OBJECT_ID('tempdb..#temp') Is Not Null)
Begin
    Drop Table #temp
End

--14- 01.01.1996 -01.01.1997 tarihleri arasýnda en fazla hangü ürün satýlmýþtýr.

select top 1 od.ProductID,
(select ProductName from Products where ProductID=od.ProductID) UrunAdi
from [Order Details] od where od.OrderID in
(select  OrderID from Orders where OrderDate between '1996-01-01' and '1997-01-01' )
group by od.ProductID
order by Sum(Quantity) desc

--15- Ürünlerin kendi fiyatlarýnýn tüm ürünlerin ortalama fiyatlarýna oranýný bulunuz.


select ProductName,UnitPrice from Products  where UnitPrice in(select  avg(UnitPrice) from Products)
avg(sum(UnitPrice))

select ProductName,UnitPrice from Products  where ProductID in(select ProductID from [Order Details] where (avg(UnitPrice)/sum(UnitPrice)) )

select 
(select  avg(sum(od.Quantity*od.UnitPrice*(1-od.Discount))) ToplamTutar from [Order Details] od where od.OrderID=OrderID)
from Orders o

sum(o.UnitPrice) UrununKendiFiyati
--16- Hangi ülkede hangi sipariþ en geç teslim edilmiþtir.

select  ShipCountry,OrderID
from Orders
where  RequiredDate<ShippedDate
group by ShipCountry,OrderID

select
OrderID,RequiredDate,ShippedDate,DATEDIFF(DAY,RequiredDate,ShippedDate) KacGün,ShipCountry
from Orders where ShippedDate is not null order by KacGün desc

--17- Hangi tedarikçiden hangi ürünler en fazla temin edilmiþtir.

select top 1
(select CompanyName from Suppliers where SupplierID=p.SupplierID) CompanyName,
p.ProductName,
sum(od.Quantity) ToplamAdet 
from Products p
	join [Order Details] od on p.ProductID=od.ProductID
group by p.ProductName,p.SupplierID
order by Sum(Quantity) desc

