CREATE TABLE [dbo].[tblInventoryAdjustment]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[productID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[physical] [int] NULL,
[adjustment] [int] NULL,
[ordered] [int] NULL,
[adjDate] [datetime] NULL,
[adjUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjNote] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblInventoryAdjustment] ADD CONSTRAINT [PK_tblInventoryAdjustment] PRIMARY KEY CLUSTERED  ([pkid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_adjDate_INC_productID_adjustment] ON [dbo].[tblInventoryAdjustment] ([adjDate]) INCLUDE ([productID], [adjustment]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_adj] ON [dbo].[tblInventoryAdjustment] ([adjustment]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productID] ON [dbo].[tblInventoryAdjustment] ([productID]) ON [PRIMARY]
GO
CREATE TRIGGER [dbo].[trg_popInv] on [dbo].[tblInventoryAdjustment]
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	--Make sure table doesn't exist first (in case of FAIL during tempINV last time it ran in this proc.)
	IF OBJECT_ID(N'tempINV', N'U') IS NOT NULL 
	DROP TABLE tempINV

	CREATE TABLE tempINV (
	 RowID int IDENTITY(1, 1), 
	 productID int
	)
	DECLARE @NumberRecords int, @RowCount int
	DECLARE @productID int

	-- Insert the resultset we want to loop through
	-- into the temporary table
	INSERT INTO tempINV (productID)
	SELECT i.productID
	FROM inserted i

	-- Get the number of records in the temporary table
	SET @NumberRecords = @@ROWCOUNT
	SET @RowCount = 1

	-- loop through all records in the temporary table
	-- using the WHILE loop construct
	WHILE @RowCount <= @NumberRecords
	BEGIN
		 SELECT @productID = productID
		 FROM tempINV
		 WHERE RowID = @RowCount

		EXEC usp_popInv @productID
		-- insert into tempJF_popInv_test102413 (productID, testWord) select  @productID, 'test' (this tests proper functionality of multi-insert situations

		SET @RowCount = @RowCount + 1
	END

	-- drop the temporary table
	IF OBJECT_ID(N'tempINV', N'U') IS NOT NULL 
	DROP TABLE tempINV
END