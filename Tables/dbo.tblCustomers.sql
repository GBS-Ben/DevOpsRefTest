CREATE TABLE [dbo].[tblCustomers] (
    [customerID]       INT              IDENTITY (1, 1) NOT NULL,
    [firstName]        NVARCHAR (255)   NULL,
    [surname]          NVARCHAR (255)   NULL,
    [company]          NVARCHAR (255)   NULL,
    [street]           NVARCHAR (255)   NULL,
    [street2]          NVARCHAR (255)   NULL,
    [suburb]           NVARCHAR (255)   NULL,
    [postCode]         NVARCHAR (255)   NULL,
    [state]            NVARCHAR (255)   NULL,
    [country]          NVARCHAR (255)   NULL,
    [phone]            NVARCHAR (255)   NULL,
    [fax]              NVARCHAR (255)   NULL,
    [mobilePhone]      NVARCHAR (255)   NULL,
    [email]            NVARCHAR (255)   NULL,
    [website]          NVARCHAR (255)   NULL,
    [login]            NVARCHAR (255)   NULL,
    [customerPassword] NVARCHAR (255)   NULL,
    [newsletter]       BIT              CONSTRAINT [DF_tblCustomers_newsletter] DEFAULT ((0)) NULL,
    [dnc]              BIT              CONSTRAINT [DF_tblCustomers_dnc] DEFAULT ((0)) NULL,
    [po]               BIT              CONSTRAINT [DF_tblCustomers_po] DEFAULT ((0)) NOT NULL,
    [monthlyBill]      BIT              CONSTRAINT [DF_tblCustomers_monthlyBill] DEFAULT ((0)) NOT NULL,
    [membershipType]   INT              NULL,
    [membershipNo]     NVARCHAR (255)   NULL,
    [title]            VARCHAR (50)     NULL,
    [coordID]          VARCHAR (50)     NULL,
    [CID]              INT              NULL,
    [shipping]         VARCHAR (50)     NULL,
    [legit]            VARCHAR (50)     NULL,
    [beforeCutoff]     VARCHAR (50)     NULL,
    [sUserDefined]     VARCHAR (255)    NULL,
    [orderNoJF]        VARCHAR (50)     NULL,
    [typeJF]           VARCHAR (50)     NULL,
    [PSCID]            INT              NULL,
    [created_on]       DATETIME         CONSTRAINT [DF__tblCustom__creat__7DBCB19B] DEFAULT (getdate()) NULL,
    [modified_on]      DATETIME         CONSTRAINT [DF__tblCustom__modif__7EB0D5D4] DEFAULT (getdate()) NULL,
    [dusa]             BIT              NULL,
    [CustomerGuid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_tblCustomers] PRIMARY KEY CLUSTERED ([customerID] ASC) WITH (FILLFACTOR = 90)
);


GO

GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_2] ON [dbo].[tblCustomers] ([company]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_8] ON [dbo].[tblCustomers] ([email]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers] ON [dbo].[tblCustomers] ([firstName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_7] ON [dbo].[tblCustomers] ([phone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_5] ON [dbo].[tblCustomers] ([postCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_6] ON [dbo].[tblCustomers] ([state]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_3] ON [dbo].[tblCustomers] ([street]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_4] ON [dbo].[tblCustomers] ([suburb]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_1] ON [dbo].[tblCustomers] ([surname]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE TRIGGER trg_update_tblCustomers on dbo.tblCustomers 
FOR UPDATE AS            
BEGIN
    UPDATE tblCustomers
    SET modified_on=getDate()
    FROM tblCustomers INNER JOIN deleted d
    ON tblCustomers.[customerID] = d.[customerID]

END