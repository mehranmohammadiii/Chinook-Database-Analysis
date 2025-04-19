Create PROCEDURE Usp_UpdateTrackPrices
@IncreasePercent DECIMAL(5,2)
AS
begin
	UPDATE Track
    SET UnitPrice = UnitPrice + (UnitPrice * @IncreasePercent / 100);
end