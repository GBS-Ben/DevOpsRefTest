CREATE TABLE [dbo].[tbljobtrack] (
    [trackingnumber]                VARCHAR (255) NOT NULL,
    [jobnumber]                     VARCHAR (255) NULL,
    [ups service]                   VARCHAR (255) NULL,
    [pickup date]                   VARCHAR (255) NULL,
    [scheduled delivery date]       VARCHAR (255) NULL,
    [package count]                 VARCHAR (255) NULL,
    [addtrack]                      VARCHAR (255) NULL,
    [Delivery Street Number]        VARCHAR (255) NULL,
    [Delivery Street Prefix]        VARCHAR (255) NULL,
    [Delivery Street Name]          VARCHAR (255) NULL,
    [Delivery Street Type]          VARCHAR (255) NULL,
    [Delivery Street Suffix]        VARCHAR (255) NULL,
    [Delivery Building Name]        VARCHAR (255) NULL,
    [Delivery Room/Suite/Floor]     VARCHAR (255) NULL,
    [Delivery City]                 VARCHAR (255) NULL,
    [Delivery State/Province]       VARCHAR (255) NULL,
    [Delivery Postal Code]          VARCHAR (255) NULL,
    [deliveredOn]                   VARCHAR (255) NULL,
    [location]                      VARCHAR (255) NULL,
    [signedForBy]                   VARCHAR (255) NULL,
    [addressType_DisplayOnIntranet] VARCHAR (255) NULL,
    [addressType]                   VARCHAR (255) NULL,
    [subscription file name]        VARCHAR (255) NULL,
    [trackSource]                   VARCHAR (255) NULL,
    [transactionID]                 VARCHAR (255) NULL,
    [transactionDate]               VARCHAR (255) NULL,
    [mailClass]                     VARCHAR (255) NULL,
    [postageAmount]                 VARCHAR (255) NULL,
    [postMarkDate]                  VARCHAR (255) NULL,
    [weight]                        VARCHAR (255) NULL,
    [PKID]                          INT           IDENTITY (1, 1) NOT NULL,
    [author]                        VARCHAR (255) NULL,
    [CreatedOn]                     DATETIME      DEFAULT (getdate()) NOT NULL,
    [UpdatedOn]                     DATETIME      DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tbljobtrack] PRIMARY KEY NONCLUSTERED ([PKID] ASC)
);


GO

GO
CREATE NONCLUSTERED INDEX [NCI_deliveredOn_INC_sevenColumns] ON [dbo].[tbljobtrack] ([deliveredOn]) INCLUDE ([trackingnumber], [jobnumber], [pickup date], [scheduled delivery date], [package count], [mailClass], [weight]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack_deliveredOntrackSource] ON [dbo].[tbljobtrack] ([deliveredOn], [trackSource]) INCLUDE ([trackingnumber], [jobnumber], [PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_jobnumber] ON [dbo].[tbljobtrack] ([jobnumber]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_PKID] ON [dbo].[tbljobtrack] ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack] ON [dbo].[tbljobtrack] ([trackingnumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack_trackingnumber_jobnumber] ON [dbo].[tbljobtrack] ([trackingnumber], [jobnumber]) INCLUDE ([ups service]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_TS] ON [dbo].[tbljobtrack] ([trackSource]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_trackSource_Inc_jobnumber] ON [dbo].[tbljobtrack] ([trackSource]) INCLUDE ([jobnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_trackSource_INC_jobnumber_author] ON [dbo].[tbljobtrack] ([trackSource]) INCLUDE ([jobnumber], [author]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack_trackSource_jobnumber] ON [dbo].[tbljobtrack] ([trackSource], [jobnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack_trackSource_transactionID] ON [dbo].[tbljobtrack] ([trackSource], [transactionID]) INCLUDE ([jobnumber], [transactionDate], [author]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_XID] ON [dbo].[tbljobtrack] ([transactionID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UPSERV] ON [dbo].[tbljobtrack] ([ups service]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack_servicemailclass] ON [dbo].[tbljobtrack] ([ups service], [mailClass]) INCLUDE ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbljobtrack_upsservice_trackingnumber_jobnumber] ON [dbo].[tbljobtrack] ([ups service], [trackingnumber], [jobnumber]) ON [PRIMARY]