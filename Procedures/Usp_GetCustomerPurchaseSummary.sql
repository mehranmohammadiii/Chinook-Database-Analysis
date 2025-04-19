Create PROCEDURE Usp_GetCustomerPurchaseSummary
AS
begin
	select Invoice.CustomerId,Customer.FirstName + ' ' + Customer.LastName AS [ustomerName],
	  sum(Invoice.Total),count(Invoice.InvoiceId)
from Customer inner join Invoice
on Customer.CustomerId=Invoice.CustomerId
group by Invoice.CustomerId,Customer.FirstName,Customer.LastName
end
GO
exec Usp_GetCustomerPurchaseSummary
GO