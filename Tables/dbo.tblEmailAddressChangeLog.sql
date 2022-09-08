CREATE TABLE [dbo].[tblEmailAddressChangeLog] (
    [Id]                         INT           IDENTITY (1, 1) NOT NULL,
    [SourceCustomerEmail]        VARCHAR (255) NULL,
    [DestinationCustomerEmail]   VARCHAR (255) NULL,
    [createdate]                 DATETIME2 (7) DEFAULT (getdate()) NULL,
    [NOPSourceCustomerId]        INT           NULL,
    [NOPDestinationCustomerId]   INT           NULL,
    [LocalSourceCustomerId]      INT           NULL,
    [LocalDestinationCustomerId] INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
