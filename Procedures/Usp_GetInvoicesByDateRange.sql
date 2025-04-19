Create PROCEDURE Usp_GetInvoicesByDateRange
@StartDate DATETIME,
@EndDate DATETIME
AS
begin
	select *
	from Invoice
	where InvoiceDate between @StartDate and @EndDate
end
GO
exec Usp_GetInvoicesByDateRange '2022-01-01','2024-01-01'
GO