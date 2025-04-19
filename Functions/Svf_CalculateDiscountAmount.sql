CREATE FUNCTION Svf_CalculateDiscountAmount
(
    @Amount DECIMAL(10,2),
    @DiscountPercent DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @Amount - (@Amount * @DiscountPercent / 100)
END
GO
select dbo.Svf_CalculateDiscountAmount(100,15.00)
GO