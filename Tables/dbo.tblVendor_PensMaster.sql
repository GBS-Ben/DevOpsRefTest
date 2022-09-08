CREATE TABLE [dbo].[tblVendor_PensMaster]
(
[productCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCemail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vProductCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vProductName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vPenColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vImprintColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vInkColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vPricePerPiece] [decimal] (6, 4) NULL
) ON [PRIMARY]