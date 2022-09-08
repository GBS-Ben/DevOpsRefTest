CREATE  PROCEDURE [dbo].[PayLater_LoadRemotePayLater]
AS
/*
-------------------------------------------------------------------------------
Author      Bobby 
Created     06/25/20
Purpose     Process Pay Laters
-------------------------------------------------------------------------------
Modification History

09/04/20	BJS Loads Remote Pay Later Table
12/28/20	CKB, Modified to use PaymentRequestID for unique records
-------------------------------------------------------------------------------*/
BEGIN

		
	INSERT NopCommerce_tblPayLater ( OrderId	,OrderNo	,OrderDate	,PaymentAmountRequired	,CustomerId	,CardType	,CardNumberLast4	,AuthorizationTransactionId	,AuthorizationTransactionCode	,AuthorizationTransactionResult,	PaidDateUtc	,CreatedOnUtc, PaymentRequestID, ActiveFlag) 
	SELECT p.OrderId,
		p.OrderNo,
		p.OrderDate,
		p.PaymentAmountRequired,
		p.CustomerId,
		p.CardType,
		p.CardNumberLast4,
		p.AuthorizationTransactionId,
		p.AuthorizationTransactionCode,
		p.AuthorizationTransactionResult,	
		p.PaidDateUtc,
		GETDATE(),
		p.PaymentRequestID,
		p.ActiveFlag
	FROM  tblPaylater p
	LEFT JOIN NopCommerce_tblPayLater gp ON gp.PaymentRequestID = p.PaymentRequestID
	WHERE gp.PaymentRequestID IS NULL

	UPDATE tpl set activeflag = 0
	FROM NopCommerce_tblPayLater tpl
	INNER JOIN tblPaylater p ON tpl.PaymentRequestID = p.PaymentRequestID
	WHERE tpl.ActiveFlag = 1 and p.ActiveFlag = 0

END