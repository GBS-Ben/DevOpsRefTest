CREATE TABLE [dbo].[tempAC_log]
(
[Title] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKID] [decimal] (18, 0) NOT NULL,
[pUnitID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ordersProductsID] [decimal] (18, 0) NOT NULL,
[dataVersion] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logDate] [datetime] NULL,
[orderNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sortOrder] [decimal] (18, 0) NULL,
[resubmit] [bit] NULL,
[expressProduction] [bit] NULL,
[productCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[productQuantity] [decimal] (18, 0) NULL,
[packetValue] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variableWholeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backName] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipsWith] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayCount] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]