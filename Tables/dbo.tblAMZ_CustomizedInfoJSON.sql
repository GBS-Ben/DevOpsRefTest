CREATE TABLE [dbo].[tblAMZ_CustomizedInfoJSON] (
    [id]                      INT            IDENTITY (1, 1) NOT NULL,
    [order-item-id]           NVARCHAR (255) NULL,
    [BuyerCustomizedInfoJSON] NVARCHAR (MAX) NULL,
    [CreatedOn]               DATETIME2 (7)  DEFAULT (getdate()) NULL
);

