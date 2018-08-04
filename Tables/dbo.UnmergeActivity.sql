CREATE TABLE [dbo].[UnmergeActivity]
(
[activityid] [uniqueidentifier] NULL,
[regardingobjectid] [uniqueidentifier] NULL,
[regardingobjectidtypecode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statecode] [int] NULL
)
GO
