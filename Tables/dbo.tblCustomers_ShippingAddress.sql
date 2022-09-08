CREATE TABLE [dbo].[tblCustomers_ShippingAddress] (
    [ShippingAddressID]        INT           IDENTITY (1, 1) NOT NULL,
    [ShippingAddressID_Remote] INT           NULL,
    [CustomerID]               INT           NULL,
    [Shipping_NickName]        VARCHAR (50)  NULL,
    [Shipping_Company]         VARCHAR (100) NULL,
    [Shipping_FirstName]       VARCHAR (100) NULL,
    [Shipping_Surname]         VARCHAR (100) NULL,
    [Shipping_Street]          VARCHAR (100) NULL,
    [Shipping_Street2]         VARCHAR (100) NULL,
    [Shipping_Suburb]          VARCHAR (50)  NULL,
    [Shipping_State]           VARCHAR (50)  NULL,
    [Shipping_PostCode]        VARCHAR (15)  NULL,
    [Shipping_Country]         VARCHAR (50)  NULL,
    [Shipping_Phone]           VARCHAR (50)  NULL,
    [Shipping_FullName]        VARCHAR (100) NULL,
    [Primary_Address]          BIT           CONSTRAINT [DF_tblCustomers_ShippingAddress_Primary_Address] DEFAULT ((0)) NOT NULL,
    [Address_Type]             BIT           CONSTRAINT [DF_tblCustomers_ShippingAddress_Address_Type] DEFAULT ((1)) NOT NULL,
    [orderNo]                  NVARCHAR (50) NULL,
    [szip_trim]                CHAR (3)      NULL,
    [created_on]               DATETIME      CONSTRAINT [DF__tblCustom__creat__07461BD5] DEFAULT (getdate()) NULL,
    [modified_on]              DATETIME      CONSTRAINT [DF__tblCustom__modif__083A400E] DEFAULT (getdate()) NULL,
    [isValidated]              BIT           CONSTRAINT [DF_tblCustomers_ShippingAddress_isValidated] DEFAULT ((0)) NULL,
    [rdi]                      CHAR (1)      NULL,
    [returnCode]               VARCHAR (50)  NULL,
    [addrExists]               BIT           NULL,
    [UPSRural]                 BIT           NULL,
    CONSTRAINT [PK_tblCustomers_ShippingAddress] PRIMARY KEY CLUSTERED ([ShippingAddressID] ASC) WITH (FILLFACTOR = 90)
);


GO

GO
CREATE NONCLUSTERED INDEX [tblCustomers_ShippingAddress_Address_Type] ON [dbo].[tblCustomers_ShippingAddress] ([Address_Type]) INCLUDE ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_ShippingAddress] ON [dbo].[tblCustomers_ShippingAddress] ([CustomerID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_ShippingAddress_3] ON [dbo].[tblCustomers_ShippingAddress] ([CustomerID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_ShippingAddress_isValidated_returnCode] ON [dbo].[tblCustomers_ShippingAddress] ([isValidated], [returnCode]) INCLUDE ([ShippingAddressID], [ShippingAddressID_Remote], [CustomerID], [Shipping_NickName], [Shipping_Company], [Shipping_FirstName], [Shipping_Surname], [Shipping_Street], [Shipping_Street2], [Shipping_Suburb], [Shipping_State], [Shipping_PostCode], [Shipping_Country], [Shipping_Phone], [Shipping_FullName], [Primary_Address], [Address_Type], [orderNo], [szip_trim], [created_on], [modified_on], [rdi], [addrExists], [UPSRural]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_ShippingAddress_1] ON [dbo].[tblCustomers_ShippingAddress] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderNo] ON [dbo].[tblCustomers_ShippingAddress] ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rdi] ON [dbo].[tblCustomers_ShippingAddress] ([rdi]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_returnCode] ON [dbo].[tblCustomers_ShippingAddress] ([returnCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_shipping_Company] ON [dbo].[tblCustomers_ShippingAddress] ([Shipping_Company]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [1q2] ON [dbo].[tblCustomers_ShippingAddress] ([Shipping_PostCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_ShippingAddress_2] ON [dbo].[tblCustomers_ShippingAddress] ([ShippingAddressID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ShippingAddressID_Remote] ON [dbo].[tblCustomers_ShippingAddress] ([ShippingAddressID_Remote]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ff] ON [dbo].[tblCustomers_ShippingAddress] ([szip_trim]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPSRural] ON [dbo].[tblCustomers_ShippingAddress] ([UPSRural]) ON [PRIMARY]
GO
CREATE TRIGGER trg_update_tblCustomers_shippingAddress on dbo.tblCustomers_ShippingAddress 
FOR UPDATE AS            
BEGIN
    UPDATE tblCustomers_shippingAddress
    SET modified_on=getDate()
    FROM tblCustomers_shippingAddress INNER JOIN deleted d
    ON tblCustomers_shippingAddress.[ShippingAddressID] = d.[ShippingAddressID]

END