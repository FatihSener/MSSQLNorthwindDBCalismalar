--ProductName, Discontinued, CategoryName parametreleri al�p �nce kategori tablosuna 
--sonra ilgili kategoriye g�re product tablosuna insert i�lemi yapan store prosedure yaz�n�z.
--(Transaction ve Identity yakalama y�ntemleri kullan�lacak)
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
		PRINT '��lem Tamamland�.'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'Bir Hatadan Dolay� ��lem Yap�lamam��t�r!'
	END CATCH
END

EXEC sp_InsertCategoryProduct Bilgisayar,0,Elektronik

SELECT * FROM Products
SELECT * FROM Categories