CREATE TABLE [dbo].[tblOPIDProductionStatus] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [OPID]            INT           NOT NULL,
    [RunNumber]       VARCHAR (255) NOT NULL,
    [processStatus]   VARCHAR (50)  NOT NULL,
    [isCurrentStatus] BIT           CONSTRAINT [DF_tblOPIDProductionStatus_isCurrentStatus] DEFAULT ((1)) NOT NULL,
    [created_On]      DATETIME      CONSTRAINT [DF_tblOPIDProductionStatus_createdOn] DEFAULT (getdate()) NOT NULL,
    [modified_On]     DATETIME      CONSTRAINT [DF_tblOPIDProductionStatus_modifiedOn] DEFAULT (getdate()) NOT NULL,
    [modified_By]     VARCHAR (255) CONSTRAINT [DF_tblOPIDProductionStatus_ModifiedBy] DEFAULT (suser_sname()) NOT NULL,
    CONSTRAINT [PK_tblOPIDProductionStatus] PRIMARY KEY CLUSTERED ([Id] ASC)
);

