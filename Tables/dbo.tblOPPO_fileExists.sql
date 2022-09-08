CREATE TABLE [dbo].[tblOPPO_fileExists] (
    [rowID]              INT             IDENTITY (1, 1) NOT NULL,
    [PKID]               INT             NOT NULL,
    [OPID]               INT             NOT NULL,
    [textValue]          NVARCHAR (4000) NULL,
    [extension]          NCHAR (3)       NULL,
    [fileExists]         BIT             CONSTRAINT [DF_tblOPPO_fileExists_fileExists] DEFAULT ((0)) NOT NULL,
    [fileChecked]        BIT             CONSTRAINT [DF_tblOPPO_fileExists_fileChecked] DEFAULT ((0)) NOT NULL,
    [fileCheckedOn]      DATETIME2 (7)   NULL,
    [ignoreCheck]        BIT             CONSTRAINT [DF_tblOPPO_fileExists_ignoreCheck] DEFAULT ((0)) NOT NULL,
    [overrideCheck]      BIT             CONSTRAINT [DF_tblOPPO_fileExists_override] DEFAULT ((0)) NOT NULL,
    [filePath]           NVARCHAR (MAX)  NULL,
    [isFlattened]        BIT             CONSTRAINT [DF_tblOPPO_fileExists_isFlattened] DEFAULT ((0)) NOT NULL,
    [fileFlattenedOn]    DATETIME2 (7)   NULL,
    [isCustomInsert]     BIT             CONSTRAINT [DF_tblOPPO_fileExists_isCustomInsert] DEFAULT ((0)) NOT NULL,
    [fileType]           NCHAR (10)      NULL,
    [zeroBytes]          BIT             CONSTRAINT [DF_tblOPPO_fileExists_zeroBytes] DEFAULT ((1)) NOT NULL,
    [zeroBytesCheckedOn] DATETIME2 (7)   NULL,
    [readyForSwitch]     BIT             CONSTRAINT [DF_tblOPPO_fileExists_readyForSwitch] DEFAULT ((0)) NOT NULL,
    [readyForSwitchDate] DATETIME2 (7)   NULL,
    [CreateDate]         DATETIME2 (7)   DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tblOPPO_fileExists] PRIMARY KEY CLUSTERED ([rowID] ASC)
);


GO

GO
CREATE NONCLUSTERED INDEX [NCI_ignoreCheck] ON [dbo].[tblOPPO_fileExists] ([ignoreCheck]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_OPID] ON [dbo].[tblOPPO_fileExists] ([OPID]) INCLUDE ([filePath]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NCI_PKID] ON [dbo].[tblOPPO_fileExists] ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_readyForSwitch] ON [dbo].[tblOPPO_fileExists] ([readyForSwitch]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>] ON [dbo].[tblOPPO_fileExists] ([readyForSwitch]) INCLUDE ([OPID]) ON [PRIMARY]