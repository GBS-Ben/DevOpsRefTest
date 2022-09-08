﻿CREATE TABLE [dbo].[tblAuth]
(
[Date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResponseCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthorizationCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressVerificationStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubmitDateTime] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpirationDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalAmount] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Method] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActionCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerFirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerLastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToFirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToLastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToCompany] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToZIP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipToCountry] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L2Tax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L2Duty] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L2Freight] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L2TaxExempt] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[L2PurchaseOrderNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RoutingNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BankAccountNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]