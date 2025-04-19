Create function Svf_GetFullCustomerName(@CustomerId INT)
returns nvarchar(100)
AS
begin
	declare @FullName nvarchar(100)
	select @FullName=FirstName + ' ' + LastName 
	from Customer
	where CustomerId = @CustomerId
	return @FullName
end
GO
select dbo.Svf_GetFullCustomerName(35)
GO