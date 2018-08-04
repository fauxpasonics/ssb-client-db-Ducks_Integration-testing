CREATE TABLE [MERGEPROCESS_New].[Queue]
(
[FK_MergeID] [int] NOT NULL,
[ObjectType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Winning_ID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Losing_ID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [MERGEPROCESS_New].[Queue] ADD CONSTRAINT [FK_MergeID] PRIMARY KEY CLUSTERED  ([FK_MergeID])
GO
