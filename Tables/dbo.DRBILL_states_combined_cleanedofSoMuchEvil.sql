CREATE TABLE [dbo].[DRBILL_states_combined_cleanedofSoMuchEvil]
(
[id] [int] NOT NULL,
[Email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Full_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Middle_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Address1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Address2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_County] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Fax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cell_Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[License_Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[License_Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Original_Issue_Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Expiration_Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Association] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isCustomer] [bit] NULL CONSTRAINT [DF_DRBILL_states_combined_cleanedofSoMuchEvil_customer] DEFAULT ((0)),
[isCordialMRK] [bit] NULL CONSTRAINT [DF_DRBILL_states_combined_cleanedofSoMuchEvil_isCordial] DEFAULT ((0)),
[isCordialInvalid] [bit] NULL CONSTRAINT [DF_DRBILL_states_combined_cleanedofSoMuchEvil_isCordialInvalid] DEFAULT ((0)),
[isCordialUnsubHOM] [bit] NULL CONSTRAINT [DF_DRBILL_states_combined_cleanedofSoMuchEvil_isCordialUnsubHOM] DEFAULT ((0)),
[isCordialValidAndSubscribed] [bit] NULL CONSTRAINT [DF_DRBILL_states_combined_cleanedofSoMuchEvil_isCordialValidAndSubscribed] DEFAULT ((0)),
[company_short_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sourceList] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Industry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GBSCompanyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DRBILL_states_combined_cleanedofSoMuchEvil] ADD CONSTRAINT [PK_DRBILL_states_combined_cleanedofSoMuchEvil] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210921-151856] ON [dbo].[DRBILL_states_combined_cleanedofSoMuchEvil] ([Email]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_OFFICENAME] ON [dbo].[DRBILL_states_combined_cleanedofSoMuchEvil] ([Office_Name]) ON [PRIMARY]