CREATE TABLE [dbo].[tblProduction_Time]
(
[PKID] [bigint] NOT NULL IDENTITY(1, 1),
[SignTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__SignT__38D43615] DEFAULT ((0)),
[ApparelTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__Appar__39C85A4E] DEFAULT ((0)),
[AwardsTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__Award__3ABC7E87] DEFAULT ((0)),
[NBTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__NBTim__3BB0A2C0] DEFAULT ((0)),
[BCTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__BCTim__3CA4C6F9] DEFAULT ((0)),
[BBTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__BBTim__3D98EB32] DEFAULT ((0)),
[FBTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__FBTim__3E8D0F6B] DEFAULT ((0)),
[CALTime] [int] NOT NULL CONSTRAINT [DF__tblProduc__CALTi__3F8133A4] DEFAULT ((0)),
[entryDate] [datetime] NOT NULL CONSTRAINT [DF__tblProduc__entry__407557DD] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProduction_Time] ADD CONSTRAINT [PK__tblProdu__5E028272478A5E5E] PRIMARY KEY CLUSTERED ([PKID]) ON [PRIMARY]
GO
