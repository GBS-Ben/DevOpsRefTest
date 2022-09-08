CREATE TABLE [dbo].[tblPaymentMethods]
(
[paymentMethodID] [int] NOT NULL IDENTITY(1, 1),
[checkoutTypeID] [int] NULL,
[online] [bit] NOT NULL,
[paymentMethodName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shortDescription] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receiptDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isCC] [bit] NOT NULL,
[isSC] [bit] NOT NULL,
[isDefault] [bit] NOT NULL,
[acceptedCards] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPaymentMethods] ADD CONSTRAINT [PK_tblPaymentMethods] PRIMARY KEY CLUSTERED  ([paymentMethodID]) WITH (FILLFACTOR=90) ON [PRIMARY]