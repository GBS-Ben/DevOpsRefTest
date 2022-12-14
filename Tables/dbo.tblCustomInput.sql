CREATE TABLE [dbo].[tblCustomInput]
(
[pkid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderdetailid] [int] NULL,
[ordernumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[giveyour] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yourname] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yourcompany] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input1] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input2] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input3] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input4] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input5] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input6] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bkgnd] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[photo1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[photo2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profsymbol1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profsymbol2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profsymbol3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changes] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[previousOrderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_slogan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_thanks] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_q1] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inserts_q2] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleteX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ixcustom1] ON [dbo].[tblCustomInput] ([orderdetailid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixcustomorderno] ON [dbo].[tblCustomInput] ([ordernumber]) WITH (FILLFACTOR=90) ON [PRIMARY]