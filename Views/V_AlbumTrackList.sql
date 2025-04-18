Create view V_AlbumTrackList
AS
	select Track.AlbumId,Track.TrackId,Artist.[Name],Track.Milliseconds / 60000 AS [TrackDurationMinutes]
	from Album inner join Track
	on Album.AlbumId=Track.AlbumId inner join Artist
	on Album.ArtistId=Artist.ArtistId
	group by Track.AlbumId,Track.TrackId,Track.Milliseconds,Artist.[Name]