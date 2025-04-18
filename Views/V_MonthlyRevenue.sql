Create view V_MonthlyRevenue
AS
	select year(InvoiceDate) AS[InvoiceYear],
	month(InvoiceDate) AS [InvoiceMonth],
	sum (Total) AS[MonthlyTotal]
	from Invoice
	group by year(InvoiceDate),month(InvoiceDate)