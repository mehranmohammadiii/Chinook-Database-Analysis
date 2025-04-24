Create Table LogTable(
	LogId int primary key identity(1,1),
	TableName varchar(100),
	CmdType nvarchar(100),            --Insert , Delete, Update(Insert,Delete)
	KeyId int,						  -- شماره رکورد تغییر شده
	RegisterDate datetime2,
	FieldValue nvarchar(100)          -- نام ستون تغییر شده
)
GO
create trigger Trg_AI_InvoiceLog
on invoice
after insert
AS
BEGIN
	declare @InvoiceID int
	select @InvoiceID= inserted.InvoiceId
	from inserted
	insert into LogTable (TableName,CmdType,KeyId,RegisterDate,FieldValue)
				values ('Invoice','Insert',@InvoiceID,GETDATE(),null)
	Print('Insertion done')
END
GO
Insert into Invoice(InvoiceId,CustomerId,InvoiceDate,Total)
			values (418,59,GETDATE(),5)
GO
select * 
from LogTable
GO