CREATE FUNCTION Svf_GetInvoiceTotalByCustomer (@CustomerId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2)
    SELECT @Total = ISNULL(SUM(Total), 0)
    FROM Invoice
    WHERE CustomerId = @CustomerId
    RETURN @Total
END
GO
select dbo.Svf_GetInvoiceTotalByCustomer(1)
GO