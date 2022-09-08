CREATE TABLE [dbo].[tblOPIDProductionProcess] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [OPID]             INT           NOT NULL,
    [RunNumber]        INT           NOT NULL,
    [workflowID]       INT           NOT NULL,
    [stepNumber]       INT           NOT NULL,
    [processID]        INT           NOT NULL,
    [WPID]             INT           NOT NULL,
    [isCurrentProcess] BIT           CONSTRAINT [DF_tblOPIDProductionProcess_isCurrentProcess] DEFAULT ((0)) NOT NULL,
    [isActive]         BIT           CONSTRAINT [DF_tblOPIDProductionProcess_isActive] DEFAULT ((1)) NOT NULL,
    [created_On]       DATETIME      CONSTRAINT [DF_tblOPIDProductionProcess_createdOn] DEFAULT (getdate()) NOT NULL,
    [completed_On]     DATETIME      NULL,
    [completed_Status] VARCHAR (50)  NULL,
    [modified_On]      DATETIME      CONSTRAINT [DF_tblOPIDProductionProcess_modifiedOn] DEFAULT (getdate()) NOT NULL,
    [modified_By]      VARCHAR (255) CONSTRAINT [DF_tblOPIDProductionProcess_ModifiedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_tblOPIDProductionProcess] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_OPID_IsActive]
    ON [dbo].[tblOPIDProductionProcess]([OPID] ASC, [isActive] ASC);

