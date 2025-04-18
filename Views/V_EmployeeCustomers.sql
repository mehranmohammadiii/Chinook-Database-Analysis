Create view V_EmployeeCustomers
AS
	select Employee.FirstName + ' ' + Employee.LastName AS[FullName],
		   Customer.CustomerId
	from Employee inner join Customer
	on Employee.EmployeeId=Customer.SupportRepId