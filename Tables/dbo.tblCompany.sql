CREATE TABLE [dbo].[tblCompany] (
    [Id]                      INT            NOT NULL,
    [Name]                    VARCHAR (500)  NOT NULL,
    [CompanyShortCode]        VARCHAR (10)   NULL,
    [GbsCompanyId]            VARCHAR (20)   NOT NULL,
    [ParentCompanyId]         INT            NULL,
    [LogoPath]                NVARCHAR (500) NULL,
    [AlternateLogoPath]       NVARCHAR (500) NULL,
    [NotApprovedSupplierText] NVARCHAR (MAX) NULL,
    [ShowOnHomePage]          BIT            DEFAULT ((0)) NOT NULL,
    [IncludeInMenu]           BIT            DEFAULT ((0)) NOT NULL,
    [Published]               BIT            DEFAULT ((1)) NOT NULL,
    [Deleted]                 BIT            DEFAULT ((0)) NOT NULL,
    [DisplayOrder]            INT            DEFAULT ((0)) NOT NULL,
    [CreatedOnUtc]            DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [UpdatedOnUtc]            DATETIME2 (7)  DEFAULT (getutcdate()) NOT NULL,
    [LastActivity]            DATETIME2 (7)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
