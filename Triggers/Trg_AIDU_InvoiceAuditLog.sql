Create trigger Trg_AIDU_InvoiceAuditLog
ON invoice
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON
	IF EXISTS (select 1 from inserted) AND EXISTS (select 1 from deleted)
		BEGIN
			declare @InvoiceID int
			select @InvoiceID=inserted.InvoiceId from inserted
			insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','UPDATE',@InvoiceID,GETDATE(),NULL)
		END
	ELSE IF EXISTS (select 1 from inserted)
		BEGIN
			declare @InvoiceID1 int
			select @InvoiceID1=inserted.InvoiceId from inserted
			insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','INSERT',@InvoiceID1,GETDATE(),NULL)
		END
	ELSE
		BEGIN	
			declare @InvoiceID2 int
			select @InvoiceID2=deleted.InvoiceId from deleted
			insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','DELETE',@InvoiceID2,GETDATE(),NULL)
		END
END
GO