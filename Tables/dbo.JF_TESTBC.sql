CREATE TABLE [dbo].[JF_TESTBC]
(
[testField] [bit] NOT NULL CONSTRAINT [DF_JF_TESTBC_testField] DEFAULT ((0)),
[testDate] [datetime] NULL
) ON [PRIMARY]