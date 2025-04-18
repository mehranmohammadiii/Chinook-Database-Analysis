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