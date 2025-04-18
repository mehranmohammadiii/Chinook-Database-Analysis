Create view V_TopCountriesByRevenue
AS
	select Invoice.BillingCountry,sum(Invoice.Total) AS[TotalRevenue]
	from Invoice
	group by Invoice.BillingCountry