Create PROC [dbo].[insertPhoenixImpositions] @xmlData xml
	,@GBSOrderNo NVARCHAR(MAX)
	,@phoenixCreateDate NVARCHAR(Max) NULL
	,@phoenixID NVARCHAR(Max) NULL
	,@name NVARCHAR(Max) NULL
	,@runLength NVARCHAR(Max) NULL
	,@notes NVARCHAR(Max) NULL
	,@phone NVARCHAR(Max) NULL
	,@contact NVARCHAR(Max) NULL
	,@client NVARCHAR(Max) NULL
	,@defaultBleed NVARCHAR(Max) NULL
	,@dieCost NVARCHAR(Max) NULL
	,@layoutCount NVARCHAR(Max) NULL
	,@overrun NVARCHAR(Max) NULL
	,@plateCost NVARCHAR(Max) NULL
	,@pressCost NVARCHAR(Max) NULL
	,@pressMinutes NVARCHAR(Max) NULL
	,@sheetUsage NVARCHAR(Max) NULL
	,@stockCost NVARCHAR(Max) NULL
	,@totalCost NVARCHAR(Max) NULL
	,@underrun NVARCHAR(Max) NULL
	,@units NVARCHAR(Max) NULL
	,@waste NVARCHAR(Max) NULL
AS
BEGIN
	DECLARE @ImpositionGUID UNIQUEIDENTIFIER
	SET @ImpositionGUID = newid()

	INSERT INTO tblPhoenixImpositions (
		[xmlData]
		,[ImpositionGUID]
		,[phoenixCreateDate]
		,[phoenixID]
		,[name]
		,[runLength]
		,[notes]
		,[phone]
		,[contact]
		,[client]
		,[defaultBleed]
		,[dieCost]
		,[layoutCount]
		,[overrun]
		,[plateCost]
		,[pressCost]
		,[pressMinutes]
		,[sheetUsage]
		,[stockCost]
		,[totalCost]
		,[underrun]
		,[units]
		,[waste]
		)
	SELECT convert(xml,@xmlData)
		,@ImpositionGUID
		,@phoenixCreateDate
		,@phoenixID
		,@name
		,@runLength
		,@notes
		,@phone
		,@contact
		,@client
		,@defaultBleed
		,@dieCost
		,@layoutCount
		,@overrun
		,@plateCost
		,@pressCost
		,@pressMinutes
		,@sheetUsage
		,@stockCost
		,@totalCost
		,@underrun
		,@units
		,@waste

	SELECT @ImpositionGUID AS ImpositionGUID





END