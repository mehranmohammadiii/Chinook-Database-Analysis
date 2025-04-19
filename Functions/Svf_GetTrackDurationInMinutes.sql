CREATE FUNCTION Svf_GetTrackDurationInMinutes (@Milliseconds INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN CAST(@Milliseconds AS DECIMAL(10,2)) / 60000
END
GO
select dbo.Svf_GetTrackDurationInMinutes((select Milliseconds from Track where TrackId=3)) 
GO