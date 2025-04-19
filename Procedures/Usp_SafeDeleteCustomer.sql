Create PROCEDURE Usp_SafeDeleteCustomer
@CustomerId int
AS
begin
	if exists (select 1 from Invoice where CustomerId=@CustomerId) 
		begin	
			RAISERROR('This customer has invoices and cannot be deleted.', 16, 1)
			return
		end
	else delete from Customer where CustomerId=@CustomerId
end
GO
exec Usp_SafeDeleteCustomer 58
GO