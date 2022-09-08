CREATE TABLE [dbo].[tblProofCenterQueue]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[QueueGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__tblProofC__Queue__7CD45AA7] DEFAULT (newid()),
[orderId] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ordersProductsId] [int] NOT NULL,
[sendProof] [bit] NOT NULL,
[proofFile] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created_On] [datetime] NULL CONSTRAINT [DF_tblProofCenterQueue_created_On] DEFAULT (getdate())
) ON [PRIMARY]