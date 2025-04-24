select *
from Artist
---------
select *
from Album
---------
select *
from Track
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
from Invoice
---------
select *
from InvoiceLine
---------
select *
from Customer
---------
select *
from Employee
GO
----------------------------------------------------------------------------------------------------------------------
--view

Create view	V_CustomerInvoices
AS
	select Customer.FirstName + ' ' + Customer.LastName AS[FullName],
	Customer.City,Invoice.Total,Invoice.InvoiceDate
	from Customer inner join Invoice
	on Customer.CustomerId=Invoice.CustomerId
GO

Create view V_InvoiceDetails
AS
	select Customer.FirstName + ' ' + Customer.LastName AS[FullName],
		   Invoice.InvoiceId,
		   Track.TrackId,
		   Invoiceline.UnitPrice,
		   Invoiceline.Quantity,
		   (Invoiceline.UnitPrice*Invoiceline.Quantity) AS [Line Total]
	from Invoice inner join InvoiceLine
	on Invoice.InvoiceId=InvoiceLine.InvoiceId inner join Track
	on InvoiceLine.TrackId=Track.TrackId inner join Customer
	on Customer.CustomerId=Invoice.InvoiceId
GO

Create view V_MonthlyRevenue
AS
	select year(InvoiceDate) AS[InvoiceYear],
	month(InvoiceDate) AS [InvoiceMonth],
	sum (Total) AS[MonthlyTotal]
	from Invoice
	group by year(InvoiceDate),month(InvoiceDate)
GO

Create view V_TopSellingTracks
AS
	select InvoiceLine.TrackId,Track.[Name],count(InvoiceLine.TrackId) AS[TotalSold]
	from Customer inner join Invoice
	on Customer.CustomerId=Invoice.CustomerId inner join InvoiceLine
	on Invoice.InvoiceId=InvoiceLine.InvoiceId inner join Track
	on InvoiceLine.TrackId=Track.TrackId
	group by InvoiceLine.TrackId,Track.[Name]
	having count(InvoiceLine.TrackId)>=2
GO

Create view V_ArtistAlbumCount
AS

	select Artist.[Name],Album.Title
	from Artist inner join Album
	on Artist.ArtistId=Album.ArtistId
GO

Create view V_CustomerCountryCount
AS
	select Country,count(Country) AS[CustomerCount] 
	from Customer
	group by Country 
GO

Create view V_EmployeeCustomers
AS
	select Employee.FirstName + ' ' + Employee.LastName AS[FullName],
		   Customer.CustomerId
	from Employee inner join Customer
	on Employee.EmployeeId=Customer.SupportRepId
GO

Create view V_GenreTrackCount
AS
	select Track.GenreId,Genre.[Name],count(Track.TrackId) AS[TrackCount]
	from Track inner join Genre
	on Track.GenreId=Genre.GenreId
	group by Track.GenreId,Genre.[Name]
GO

Create view V_AlbumTrackList
AS
	select Track.AlbumId,Track.TrackId,Artist.[Name],Track.Milliseconds / 60000 AS [TrackDurationMinutes]
	from Album inner join Track
	on Album.AlbumId=Track.AlbumId inner join Artist
	on Album.ArtistId=Artist.ArtistId
	group by Track.AlbumId,Track.TrackId,Track.Milliseconds,Artist.[Name]
GO

Create view V_CustomerLastInvoice
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

Create view V_TopCountriesByRevenue
AS
	select Invoice.BillingCountry,sum(Invoice.Total) AS[TotalRevenue]
	from Invoice
	group by Invoice.BillingCountry
GO
----------------------------------------------------------------------------------------------------------------------
 --Stored Procedures

 Create PROCEDURE Usp_GetCustomerInvoices
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

Create PROCEDURE Usp_GetInvoicesByDateRange
@StartDate DATETIME,
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

Create PROCEDURE Usp_GetTopSellingTracks
AS
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

Create PROCEDURE Usp_GetCustomerPurchaseSummary
AS
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

Create PROCEDURE Usp_InsertNewInvoiceWithLines
    @CustomerId INT,
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

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
exec Usp_InsertNewInvoiceWithLines 59,'2 Microsoft Way','New York','USA',1.98,1,2
GO

Create PROCEDURE Usp_CreateInvoiceWithTracks
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
exec Usp_CreateInvoiceWithTracks 36,'2 Microsoft Way','New York','USA',7,4,1,2
GO

Create PROCEDURE Usp_SafeDeleteCustomer
@CustomerId int
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
exec Usp_SafeDeleteCustomer 58
GO

Create PROCEDURE Usp_CheckSalesAndNotify
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

Create PROCEDURE Usp_UpdateTrackPrices
@IncreasePercent DECIMAL(5,2)
AS
begin
	UPDATE Track
    SET UnitPrice = UnitPrice + (UnitPrice * @IncreasePercent / 100);
end
---------------------------------------------------------------------------------------------------------------------
--User Defined Functions

Create function Svf_GetFullCustomerName(@CustomerId INT)
returns nvarchar(100)
AS
begin
	declare @FullName nvarchar(100)
	select @FullName=FirstName + ' ' + LastName 
	from Customer
	where CustomerId = @CustomerId
	return @FullName
end
GO
select dbo.Svf_GetFullCustomerName(35)
GO

CREATE FUNCTION Svf_CalculateDiscountAmount
(
    @Amount DECIMAL(10,2),
    @DiscountPercent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Amount - (@Amount * @DiscountPercent / 100)
END
GO
select dbo.Svf_CalculateDiscountAmount(100,15.00)
GO

CREATE FUNCTION Svf_GetInvoiceTotalByCustomer (@CustomerId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2)
    SELECT @Total = ISNULL(SUM(Total), 0)
    FROM Invoice
    WHERE CustomerId = @CustomerId
    RETURN @Total
END
GO
select dbo.Svf_GetInvoiceTotalByCustomer(1)
GO

CREATE FUNCTION Svf_GetTrackDurationInMinutes (@Milliseconds INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN CAST(@Milliseconds AS DECIMAL(10,2)) / 60000
END
GO
select dbo.Svf_GetTrackDurationInMinutes((select Milliseconds from Track where TrackId=3)) 
GO

CREATE FUNCTION Svf_GetCountrySalesCount (@Country NVARCHAR(50))
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

CREATE FUNCTION Tvf_GetInvoicesByCountry
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

CREATE FUNCTION Tvf_GetCustomerInvoices
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

CREATE FUNCTION Tvf_GetTracksByGenre
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

Create FUNCTION Tvf_GetTopSellingTracks
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
from dbo.Tvf_GetTopSellingTracks(2)
GO

CREATE FUNCTION Tvf_GetCustomerPurchaseHistory
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
----------------------------------------------------------------------------------------------------------------------
--Triggers
Create Table LogTable(
	LogId int primary key identity(1,1),
	TableName varchar(100),
	CmdType nvarchar(100),            --Insert , Delete, Update(Insert,Delete)
	KeyId int,						  -- شماره رکورد تغییر شده
	RegisterDate datetime2,
	FieldValue nvarchar(100)          -- نام ستون تغییر شده
)
GO
create trigger Trg_AI_InvoiceLog
on invoice
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
			values (418,59,GETDATE(),5)
GO
select * 
from LogTable
GO

CREATE TRIGGER Trg_ID_PreventDeleteMainCustomer
ON Customer
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

CREATE TRIGGER Trg_AU_EnforceMinimumTrackPrice
ON Track
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

CREATE TABLE TrackPriceHistory (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    TrackId INT,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
)
GO
CREATE TRIGGER Trg_AU_TrackPriceAudit
ON Track
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
ON invoice
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
ON Invoice
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
