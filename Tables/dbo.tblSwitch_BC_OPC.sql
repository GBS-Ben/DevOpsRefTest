CREATE TABLE [dbo].[tblSwitch_BC_OPC] (
    [ordersProductsID]     INT            NOT NULL,
    [orderID]              INT            NULL,
    [orderNo]              NVARCHAR (50)  NULL,
    [fileName_front]       NVARCHAR (255) NULL,
    [fileName_back]        NVARCHAR (255) NULL,
    [presentedToSwitch]    BIT            CONSTRAINT [DF_tblSwitch_BC_OPC_presentedToSwitch] DEFAULT ((0)) NULL,
    [presentedToSwitch_on] DATETIME       NULL,
    [created_on]           DATETIME       CONSTRAINT [DF_tblSwitch_BC_OPC_created_on] DEFAULT (getdate()) NOT NULL,
    [modified_on]          DATETIME       CONSTRAINT [DF_tblSwitch_BC_OPC_modified_on] DEFAULT (getdate()) NULL,
    [customDataSynced]     BIT            CONSTRAINT [DF_tblSwitch_BC_OPC_dataSynced] DEFAULT ((0)) NULL,
    [isPrepped]            BIT            CONSTRAINT [DF_tblSwitch_BC_OPC_isPrepped] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSwitch_BC_OPC] PRIMARY KEY CLUSTERED ([ordersProductsID] ASC)
);


GO

GO
CREATE NONCLUSTERED INDEX [NCI_presentedToSwitch_on] ON [dbo].[tblSwitch_BC_OPC] ([presentedToSwitch_on]) ON [PRIMARY]
GO
CREATE TRIGGER trg_update_tblSwitch_BC_OPC on tblSwitch_BC_OPC
FOR UPDATE AS            
BEGIN
    UPDATE tblSwitch_BC_OPC
    SET modified_on=GETDATE()
    FROM tblSwitch_BC_OPC INNER JOIN deleted d
    ON tblSwitch_BC_OPC.ordersProductsID = d.ordersProductsID

END