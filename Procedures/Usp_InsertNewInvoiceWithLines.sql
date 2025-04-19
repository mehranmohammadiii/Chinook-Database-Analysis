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