CREATE TABLE [dbo].[tempJF_jdiv]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [int] NOT NULL,
[customerID] [int] NULL,
[billing_postCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_postCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID_Email] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[URL2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[spaceBefore] [bit] NOT NULL CONSTRAINT [DF_tempJF_jdiv_spaceBefore] DEFAULT ((0)),
[spaceAfter] [bit] NOT NULL CONSTRAINT [DF_tempJF_jdiv_spaceAfter] DEFAULT ((0)),
[colonBefore] [bit] NOT NULL CONSTRAINT [DF_tempJF_jdiv_colonBefore] DEFAULT ((0)),
[colonAfter] [bit] NOT NULL CONSTRAINT [DF_tempJF_jdiv_colonAfter] DEFAULT ((0)),
[newEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CleanFront] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CleanBack] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wasCleaned] [bit] NOT NULL CONSTRAINT [DF_tempJF_jdiv_isClean] DEFAULT ((0))
) ON [PRIMARY]