Create view V_GenreTrackCount
AS
	select Track.GenreId,Genre.[Name],count(Track.TrackId) AS[TrackCount]
	from Track inner join Genre
	on Track.GenreId=Genre.GenreId
	group by Track.GenreId,Genre.[Name]