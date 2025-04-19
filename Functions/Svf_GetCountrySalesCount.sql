CREATE FUNCTION Svf_GetCountrySalesCount (@Country NVARCHAR(50))
RETURNS INT
AS
BEGIN
    DECLARE @Count INT
    SELECT @Count = COUNT(*)
    FROM Invoice
    WHERE BillingCountry = @Country
    RETURN @Count
END
GO
select dbo.Svf_GetCountrySalesCount('USA')
GO