CREATE FUNCTION Tvf_GetTracksByGenre
(
    @GenreId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TrackId, Name, AlbumId, UnitPrice
    FROM Track
    WHERE GenreId = @GenreId
)
GO
select *
from dbo.Tvf_GetTracksByGenre(2)
GO