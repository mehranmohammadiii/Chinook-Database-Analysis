Create view V_ArtistAlbumCount
AS

	select Artist.[Name],Album.Title
	from Artist inner join Album
	on Artist.ArtistId=Album.ArtistId
