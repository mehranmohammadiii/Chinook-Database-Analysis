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