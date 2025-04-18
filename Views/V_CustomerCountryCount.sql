Create view V_CustomerCountryCount
AS
	select Country,count(Country) AS[CustomerCount] 
	from Customer
	group by Country 

