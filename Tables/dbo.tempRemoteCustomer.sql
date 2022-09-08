﻿CREATE TABLE [dbo].[tempRemoteCustomer]
(
[Id] [int] NOT NULL,
[CustomerGuid] [uniqueidentifier] NOT NULL,
[Username] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdminComment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsTaxExempt] [bit] NOT NULL,
[AffiliateId] [int] NOT NULL,
[VendorId] [int] NOT NULL,
[HasShoppingCartItems] [bit] NOT NULL,
[Active] [bit] NOT NULL,
[Deleted] [bit] NOT NULL,
[IsSystemAccount] [bit] NOT NULL,
[SystemName] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastIpAddress] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOnUtc] [datetime] NOT NULL,
[LastLoginDateUtc] [datetime] NULL,
[LastActivityDateUtc] [datetime] NOT NULL,
[BillingAddress_Id] [int] NULL,
[ShippingAddress_Id] [int] NULL,
[RequireReLogin] [bit] NOT NULL,
[EmailToRevalidate] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FailedLoginAttempts] [int] NOT NULL,
[CannotLoginUntilDateUtc] [datetime] NULL,
[RegisteredInStoreId] [int] NOT NULL
) ON [PRIMARY]