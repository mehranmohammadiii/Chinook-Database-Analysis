CREATE TABLE TrackPriceHistory (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    TrackId INT,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangeDate DATETIME DEFAULT GETDATE()
)
GO
CREATE TRIGGER Trg_AU_TrackPriceAudit
ON Track
AFTER UPDATE
AS
BEGIN
	insert into TrackPriceHistory(TrackId,OldPrice,NewPrice)
	select inserted.TrackId,DELETED.UnitPrice,inserted.UnitPrice
	from inserted inner join DELETED
	on inserted.TrackId=DELETED.TrackId
	where inserted.UnitPrice <> DELETED.UnitPrice

	--declare @TrackId int
	--declare @OldPrice DECIMAL(10,2)
	--declare @NewPrice DECIMAL(10,2)

	--select @TrackId=inserted.TrackId,@OldPrice=DELETED.UnitPrice,@NewPrice=inserted.UnitPrice
	--from inserted inner join DELETED
	--on inserted.TrackId=DELETED.TrackId
	--where inserted.UnitPrice <> DELETED.UnitPrice

	--insert into TrackPriceHistory(TrackId,OldPrice,NewPrice)
	--values (@TrackId,@OldPrice,@NewPrice)
END
GO