CREATE TABLE [dbo].[tblShipping]
(
[trackingnumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[jobnumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ups service] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickup date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled delivery date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package count] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addtrack] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Number] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Prefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Suffix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Building Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Room/Suite/Floor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery State/Province] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Postal Code] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]