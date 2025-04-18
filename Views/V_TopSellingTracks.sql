Create view V_TopSellingTracks
AS
	select InvoiceLine.TrackId,Track.[Name],count(InvoiceLine.TrackId) AS[TotalSold]
	from Customer inner join Invoice
	on Customer.CustomerId=Invoice.CustomerId inner join InvoiceLine
	on Invoice.InvoiceId=InvoiceLine.InvoiceId inner join Track
	on InvoiceLine.TrackId=Track.TrackId
	group by InvoiceLine.TrackId,Track.[Name]
	having count(InvoiceLine.TrackId)>=2