Create FUNCTION Tvf_GetTopSellingTracks
(
    @MinQuantity INT
)
RETURNS TABLE
AS
RETURN
(
	select Track.TrackId,Track.[Name],sum(InvoiceLine.Quantity) AS TotalSold
	from Track inner join InvoiceLine
	on Track.TrackId=InvoiceLine.TrackId
	group by InvoiceLine.TrackId,Track.TrackId,Track.[Name]
	having sum(InvoiceLine.Quantity)>=@MinQuantity
)
GO
select *
from dbo.Tvf_GetTopSellingTracks(2)
GO
