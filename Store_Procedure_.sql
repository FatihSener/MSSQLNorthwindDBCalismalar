--ProductName, Discontinued, CategoryName parametreleri alýp önce kategori tablosuna 
--sonra ilgili kategoriye göre product tablosuna insert iþlemi yapan store prosedure yazýnýz.
--(Transaction ve Identity yakalama yöntemleri kullanýlacak)
CREATE PROCEDURE sp_InsertCategoryProduct
(
	@ProductName NVARCHAR(40),
	@Discontinued BIT,
	@CategoryName NVARCHAR(15)
)
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY	
		INSERT INTO Categories(CategoryName) VALUES (@CategoryName)
		DECLARE @CategoryID INT
		SET @CategoryID = SCOPE_IDENTITY()

		INSERT INTO Products(ProductName,Discontinued,CategoryID) VALUES (@ProductName, @Discontinued, @CategoryID)
		COMMIT TRAN
		PRINT 'Ýþlem Tamamlandý.'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'Bir Hatadan Dolayý Ýþlem Yapýlamamýþtýr!'
	END CATCH
END

EXEC sp_InsertCategoryProduct Bilgisayar,0,Elektronik

SELECT * FROM Products
SELECT * FROM Categories