-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DisableIndexesForRestore]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if  @@ServerName = 'DEV-SQL01\INTRANET'
	begin

		ALTER INDEX [IX_tblCustomers] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_1] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_2] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_3] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_4] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_5] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_6] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_7] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_8] ON [dbo].[tblCustomers] DISABLE
		ALTER INDEX [IX_tblCustomers_BillingAddress_orderNo] ON [dbo].[tblCustomers_BillingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_BillingAddress_Billing_Phone] ON [dbo].[tblCustomers_BillingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_BillingAddress_CustomerID_Billing_Phone] ON [dbo].[tblCustomers_BillingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_ShippingAddress] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_ShippingAddress_1] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_ShippingAddress_2] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_ShippingAddress_3] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [1q2] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [ff] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_ShippingAddressID_Remote] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_shipping_Company] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_rdi] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_returnCode] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_UPSRural] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_tblCustomers_ShippingAddress_isValidated_returnCode] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [tblCustomers_ShippingAddress_Address_Type] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [NCI_orderNo] ON [dbo].[tblCustomers_ShippingAddress] DISABLE
		ALTER INDEX [IX_tblOrders.orderNo] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders.customerID] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_DATE] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders.orderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders.storeID] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_membershipType] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_orderType] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_a1] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_orderStatus_orderNO_paymentMethodID_Inc_orderID] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_OrderAck_archived_ordertype_orderstatus_tabstatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_orderType_inc_orderID_orderNo_created_on] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_orderstatus_orderdate_INC_rowupdate_shippingdesc] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_tabStatus_orderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_displayPaymentStatus_orderDate_orderStatus_INC_orderID_orderNO_customerID_createdon] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_orderStatus_Inc_orderID_orderNo_customerID_orderDate_orderTotal] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_shippingAddressID_INC_orderNo] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_orderStatus_tabStatus_INC_orderID_orderNo_lastStatusUpdate] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_orderWeight_com_res_aReg_bReg_INC_orderID_orderNo_orderDate_rowUpdate] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_archived_orderStatus_tabStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_orderAck_paymentProcessed_paymentSuccessful_archived_orderType_tabStatus_orderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblORders_Status] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_paymentSuccessful_archived_orderStatus_tabStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_a1_orderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_orderType] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_displayPaymentStatus_OrderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [NCI_NOP] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_Orders_NOP_OrderDate_Status] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_A1] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_ResCom_OrderNoRowUpdate] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_archived_orderStatus_inc_orderNo_customerID] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_orderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [IX_tblOrders_OrderDateOrderStatus] ON [dbo].[tblOrders] DISABLE
		ALTER INDEX [PK_tblOrders_Products_1] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [AB_IX] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_PC] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_FastTrack_Status] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_productID_deletex] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_deletex_INC_productID_modifiedon] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_FT_completed] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_modifiedon_INC_productID_deletex] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_Deletex_processtype_IncOrderID] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_switch_create] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_tblOrders_Products_deletex] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_deleteX] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_fasttrack_Inc_ID_productID] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_fastTrak_fastTrackProductType_fastTrackcompleted_INC_ID_orderID_fastTrackstatus] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_fastTrak_fastTrakCompleted_deletex_fastTrackstatus_INC_ID_orderID_fastTrakimprintName] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_fastTrak_fastTrackstatus_INC_ID_orderID_fastTrakstatuslastModified] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_processType_deletex_INC_ID_orderID] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_tblOrders_Products_productID_deletex] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_Order_Products_DeleteX] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [tblOrders_Products_groupID] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_processType] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_processType_INC_orderID_productCode] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_tblOrders_Products_deletex_FastTrakStatus] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_tblOrders_Products_GbsCompanyId] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_fastTrak_status_processType_INC_orderID_productID_productCode] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_deletex_INC_orderID_modified_on] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_ProductCode_INC_CreatedOn] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_fastTrak_completed_processType_INC_orderID_fastTrak_completedOn] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_OrdersProducts_fastTrak_FTCompleted_FTCompletedOn] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_OPIDGUID] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_created_processType_productCode] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [NCI_GBSCompanyID_INC_orderID_ID] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [IX_switchcreate_Processtype_deletex_INC_many] ON [dbo].[tblOrders_Products] DISABLE
		ALTER INDEX [PK_tblOrdersProducts_ProductOptions_1] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_OP] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_optionCaption_deletex_INC_ordersProductsID_textValue] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_OptionCaption_Deletex_IncOrdersProductsID] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_OptionID_IncludePKIDTextValue] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_tblOrdersProducts_ProductOptions_optionCaption_deletex] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [NCI_CreatedOn] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [NCI_deletex_inc_textValue_ordersProductsID] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [NCI_optionID_deletex_inc_ordersProductsID_textValue] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_tblOrdersProducts_ProductOptions_optionID_optionCaption_optionGroupCaption] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [<Name of Missing Index, sysname,>] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_OPPO_OrdersProductsID_Deletex_INC_optionCaption] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_tblOrdersProducts_ProductOptions_ODC] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_OPIDGUID] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_tblOrdersProducts_ProductOptions_deletex_created_on] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_OPPO_OrdersProductsID_Deletex_INC_optionCaption_textvalue] ON [dbo].[tblOrdersProducts_ProductOptions] DISABLE
		ALTER INDEX [IX_productID] ON [dbo].[tblProduct_ProductOptions] DISABLE
		ALTER INDEX [IX_PN] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_PC] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_productType] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_parentProductID] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_subContract] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_fasTrakProductType] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [NCI_fastTrack_productCode_INC_productID_fastTrackproductType] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [NCI_fastTrack_productCode_productType_INC_productID_fastTrackproductType] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [NCI_fastTrakproductType_shortName_INC_productID_productName] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [NCI_subcontract_INC_productID_productCode] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_productType_INC_productCode] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_productCode_INC_parentproductid_numunits] ON [dbo].[tblProducts] DISABLE
		ALTER INDEX [IX_tblTransactions_1] ON [dbo].[tblTransactions] DISABLE
		ALTER INDEX [IX_tblTransactions_2] ON [dbo].[tblTransactions] DISABLE
		ALTER INDEX [IX_tblTransactions_3] ON [dbo].[tblTransactions] DISABLE
		ALTER INDEX [IX_tblTransactions_4] ON [dbo].[tblTransactions] DISABLE
		ALTER INDEX [NonClusteredIndex-20150612-104720] ON [dbo].[tblTransactions] DISABLE
		ALTER INDEX [PK_tblTransactions] ON [dbo].[tblTransactions] DISABLE
		ALTER INDEX [IX_OI] ON [dbo].[tblVouchers] DISABLE
		ALTER INDEX [IX_OID] ON [dbo].[tblVouchersSalesUse] DISABLE
		ALTER INDEX [NCI_sVoucherCode] ON [dbo].[tblVouchersSalesUse] DISABLE
	end
END