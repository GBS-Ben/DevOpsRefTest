CREATE PROCEDURE [dbo].[VOUCHER_RunAll]
	AS

EXECUTE [dbo].[Voucher_BHHS_CALPROPS_Update]
EXECUTE [dbo].[Voucher_BHHS_EWM_Update]
EXECUTE [dbo].[Voucher_BHHS_Florida_Update]
EXECUTE [dbo].[Voucher_BHHS_Fox_Update]
EXECUTE [dbo].[Voucher_EXP_Update]
EXECUTE [dbo].[Voucher_FATHOM_Update]
EXECUTE [dbo].[Voucher_CressyEverett_Update]
EXECUTE [dbo].[Voucher_Redeemer_Update]
EXECUTE [dbo].[Voucher_BHHS_PRO_Update]