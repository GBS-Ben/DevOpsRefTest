CREATE TABLE [dbo].[ScanShip] (
    [Unique_Identifier]   NVARCHAR (50)  NOT NULL,
    [Customer_ID]         NVARCHAR (50)  NULL,
    [Company]             NVARCHAR (255) NULL,
    [Address_1]           NVARCHAR (255) NULL,
    [Address_2]           NVARCHAR (255) NULL,
    [City]                NVARCHAR (255) NULL,
    [State]               NVARCHAR (255) NULL,
    [Zip]                 NVARCHAR (255) NULL,
    [Country]             NVARCHAR (255) NOT NULL,
    [Phone]               NVARCHAR (50)  NULL,
    [Service]             NVARCHAR (50)  NOT NULL,
    [Billing_Option]      NVARCHAR (50)  NOT NULL,
    [Attention]           NVARCHAR (255) NULL,
    [Email]               NVARCHAR (255) NULL,
    [noti_flag]           NVARCHAR (50)  NOT NULL,
    [From_Company]        NVARCHAR (255) NOT NULL,
    [From_Address]        NVARCHAR (255) NOT NULL,
    [From_City]           NVARCHAR (50)  NOT NULL,
    [From_State]          NVARCHAR (50)  NOT NULL,
    [From_Zip]            NVARCHAR (50)  NOT NULL,
    [From_Phone]          NVARCHAR (50)  NOT NULL,
    [From_Fax]            NVARCHAR (50)  NOT NULL,
    [From_Country]        NVARCHAR (50)  NOT NULL,
    [SpecialInstructions] NVARCHAR (255) NULL,
    [fStoreID]            INT            NULL,
    [fCompany]            NVARCHAR (255) NULL,
    [fAddress1]           NVARCHAR (255) NULL,
    [fCity]               NVARCHAR (50)  NULL,
    [fState]              NVARCHAR (50)  NULL,
    [fZip]                NVARCHAR (50)  NULL,
    [fTollFree]           NVARCHAR (50)  NULL,
    [fFax]                NVARCHAR (50)  NULL,
    [fCSZ]                NVARCHAR (50)  NULL,
    [totalBadgeWeight]    INT            NULL,
    [orderNo]             NVARCHAR (15)  NULL,
    [Shipped]             BIT            CONSTRAINT [DF_WorldShip_markedAsShipped] DEFAULT ((0)) NOT NULL,
    [modified_on]         DATETIME       CONSTRAINT [DF_ScanShip_modified_on] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_WorldShip] PRIMARY KEY CLUSTERED ([Unique_Identifier] ASC)
);


GO

GO
CREATE NONCLUSTERED INDEX [NCI_orderNo] ON [dbo].[ScanShip] ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ScanShip_Shipped] ON [dbo].[ScanShip] ([Shipped]) INCLUDE ([Customer_ID], [orderNo]) ON [PRIMARY]
GO
CREATE TRIGGER [dbo].[trg_UpdateScanShip] on ScanShip 
FOR UPDATE 
AS            
UPDATE a
SET modified_on = GETDATE()
FROM ScanShip a INNER JOIN deleted d
ON a.Unique_Identifier = d.Unique_Identifier