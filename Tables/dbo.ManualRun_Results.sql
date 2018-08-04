CREATE TABLE [dbo].[ManualRun_Results]
(
[contactid] [uniqueidentifier] NULL,
[accountid] [uniqueidentifier] NULL,
[targetid] [uniqueidentifier] NULL,
[subordinateid] [uniqueidentifier] NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[CrmErrorMessage] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
