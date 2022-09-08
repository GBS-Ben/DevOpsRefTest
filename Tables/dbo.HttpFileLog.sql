CREATE TABLE [dbo].[HttpFileLog] (
    [HttpFileLogId]      INT             IDENTITY (1, 1) NOT NULL,
    [RemoteFileSource]   VARCHAR (500)   NULL,
    [RemoteFilePath]     NVARCHAR (2500) NULL,
    [LocalFilePath]      NVARCHAR (2500) NULL,
    [FileProcessNote]    VARCHAR (500)   NULL,
    [FileStatusDateTime] DATETIME2 (7)   NULL,
    [FileStatus]         VARCHAR (100)   DEFAULT ('New') NULL,
    [CreateDateTime]     DATETIME2 (7)   DEFAULT (getdate()) NULL
);

