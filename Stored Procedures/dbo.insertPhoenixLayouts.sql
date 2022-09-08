create PROC [dbo].[insertPhoenixLayouts]
@ImpositionGUID UNIQUEIDENTIFIER
	,@phoenixLayoutID NVARCHAR(Max) NULL
	,@layoutIndex NVARCHAR(Max) null
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

Declare @LayoutGUID UNIQUEIDENTIFIER
	SET @LayoutGUID = newid()


	INSERT INTO [tblPhoenixLayouts] (
		[ImpositionGUID]
		,[LayoutGUID]
		,[phoenixLayoutID]
		,[layoutIndex]
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
	SELECT 
		@ImpositionGUID
		,@LayoutGUID
		,@phoenixLayoutID
		,@layoutIndex
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

SELECT @layoutIndex as layoutIndex, @LayoutGUID as LayoutGUID
END