CREATE FUNCTION Tvf_GetInvoicesByCountry
(
    @Country NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
    SELECT InvoiceId, CustomerId, InvoiceDate, BillingCity, Total
    FROM Invoice
    WHERE BillingCountry = @Country
)
GO
select *
from dbo.Tvf_GetInvoicesByCountry('USA')
GO