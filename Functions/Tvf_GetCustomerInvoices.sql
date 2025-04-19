CREATE FUNCTION Tvf_GetCustomerInvoices
(
    @CustomerId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT InvoiceId, InvoiceDate, Total
    FROM Invoice
    WHERE CustomerId = @CustomerId
)
GO
select *
from dbo.Tvf_GetCustomerInvoices(2)
GO