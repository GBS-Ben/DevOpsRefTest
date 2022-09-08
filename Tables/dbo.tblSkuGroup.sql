CREATE TABLE [dbo].[tblSkuGroup]
(
[skuPattern] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[skuGroup] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Include] [bit] NULL CONSTRAINT [DF_tblSkuGroup_Include] DEFAULT ((1))
) ON [PRIMARY]