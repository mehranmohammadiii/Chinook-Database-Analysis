CREATE TRIGGER Trg_ID_PreventDeleteMainCustomer
ON Customer
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM DELETED WHERE CustomerId = 1)
    BEGIN
        Print('Special people cannot be deleted.')
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Customer WHERE CustomerId IN (SELECT CustomerId FROM DELETED)
    END
END
GO