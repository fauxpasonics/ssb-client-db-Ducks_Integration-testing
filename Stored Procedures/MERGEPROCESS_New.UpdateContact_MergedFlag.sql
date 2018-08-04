SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [MERGEPROCESS_New].[UpdateContact_MergedFlag]

AS

--	update winning record
UPDATE A
SET A.MergeComplete = 1,
	A.MergeComment = CASE WHEN c.CrmErrorMessage is null then CONCAT('Merge completed on ',CAST(GETDATE() AS NVARCHAR(100)),' by SSB.')
						WHEN C.CrmErrorMessage LIKE '%Does Not Exist%' OR C.CrmErrorMessage LIKE '%is deactive%'
									THEN CONCAT('Merge not possible, entity is deleted. Attempted on: ',CAST(GETDATE() AS NVARCHAR(100)),'') END
FROM MERGEPROCESS_New.DetectedMerges A
JOIN MERGEPROCESS_New.[Queue] B
	ON A.PK_MergeID = B.FK_MergeID
	AND A.ObjectType = B.ObjectType
	AND A.ObjectType = 'Contact'
JOIN MERGEPROCESS_New.ContactMerge_ProcessLog C
	ON C.targetid = b.Winning_ID 

;
GO
