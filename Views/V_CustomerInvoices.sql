Create view	V_CustomerInvoices
AS
	select Customer.FirstName + ' ' + Customer.LastName AS[FullName],
	Customer.City,Invoice.Total,Invoice.InvoiceDate
	from Customer inner join Invoice
	on Customer.CustomerId=Invoice.CustomerId