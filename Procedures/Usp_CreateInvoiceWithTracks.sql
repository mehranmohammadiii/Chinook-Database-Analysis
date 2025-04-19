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