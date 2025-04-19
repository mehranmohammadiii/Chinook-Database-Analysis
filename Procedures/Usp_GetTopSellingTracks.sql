Create PROCEDURE Usp_GetTopSellingTracks
AS
begin
	select InvoiceLine.TrackId,Track.[Name],sum(InvoiceLine.Quantity)
	from Track inner join InvoiceLine
	on Track.TrackId=InvoiceLine.TrackId
	group by InvoiceLine.TrackId,Track.[Name]
	order by sum(InvoiceLine.Quantity) desc
end
GO
exec Usp_GetTopSellingTracks
GO