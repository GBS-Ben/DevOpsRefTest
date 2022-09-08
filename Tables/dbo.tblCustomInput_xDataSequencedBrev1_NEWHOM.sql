CREATE TABLE [dbo].[tblCustomInput_xDataSequencedBrev1_NEWHOM]
(
[pkid] [int] NULL,
[orderdetailid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[giveyour] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yourname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yourcompany] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input6] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[photo1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[photo2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bkgnd] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profsymbol1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profsymbol2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[profsymbol3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enterdate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input7] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[input8] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[marketCenterName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[projectDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csz] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[yourName2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[streetAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ixx] ON [dbo].[tblCustomInput_xDataSequencedBrev1_NEWHOM] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]