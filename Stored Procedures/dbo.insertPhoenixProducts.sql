create PROC [dbo].[insertPhoenixProducts] @impositionGUID UNIQUEIDENTIFIER
	,@LayoutGUID UNIQUEIDENTIFIER
	,@ordersProductsID nvarchar(max) NULL
	,@index NVARCHAR(max) NULL
	,@name NVARCHAR(max) NULL
	,@color NVARCHAR(max) NULL
	,@ordered NVARCHAR(max) NULL
	,@description NVARCHAR(max) NULL
	,@dieName NVARCHAR(max) NULL
	,@dieSource NVARCHAR(max) NULL
	,@diePath NVARCHAR(max) NULL
	,@stock NVARCHAR(max) NULL
	,@grade NVARCHAR(max) NULL
	,@grain NVARCHAR(max) NULL
	,@width NVARCHAR(max) NULL
	,@height NVARCHAR(max) NULL
	,@spacingType NVARCHAR(max) NULL
	,@priority NVARCHAR(max) NULL
	,@rotation NVARCHAR(max) NULL
	,@templates NVARCHAR(max) NULL
	,@placed NVARCHAR(max) NULL
	,@total NVARCHAR(max) NULL
	,@overrun NVARCHAR(max) NULL
	,@properties NVARCHAR(max) NULL
AS
BEGIN
Declare @productGUID uniqueidentifier
set @productGUID = NEWID()

	INSERT INTO [tblPhoenixProducts] (
		impositionGUID
		,LayoutGUID
		,productGUID
		,ordersProductsID
		,[index]
		,[name]
		,color
		,ordered
		,description
		,dieName
		,dieSource
		,diePath
		,stock
		,grade
		,grain
		,width
		,height
		,spacingType
		,priority
		,rotation
		,templates
		,placed
		,total
		,overrun
		,properties
		)
	SELECT @impositionGUID
		,@LayoutGUID
		,@productGUID
		,try_convert(int,@ordersProductsID)
		,@index
		,@name
		,@color
		,@ordered
		,@description
		,@dieName
		,@dieSource
		,@diePath
		,@stock
		,@grade
		,@grain
		,@width
		,@height
		,@spacingType
		,@priority
		,@rotation
		,@templates
		,@placed
		,@total
		,@overrun
		,@properties
END