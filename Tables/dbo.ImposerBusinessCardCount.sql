CREATE TABLE [dbo].[ImposerBusinessCardCount]
(
[CardSides] [decimal] (18, 0) NOT NULL CONSTRAINT [DF_ImposerBusinessCardCount_BC_COUNT] DEFAULT ((0)),
[Impressions] [decimal] (18, 0) NULL,
[RunTime] [decimal] (18, 1) NULL
) ON [PRIMARY]