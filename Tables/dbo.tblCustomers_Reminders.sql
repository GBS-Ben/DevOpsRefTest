CREATE TABLE [dbo].[tblCustomers_Reminders]
(
[reminderID] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[occasion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reminderDate] [datetime] NULL,
[reminderNotifyPeriod] [int] NULL,
[reminderName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reminderMSG] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomers_Reminders] ADD CONSTRAINT [PK_tblCustomers_Reminders] PRIMARY KEY CLUSTERED  ([reminderID]) WITH (FILLFACTOR=90) ON [PRIMARY]