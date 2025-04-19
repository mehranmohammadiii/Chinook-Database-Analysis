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