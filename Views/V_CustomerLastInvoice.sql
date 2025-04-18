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