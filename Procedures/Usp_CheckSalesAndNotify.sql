Create PROCEDURE Usp_CheckSalesAndNotify
    @MinSales DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalSales DECIMAL(10,2);
    SELECT @TotalSales = SUM(Total) FROM Invoice;

    IF @TotalSales <= @MinSales
        PRINT(N' فروش عالی بود، به مدیر اطلاع داده شد!')
    ELSE
        PRINT (N'فروش هنوز به حد انتظار نرسیده است.')
END
GO
exec Usp_CheckSalesAndNotify 2341.15
GO