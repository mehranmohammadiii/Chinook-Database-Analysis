select *
from Artist
---------
select *
from Album -->[ArtistId]
---------
select *
from Track -->[AlbumId][MediaTypeId][GenreId]
---------
select *
from MediaType
---------
select *
from Genre
---------
select *
from Playlist
---------
select *
from PlaylistTrack
---------
select *
from Invoice -->[CustomerId]
---------
select *
from InvoiceLine -->[InvoiceId],[TrackId]
---------
select *
from Customer--> [SupportRepId]
---------
select *
from Employee -->[ReportsTo]
GO
----------------------------------------------------------------------------------------------------------------------
--view

Create view	V_CustomerInvoices			--نمایش لیست کامل مشتری‌ها به همراه تاریخ و مبلغ فاکتور
AS															
	select Customer.FirstName + ' ' + Customer.LastName AS[FullName],
	Customer.City,Invoice.Total,Invoice.InvoiceDate
	from Customer inner join Invoice
	on Customer.CustomerId=Invoice.CustomerId;
GO

Create view V_InvoiceDetails			--نمای کلی از فاکتور + ترک‌هایی که در آن فاکتور خریداری شده
AS
	select Customer.FirstName + ' ' + Customer.LastName AS[FullName],
		   Invoice.InvoiceId,
		   Track.[Name],
		   Invoiceline.UnitPrice,
		   Invoiceline.Quantity,
		   (Invoiceline.UnitPrice*Invoiceline.Quantity) AS [Line Total]
	from Invoice inner join InvoiceLine
	on Invoice.InvoiceId=InvoiceLine.InvoiceId inner join Track
	on InvoiceLine.TrackId=Track.TrackId inner join Customer
	on Customer.CustomerId=Invoice.InvoiceId;
GO

Create view V_MonthlyRevenue			--مجموع فروش به تفکیک ماه و سال
AS
	select year(InvoiceDate) AS[InvoiceYear],
	month(InvoiceDate) AS [InvoiceMonth],
	sum (Total) AS[MonthlyTotal],
	count(Total) [Number of sales]
	from Invoice
	group by year(InvoiceDate),month(InvoiceDate);
GO

Create view V_TopSellingTracks			--لیست ترک‌های پرفروش به ترتیب فروش
AS
	select InvoiceLine.TrackId,Track.[Name],count(InvoiceLine.TrackId) AS[TotalSold]
	from InvoiceLine inner join Track
	on InvoiceLine.TrackId=Track.TrackId
	group by InvoiceLine.TrackId,Track.[Name]
	having count(InvoiceLine.TrackId)>=2;
GO

Create view V_ArtistAlbumCount			--تعداد آلبوم‌های هر هنرمند		
AS
	select Artist.[Name],Album.Title
	from Artist inner join Album
	on Artist.ArtistId=Album.ArtistId;
GO

Create view V_CustomerCountryCount		--تعداد مشتری در هر کشور
AS
	select Country,count(Country) AS[CustomerCount] 
	from Customer
	group by Country; 
GO

Create view V_EmployeeCustomers			--لیست تمام مشتریانی که توسط هر کارمند پشتیبانی می‌شوند
AS
	select Employee.FirstName + ' ' + Employee.LastName AS[FullName],
		   Customer.CustomerId
	from Employee inner join Customer
	on Employee.EmployeeId=Customer.SupportRepId
GO

Create view V_GenreTrackCount			--تعداد ترک‌های هر سبک موسیقی
AS
	select Track.GenreId,Genre.[Name],count(Track.TrackId) AS[TrackCount]
	from Track inner join Genre
	on Track.GenreId=Genre.GenreId
	group by Track.GenreId,Genre.[Name]
GO

Create view V_AlbumTrackList			--لیست ترک‌های هر آلبوم همراه با نام هنرمند و مدت زمان ترک
AS
	select Track.AlbumId,Track.TrackId,Artist.[Name],Track.Milliseconds / 60000 AS [TrackDurationMinutes]
	from Album inner join Track
	on Album.AlbumId=Track.AlbumId inner join Artist
	on Album.ArtistId=Artist.ArtistId
	group by Track.AlbumId,Track.TrackId,Track.Milliseconds,Artist.[Name]
GO

Create view V_CustomerLastInvoice			--آخرین فاکتور هر مشتری برای گزارش خریدهای جدید
AS
	with cte_1 As	(
			select ROW_NUMBER() over(partition by Invoice.[CustomerId] order by Invoice.[InvoiceDate] desc) [row number],
			Invoice.[CustomerId],Invoice.[InvoiceDate]
			from Invoice
		)
	select *
	from cte_1 
	where [row number]=1
GO

Create view V_TopCountriesByRevenue			--مجموع درآمد از هر کشور، مرتب از بیشترین به کمترین
AS
	select Invoice.BillingCountry,sum(Invoice.Total) AS[TotalRevenue]
	from Invoice
	group by Invoice.BillingCountry
GO
----------------------------------------------------------------------------------------------------------------------
 --Stored Procedures

 Create PROCEDURE Usp_GetCustomerInvoices	--تمام فاکتورهای یک مشتری خاص بر اساس CustomerId را نمایش می‌دهد
 @CustomerId INT
 AS
 begin
	select InvoiceId,InvoiceDate,BillingCountry,Total
	from Invoice
	where CustomerId=@CustomerId
 end
 GO
 exec Usp_GetCustomerInvoices 2
 GO

Create PROCEDURE Usp_GetInvoicesByDateRange	    --تمام فاکتورهای ثبت شده بین یک بازه تاریخی خاص را لیست می‌کند													
@StartDate DATETIME,							-- کاربردی برای گزارش‌های مالی ماهانه یا سالانه
@EndDate DATETIME									
AS
begin
	select *
	from Invoice
	where InvoiceDate between @StartDate and @EndDate
end
GO
exec Usp_GetInvoicesByDateRange '2022-01-01','2024-01-01'
GO

Create PROCEDURE Usp_GetTopSellingTracks	--پرفروش‌ترین ترک‌های موسیقی بر اساس تعداد فروش را نمایش می‌دهد
AS											--رای مارکتینگ یا تحلیل فروش بسیار مناسب
begin
	select InvoiceLine.TrackId,Track.[Name],sum(InvoiceLine.Quantity)
	from Track inner join InvoiceLine
	on Track.TrackId=InvoiceLine.TrackId
	group by InvoiceLine.TrackId,Track.[Name]
	order by sum(InvoiceLine.Quantity) desc
end
GO
exec Usp_GetTopSellingTracks
GO

Create PROCEDURE Usp_GetCustomerPurchaseSummary	 --جمع کل خرید هر مشتری به همراه تعداد فاکتورهایی که ثبت کرده است.
AS												--برای تحلیل ارزش هر مشتری عالی است
begin
	select Invoice.CustomerId,Customer.FirstName + ' ' + Customer.LastName AS [ustomerName],
	sum(Invoice.Total),count(Invoice.InvoiceId)
	from Customer inner join Invoice
    on Customer.CustomerId=Invoice.CustomerId
    group by Invoice.CustomerId,Customer.FirstName,Customer.LastName
end
GO
exec Usp_GetCustomerPurchaseSummary
GO

Create PROCEDURE Usp_InsertNewInvoiceWithLines	--یک فاکتور جدید همراه با چند InvoiceLine در قالب یک تراکنش ثبت می‌کند
    @CustomerId INT,							--برای جلوگیری از داده ناقص در دیتابیس
    @BillingAddress NVARCHAR(100),
    @BillingCity NVARCHAR(50),
    @BillingCountry NVARCHAR(50),
    @Total DECIMAL(10,2),
    @Track1Id INT,
    @Track2Id INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		declare @A int= (select InvoiceId from Invoice where InvoiceId >= all(select InvoiceId from Invoice))
        INSERT INTO Invoice (InvoiceId,CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingCountry, Total)
        VALUES ((@A+1),@CustomerId, GETDATE(), @BillingAddress, @BillingCity, @BillingCountry, @Total);

        --DECLARE @InvoiceId INT = SCOPE_IDENTITY();
		declare @B int=(select InvoiceLineId from InvoiceLine where InvoiceLineId >= all(select InvoiceLineId from InvoiceLine))
        INSERT INTO InvoiceLine (InvoiceLineId,InvoiceId, TrackId, UnitPrice, Quantity)
        VALUES 
            (@B+1,(@A+1), @Track1Id, (SELECT UnitPrice FROM Track WHERE TrackId = @Track1Id), 1),
            (@B+2,(@A+1), @Track2Id, (SELECT UnitPrice FROM Track WHERE TrackId = @Track2Id), 1);

		declare @c numeric(10,2) =(select sum(Quantity*UnitPrice) from InvoiceLine where InvoiceId=(@A+1) group by InvoiceId);
		update Invoice
		set Total=@c
		where InvoiceId=(@A+1);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
exec Usp_InsertNewInvoiceWithLines 59,'2 Microsoft Way','New York','USA',1.98,1,2
exec Usp_InsertNewInvoiceWithLines 59,'2 Microsoft Way','New York','USA',0,7,2
exec Usp_InsertNewInvoiceWithLines 40,'2 Microsoft Way','New York','USA',0,12,6
GO

Create PROCEDURE Usp_CreateInvoiceWithTracks --ثبت سفارش جدید به همراه چندین ترک و محاسبه مجموع مبلغ فاکتور
@CustomerId int ,
@BillingAddress nvarchar(70),
@BillingCity nvarchar(40),
@BillingCountry nvarchar(40),
@TrackId1 int,
@TrackId2 int,
@TrackId1Qty int,
@TrackId2Qty int
AS
begin
	begin tran
		begin try
			declare @A int= (select InvoiceId from Invoice where InvoiceId >= all(select InvoiceId from Invoice))
			insert into Invoice([InvoiceId],[CustomerId],
								[InvoiceDate],[BillingAddress],
								[BillingCity],[BillingCountry],[Total])
			Values((@A+1),@CustomerId,GETDATE(),@BillingAddress,@BillingCity,@BillingCountry,0)
			print('Invoice insertion confirmation')
			declare @B int=(select InvoiceLineId from InvoiceLine where InvoiceLineId >= all(select InvoiceLineId from InvoiceLine))
			insert into InvoiceLine([InvoiceLineId],[InvoiceId],[TrackId],[UnitPrice],[Quantity])
			Values((@B+1),(@A+1),@TrackId1,(select UnitPrice from Track where TrackId=@TrackId1),@TrackId1Qty),
				  ((@B+2),(@A+1),@TrackId2,(select UnitPrice from Track where TrackId=@TrackId2),@TrackId2Qty)
			print('Invoiceline insertion confirmation')
			update Invoice
			set Total= (select sum(UnitPrice*Quantity) from InvoiceLine where InvoiceId=(@A+1))
			where InvoiceId=(@A+1)
			print('Update confirmation')
			commit tran
		end try
		begin catch
			ROLLBACK TRANSACTION
			THROW
		end catch
end
GO
exec Usp_CreateInvoiceWithTracks 50,'2 Microsoft Way','New York','USA',7,4,5,3;
GO

Create PROCEDURE Usp_GetInvoicesReport --گزارش‌گیری داینامیک بر اساس تاریخ شروع و پایان با قابلیت فیلتر کشور
@Startdate datetime,
@Enddate datetime,
@Country nvarchar(20)
AS
Begin
	select *
	from Invoice
	where InvoiceDate between @Startdate and @Enddate and BillingCountry=@Country
end
GO
exec Usp_GetInvoicesReport '2023-01-01','2024-01-01','USA';
GO

Create PROCEDURE Usp_SafeDeleteCustomer	  --حذف مشتری، ولی فقط در صورتی که هیچ فاکتوری براش ثبت نشده باشه
@CustomerId int							  --حذف امن مشتری
AS
begin
	if exists (select 1 from Invoice where CustomerId=@CustomerId) 
		begin	
			RAISERROR('This customer has invoices and cannot be deleted.', 16, 1)
			return
		end
	else delete from Customer where CustomerId=@CustomerId
end
GO
exec Usp_SafeDeleteCustomer 58;
GO

Create PROCEDURE Usp_CheckSalesAndNotify --فروش بالای یک حد مشخص را چک کن، اگر فروش بیشتر بود، سیستم ایمیل ارسال کند 
    @MinSales DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalSales DECIMAL(10,2);
    SELECT @TotalSales = SUM(Total) FROM Invoice;

    IF @TotalSales <= @MinSales
        PRINT(N' فروش عالی بود، به مدیر اطلاع داده شد!')
    ELSE
        PRINT (N'فروش هنوز به حد انتظار نرسیده است.')
END
GO
exec Usp_CheckSalesAndNotify 2341.15
GO

Create PROCEDURE Usp_UpdateTrackPrices --یک درصد خاص از افزایش قیمت روی همه ترک‌ها اعمال کن
@IncreasePercent DECIMAL(5,2)
AS
begin
	UPDATE Track
    SET UnitPrice = UnitPrice + (UnitPrice * @IncreasePercent / 100);
end
-----------------------------------------------------------------------------------------------------------------------
----User Defined Functions

Create function Svf_GetFullCustomerName(@CustomerId INT)
returns nvarchar(100)	--این تابع، بر اساس CustomerId، نام و نام خانوادگی مشتری رو در قالب یک رشته کامل برمی‌گردونه
AS
begin
	declare @FullName nvarchar(100)
	select @FullName=FirstName + ' ' + LastName 
	from Customer
	where CustomerId = @CustomerId
	return @FullName
end
GO
select dbo.Svf_GetFullCustomerName(35);
GO

CREATE FUNCTION Svf_CalculateDiscountAmount	-- محاسبه‌ی مقدار مبلغ تخفیف بر اساس درصد و مبلغ اولیه
(											--مناسب برای نمایش یا محاسبه قیمت نهایی در گزارش‌های فروش و تخفیف‌ها
    @Amount DECIMAL(10,2),
    @DiscountPercent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Amount - (@Amount * @DiscountPercent / 100)
END
GO
select dbo.Svf_CalculateDiscountAmount(100,15.00);
GO

CREATE FUNCTION Svf_GetInvoiceTotalByCustomer (@CustomerId INT)
RETURNS DECIMAL(18,2)						--مجموع کل مبلغ فاکتورهای یک مشتری خاص را محاسبه می‌کند
AS
BEGIN
    DECLARE @Total DECIMAL(18,2)
    SELECT @Total = ISNULL(SUM(Total), 0)
    FROM Invoice
    WHERE CustomerId = @CustomerId
    RETURN @Total
END
GO
select dbo.Svf_GetInvoiceTotalByCustomer(3)
GO

CREATE FUNCTION Svf_GetTrackDurationInMinutes (@Milliseconds INT)  --تبدیل زمان ترک از میلی‌ثانیه به دقیقه
RETURNS DECIMAL(10,2)					
AS
BEGIN
    RETURN CAST(@Milliseconds AS DECIMAL(10,2)) / 60000
END
GO
select dbo.Svf_GetTrackDurationInMinutes((select Milliseconds from Track where TrackId=3)) 
GO

CREATE FUNCTION Svf_GetCountrySalesCount (@Country NVARCHAR(50)) --تعداد فاکتورهای ثبت شده در یک کشور خاص را برمی‌گرداند
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    SELECT @Count = COUNT(*)
    FROM Invoice
    WHERE BillingCountry = @Country
    RETURN @Count
END
GO
select dbo.Svf_GetCountrySalesCount('USA')
GO

CREATE FUNCTION Tvf_GetInvoicesByCountry  -- این تابع تمام فاکتورهایی که از یک کشور خاص ثبت شده‌اند را برمی‌گرداند
(
    @Country NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT InvoiceId, CustomerId, InvoiceDate, BillingCity, Total
    FROM Invoice
    WHERE BillingCountry = @Country
)
GO
select *
from dbo.Tvf_GetInvoicesByCountry('USA')
GO

CREATE FUNCTION Tvf_GetCustomerInvoices  --این تابع همه فاکتورهای یک مشتری خاص را برمی‌گرداند
(
    @CustomerId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT InvoiceId, InvoiceDate, Total
    FROM Invoice
    WHERE CustomerId = @CustomerId
)
GO
select *
from dbo.Tvf_GetCustomerInvoices(2)
GO

CREATE FUNCTION Tvf_GetTracksByGenre --بر اساس GenreId، لیست تمام ترک‌های آن ژانر را برمی‌گرداند
(
    @GenreId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TrackId, Name, AlbumId, UnitPrice
    FROM Track
    WHERE GenreId = @GenreId
)
GO
select *
from dbo.Tvf_GetTracksByGenre(2)
GO

Create FUNCTION Tvf_GetTopSellingTracks  --ترک‌هایی که تعداد فروش‌شان بیشتر از یک عدد مشخص است را برمی‌گرداند
(
    @MinQuantity INT
)
RETURNS TABLE
AS
RETURN
(
	select Track.TrackId,Track.[Name],sum(InvoiceLine.Quantity) AS TotalSold
	from Track inner join InvoiceLine
	on Track.TrackId=InvoiceLine.TrackId
	group by InvoiceLine.TrackId,Track.TrackId,Track.[Name]
	having sum(InvoiceLine.Quantity)>=@MinQuantity
)
GO
select *
from dbo.Tvf_GetTopSellingTracks(3)
GO

CREATE FUNCTION Tvf_GetCustomerPurchaseHistory --سابقه‌ی خرید هر مشتری شامل تاریخ فاکتور و مبلغ را برمی‌گرداند
(
    @CustomerId INT
)
RETURNS TABLE
AS
RETURN
(
	select Invoice.InvoiceDate,Invoice.Total,InvoiceLine.TrackId,Track.[Name]
	from Invoice inner join InvoiceLine
	on Invoice.InvoiceId=InvoiceLine.InvoiceId inner join Track
	on InvoiceLine.TrackId=Track.TrackId
	where Invoice.CustomerId=@CustomerId
)
GO
select *
from dbo.Tvf_GetCustomerPurchaseHistory(46)
GO
------------------------------------------------------------------------------------------------------------------------
----Triggers
Create Table LogTable(
	LogId int primary key identity(1,1),
	TableName varchar(100),
	CmdType nvarchar(100),            --Insert , Delete, Update(Insert,Delete)
	KeyId int,						  -- شماره رکورد تغییر شده
	RegisterDate datetime2,
	FieldValue nvarchar(100)          -- نام ستون تغییر شده
)
GO
create trigger Trg_AI_InvoiceLog		--ثبت لاگ هنگام ایجاد فاکتور جدید
on invoice								--هر بار که یک Invoice جدید ثبت شد، اطلاعات فاکتور به جدول InvoiceLog اضافه شود.
after insert
AS
BEGIN
	declare @InvoiceID int
	select @InvoiceID= inserted.InvoiceId
	from inserted
	insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','Insert',@InvoiceID,GETDATE(),null)
	Print('Insertion done')
END
GO
Insert into Invoice(InvoiceId,CustomerId,InvoiceDate,Total)
			values (430,59,GETDATE(),0)
GO
select * 
from LogTable
GO

CREATE TRIGGER Trg_ID_PreventDeleteMainCustomer --محافظت از رکوردهای حساس در جدول Customer
ON Customer						--جلوگیری از حذف مشتری با CustomerId = 1 (فرض کن مشتری اصلی سیستم باشه).
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DELETED WHERE CustomerId = 1)
    BEGIN
        Print('Special people cannot be deleted.')
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Customer WHERE CustomerId IN (SELECT CustomerId FROM DELETED)
    END
END
GO

CREATE TRIGGER Trg_AU_EnforceMinimumTrackPrice --کنترل خودکار قیمت ترک‌ها
ON Track				--هر وقت قیمت یک ترک از Track تغییر کند و از 0.99 کمتر شود، اتوماتیک به 0.99 برگردد.
AFTER UPDATE
AS
BEGIN
	UPDATE Track
    SET UnitPrice = 0.99
	from Track inner join inserted
	on Track.UnitPrice=inserted.UnitPrice
	where inserted.UnitPrice<0.99
END
GO

CREATE TRIGGER Trg_AD_DeleteInvoiceLines  --حذف خودکار InvoiceLine هنگام حذف Invoice
ON InvoiceLine
AFTER DELETE
AS
BEGIN
    DELETE FROM Invoice
    WHERE InvoiceId IN (SELECT InvoiceId FROM DELETED);
END;
delete 
from InvoiceLine
where InvoiceId=429
GO

CREATE TABLE TrackPriceHistory (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    TrackId INT,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
)
GO
CREATE TRIGGER Trg_AU_TrackPriceAudit  --ثبت تاریخ تغییرات قیمت ترک‌ها
ON Track				--هر زمان قیمت ترک تغییر کند، تغییرات در جدول TrackPriceHistory ذخیره شود
AFTER UPDATE
AS
BEGIN
	insert into TrackPriceHistory(TrackId,OldPrice,NewPrice)
	select inserted.TrackId,DELETED.UnitPrice,inserted.UnitPrice
	from inserted inner join DELETED
	on inserted.TrackId=DELETED.TrackId
	where inserted.UnitPrice <> DELETED.UnitPrice

	--declare @TrackId int
	--declare @OldPrice DECIMAL(10,2)
	--declare @NewPrice DECIMAL(10,2)

	--select @TrackId=inserted.TrackId,@OldPrice=DELETED.UnitPrice,@NewPrice=inserted.UnitPrice
	--from inserted inner join DELETED
	--on inserted.TrackId=DELETED.TrackId
	--where inserted.UnitPrice <> DELETED.UnitPrice

	--insert into TrackPriceHistory(TrackId,OldPrice,NewPrice)
	--values (@TrackId,@OldPrice,@NewPrice)
END
GO

Create trigger Trg_AIDU_InvoiceAuditLog
ON invoice	--این تریگر هر وقت یک رکورد در جدول مهمی (مثلاً Invoice) اضافه، حذف یا تغییر بشه، جزئیاتش رو توی جدول AuditLog ذخیره می‌کنه
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON
	IF EXISTS (select 1 from inserted) AND EXISTS (select 1 from deleted)
		BEGIN
			declare @InvoiceID int
			select @InvoiceID=inserted.InvoiceId from inserted
			insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','UPDATE',@InvoiceID,GETDATE(),NULL)
		END
	ELSE IF EXISTS (select 1 from inserted)
		BEGIN
			declare @InvoiceID1 int
			select @InvoiceID1=inserted.InvoiceId from inserted
			insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','INSERT',@InvoiceID1,GETDATE(),NULL)
		END
	ELSE
		BEGIN	
			declare @InvoiceID2 int
			select @InvoiceID2=deleted.InvoiceId from deleted
			insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','DELETE',@InvoiceID2,GETDATE(),NULL)
		END
END
GO

CREATE TRIGGER Trg_AI_PreventDuplicateInvoice
ON Invoice				--گر برای یک مشتری با تاریخ یکسان فاکتور ثبت بشه، تریگر مانع این کار میشه
AFTER INSERT
AS
BEGIN
	IF EXISTS (
		select inserted.CustomerId,inserted.InvoiceDate
		from inserted inner join Invoice
		on inserted.CustomerId=Invoice.CustomerId AND
		DATEDIFF(DAY,inserted.InvoiceDate,Invoice.InvoiceDate)=0 AND
		inserted.InvoiceId <> Invoice.InvoiceId
					)
		BEGIN
			print('It is not allowed for a customer to register two invoices on a given date.')
			ROLLBACK TRAN
		END
END
GO
---------------------------------------------------------------------------------------------------------------------
