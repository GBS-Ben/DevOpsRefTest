﻿CREATE TABLE [dbo].[tbl_UPSQuantumViewCapture]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[Subscriber ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscription Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscription Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Query Begin Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Query End Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subscription File Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[File Status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Record Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Address Line 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Address Line 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Address Line 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper State/Province] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Postal Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Attention] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Address Line 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Address Line 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Address Line 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To State/Province] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Postal Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ship To Location ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipment Reference Number Type 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipment Reference Number Value 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipment Reference Number Type 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipment Reference Number Value 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS Service] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pickup Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scheduled Delivery Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Scheduled Delivery Time] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Document Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Activity Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Activity Time] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Count] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Dimensions Unit of Measurement] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Length] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Width] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Height] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Dimensional Weight] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Weight] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Oversize Package Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tracking Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Type 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Value 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Type 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Value 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Type 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Value 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Type 4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Value 4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Type 5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Package Reference Number Value 5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COD Currency Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COD Amount Due] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Declared Value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Earliest Delivery Time] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hazardous Materials Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hold For Pickup] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Saturday Delivery Indicator] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Call Tag ARS Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manufacture Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Harmonized Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customs Monetary Value] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Special Instructions] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipment Charge Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bill Ship To] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Collect Bill] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS Location] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS Location State/Province] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPS Location Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Street Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Street Prefix] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Street Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Street Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Street Suffix] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Building Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Room/Suite/Floor] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Political Division 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To State/Province] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Updated Ship To Postal Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception Status Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception Reason Description] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception Resolution Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception Resolution Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rescheduled Delivery Date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rescheduled Delivery Time] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver Release] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Location] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Prefix] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Street Suffix] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Building Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Room/Suite/Floor] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Political Division 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery State/Province] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery Postal Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Residential Address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Signed For By] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COD Collected Currency Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COD Amount Collected] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COD Amount Decimal] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bill To Account Number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bill Option] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception Reason Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exception Status Code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Receiving Address Name"] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Activity Type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_UPSQuantumViewCapture] ADD CONSTRAINT [PK_tbl_UPSQuantumViewCapture] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_PRNV1] ON [dbo].[tbl_UPSQuantumViewCapture] ([Package Reference Number Value 1]) INCLUDE ([Ship To Attention], [Ship To Phone], [Ship To Name], [Ship To Address Line 1], [Ship To Address Line 2], [Ship To City], [Ship To State/Province], [Ship To Postal Code], [Scheduled Delivery Date], [Package Count], [Package Weight], [Tracking Number], [Package Reference Number Value 3]) ON [PRIMARY]