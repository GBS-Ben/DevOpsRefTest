CREATE TABLE [dbo].[tempJF_jdiv02]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [int] NOT NULL,
[customerID] [int] NULL,
[billing_postCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_postCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID_Email] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BCimageURL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL1] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[URL2] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[newEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleanFront] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleanBack] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wasCleaned] [bit] NOT NULL CONSTRAINT [DF_tempJF_jdiv02_wasCleaned] DEFAULT ((0))
) ON [PRIMARY]