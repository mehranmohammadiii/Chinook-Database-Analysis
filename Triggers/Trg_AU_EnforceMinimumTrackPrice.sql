CREATE TRIGGER Trg_AU_EnforceMinimumTrackPrice
ON Track
AFTER UPDATE
AS
BEGIN
	UPDATE Track
    SET UnitPrice = 0.99
	from Track inner join inserted
	on Track.UnitPrice=inserted.UnitPrice
	where inserted.UnitPrice<0.99
END
GO