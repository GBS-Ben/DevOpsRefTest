CREATE TABLE [dbo].[tblUPSLabel]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[shipperName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperAttentionName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperStreet] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperState] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperPostalCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperCountry] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipperPhone] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoFullName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoAttention] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoCompany] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoStreet] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoStreet2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoCity] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoState] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoPostalCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoCountry] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shiptoPhone] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipDescription] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upsServiceCode] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[packageWeight] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unitOfMeasure] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[packageTypeCode] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labelGenerated] [bit] NOT NULL CONSTRAINT [DF_tblUPSLabel_labelGenerated] DEFAULT ((0)),
[errorReceived] [bit] NOT NULL CONSTRAINT [DF_tblUPSLabel_errorReceived] DEFAULT ((0)),
[errorValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insertDate] [datetime] NOT NULL CONSTRAINT [DF_tblUPSLabel_insertDate] DEFAULT (getdate()),
[billingWeight] [numeric] (7, 2) NULL,
[transactionCharge] [numeric] (7, 2) NULL,
[negotiatedCharge] [numeric] (7, 2) NULL,
[totalCharge] [numeric] (7, 2) NULL,
[trackingNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labelPath] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]