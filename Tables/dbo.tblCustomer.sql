CREATE TABLE [dbo].[tblCustomer]
(
[customerID] [int] NOT NULL IDENTITY(1, 1),
[contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suffix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extraEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extraPhone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[designation] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccInfo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kh_three] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kh_six] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[co_ref] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[multiEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HOM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Planner] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewlyFound] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomer] ADD CONSTRAINT [IX_tblCustomer] UNIQUE NONCLUSTERED  ([customerID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomer_2] ON [dbo].[tblCustomer] ([contact]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblCustomer_1] ON [dbo].[tblCustomer] ([email]) WITH (FILLFACTOR=90) ON [PRIMARY]