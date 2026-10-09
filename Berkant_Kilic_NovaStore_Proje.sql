-- BÖLÜM 1: Veri Tabanı Tasarımı (Logical Design ve DDL)

-- 1. Veri Tabanı Oluşturma
CREATE DATABASE NovaStoreDB;
GO
USE NovaStoreDB;
GO

-- 2. Tablo Gereksinimleri
-- A. Categories (Kategoriler) Tablosu
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- B. Products (Ürünler) Tablosu
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

-- C. Customers (Müşteriler) Tablosu
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);

-- D. Orders (Siparişler) Tablosu
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

-- E. OrderDetails (Sipariş Detayları - Ara Tablo)
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL
);
GO

-- BÖLÜM 2: Veri Girişi (DML - Insert)

-- Görev 1: 5 Adet Kategori Ekleme
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'), ('Giyim'), ('Kitap'), ('Kozmetik'), ('Ev ve Yaşam');

-- Görev 2: Her Kategoriye Ait Toplam 12 Ürün Ekleme
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Laptop', 25000.00, 15, 1), ('Akıllı Telefon', 15000.00, 20, 1),
('Tişört', 250.00, 50, 2), ('Kot Pantolon', 600.00, 30, 2),
('Roman', 80.00, 100, 3), ('Bilim Kurgu Kitabı', 120.00, 40, 3),
('Parfüm', 800.00, 25, 4), ('Nemlendirici Krem', 300.00, 60, 4),
('Masa Lambası', 450.00, 35, 5), ('Nevresim Takımı', 1200.00, 10, 5),
('Kulaklık', 1500.00, 50, 1), ('Spor Ayakkabı', 2000.00, 40, 2);

-- Görev 3: 6 Adet Müşteri Kaydı Oluşturma
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz', 'İstanbul', 'ahmet@email.com'), ('Ayşe Demir', 'Ankara', 'ayse@email.com'),
('Mehmet Öz', 'İzmir', 'mehmet@email.com'), ('Fatma Şahin', 'Bursa', 'fatma@email.com'),
('Ali Kaya', 'Antalya', 'ali@email.com'), ('Zeynep Çelik', 'Eskişehir', 'zeynep@email.com');

-- Görev 4: Farklı Tarihlerde 8 Adet Sipariş ve Detayları
INSERT INTO Orders (CustomerID, TotalAmount) VALUES
(1, 26500.00), (2, 850.00), (3, 120.00), (4, 1100.00),
(5, 1200.00), (1, 450.00), (6, 2000.00), (2, 15000.00);

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1), (1, 11, 1), (2, 3, 1), (2, 4, 1), (3, 6, 1),
(4, 7, 1), (4, 8, 1), (5, 10, 1), (6, 9, 1), (7, 12, 1), (8, 2, 1);
GO

-- BÖLÜM 3: Sorgulama ve Analiz (DQL - Select ve Joins)

-- 1. Temel Listeleme
SELECT ProductName, Stock FROM Products WHERE Stock < 20 ORDER BY Stock DESC;

-- 2. Veri Birleştirme (JOIN)
SELECT c.FullName, c.City, o.OrderDate, o.TotalAmount
FROM Orders o INNER JOIN Customers c ON o.CustomerID = c.CustomerID;

-- 3. Çoklu Birleştirme ve Detay Raporu
SELECT c.FullName, p.ProductName, p.Price, cat.CategoryName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';

-- 4. Gruplama ve Aggregate Fonksiyonlar
SELECT c.CategoryName, COUNT(p.ProductID) AS UrunSayisi
FROM Categories c LEFT JOIN Products p ON c.CategoryID = p.CategoryID GROUP BY c.CategoryName;

-- 5. Ciro Analizi (Zor)
SELECT c.FullName, SUM(o.TotalAmount) AS ToplamCiro
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FullName ORDER BY ToplamCiro DESC;

-- 6. Zaman Analizi
SELECT OrderID, OrderDate, DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGun FROM Orders;
GO

-- BÖLÜM 4: İleri Seviye Veri Tabanı Nesneleri

-- 1. View (Görünüm) Oluşturma
CREATE VIEW vw_SiparisOzet AS
SELECT c.FullName AS [Müşteri Adı], o.OrderDate AS [Sipariş Tarihi], p.ProductName AS [Ürün Adı], od.Quantity AS [Adet]
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;
GO

-- 2. Yedekleme (Backup)
BACKUP DATABASE NovaStoreDB TO DISK = 'C:\Yedek\NovaStoreDB.bak';
GO

-- =========================================================================
-- BÖLÜM 6: EKSTRA İLERİ DÜZEY GELİŞTİRMELER (BONUS)
-- =========================================================================

-- 1. Veri Bütünlüğü Kısıtlamaları (Check Constraints)
ALTER TABLE Products 
ADD CONSTRAINT CK_Products_Price CHECK (Price >= 0),
    CONSTRAINT CK_Products_Stock CHECK (Stock >= 0);

ALTER TABLE OrderDetails 
ADD CONSTRAINT CK_OrderDetails_Quantity CHECK (Quantity > 0);
GO

-- 2. Performans İndeksleri (Non-Clustered Indexes)
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID ON Orders(CustomerID);
CREATE NONCLUSTERED INDEX IX_OrderDetails_OrderID_ProductID ON OrderDetails(OrderID, ProductID);
CREATE NONCLUSTERED INDEX IX_Products_CategoryID ON Products(CategoryID);
GO

-- 3. Stok Takip Trigger'ı (Otomatik Stok Düşürme & Kontrol)
CREATE TRIGGER trg_OrderDetails_StockUpdate
ON OrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM Products p
        JOIN inserted i ON p.ProductID = i.ProductID
        WHERE p.Stock < i.Quantity
    )
    BEGIN
        RAISERROR('HATA: Yetersiz stok! Sipariş işlemi geri alındı.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE p
    SET p.Stock = p.Stock - i.Quantity
    FROM Products p
    JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

-- 4. Dinamik Müşteri Segmentasyon Fonksiyonu (Scalar Function)
CREATE FUNCTION dbo.fn_GetCustomerSegment (@CustomerID INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @TotalSpent DECIMAL(10,2);
    DECLARE @Segment VARCHAR(20);

    SELECT @TotalSpent = ISNULL(SUM(TotalAmount), 0)
    FROM Orders
    WHERE CustomerID = @CustomerID;

    IF @TotalSpent >= 10000
        SET @Segment = 'Platin VIP';
    ELSE IF @TotalSpent >= 1000
        SET @Segment = 'Altın Üye';
    ELSE
        SET @Segment = 'Standart';

    RETURN @Segment;
END;
GO

-- 5. Güvenli Sipariş Oluşturma Saklı Yordamı (Transaction ile Stored Procedure)
CREATE PROCEDURE sp_CreateNewOrder
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UnitPrice DECIMAL(10,2);
        SELECT @UnitPrice = Price FROM Products WHERE ProductID = @ProductID;

        IF @UnitPrice IS NULL
        BEGIN
            RAISERROR('Ürün bulunamadı!', 16, 1);
        END

        DECLARE @OrderTotal DECIMAL(10,2) = @UnitPrice * @Quantity;

        INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
        VALUES (@CustomerID, GETDATE(), @OrderTotal);

        DECLARE @NewOrderID INT = SCOPE_IDENTITY();

        INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
        VALUES (@NewOrderID, @ProductID, @Quantity);

        COMMIT TRANSACTION;
        PRINT 'Sipariş başarıyla oluşturuldu ve stok trigger ile düşürüldü.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO