CREATE proc [dbo].[usp_assign_CouponCode]
AS
SET NOCOUNT ON;

BEGIN TRY
	DECLARE @CouponNull int
	SET @CouponNull=(select count(*) from tblGroupOrders where couponNum=0 and couponSent='No')
	IF @CouponNull is null
		BEGIN
			SET @CouponNull=0
		END
	IF @CouponNull>0
		BEGIN
			DECLARE @HDA30 datetime,
				@CouponNum int
			DECLARE c_ExpireyPop CURSOR FOR 
			SELECT distinct uniqueID from tblGroupOrders where couponNum=0 and couponSent='No'
			OPEN c_ExpireyPop
			FETCH NEXT FROM c_ExpireyPop 
			INTO @HDA30
			WHILE @@FETCH_STATUS = 0
				BEGIN		
					SET @CouponNum=(select top 1 couponNum from tblCouponCodes where available='Yes' order by couponNum)
				
					UPDATE tblGroupOrders
					SET couponNum=@CouponNum, 
					status='Coupon Assigned',
					couponStatus='Active' 
					where uniqueID=@HDA30
		
					UPDATE tblCouponCodes
					SET available='No' 
					where couponNum=@CouponNum
		
					FETCH NEXT FROM c_ExpireyPop 
					INTO @HDA30
		
				END
				CLOSE c_ExpireyPop
				DEALLOCATE c_ExpireyPop
		END

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH