CREATE TRIGGER Trg_AI_PreventDuplicateInvoice
ON Invoice
AFTER INSERT
AS
BEGIN
	IF EXISTS (
		select inserted.CustomerId,inserted.InvoiceDate
		from inserted inner join Invoice
		on inserted.CustomerId=Invoice.CustomerId AND
		DATEDIFF(DAY,inserted.InvoiceDate,Invoice.InvoiceDate)=0 AND
		inserted.InvoiceId <> Invoice.InvoiceId
					)
		BEGIN
			print('It is not allowed for a customer to register two invoices on a given date.')
			ROLLBACK TRAN
		END
END
GO