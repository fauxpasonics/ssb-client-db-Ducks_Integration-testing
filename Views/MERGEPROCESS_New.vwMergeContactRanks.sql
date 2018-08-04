SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




 
CREATE VIEW [MERGEPROCESS_New].[vwMergeContactRanks]
 
AS
 
SELECT a.SSBID
    , c.contactid ID
    --Add in custom ranking here
    ,ROW_NUMBER() OVER(PARTITION BY SSBID ORDER BY 
	c.str_lastactivitydate DESC, c.modifiedon desc, c.createdon
	--CASE WHEN c.str_number IS NOT NULL OR c.str_number <> '' THEN 99  
	--     WHEN owneridname LIKE '%SSB%' THEN 0 
 --        WHEN owneridname LIKE '%STR%' THEN 1  END DESC, c.createdon, c.Modifiedon DESC
		 ) xRank
FROM MERGEPROCESS_New.DetectedMerges a
JOIN mergeprocess_new.tmp_dimcust b 
    ON a.SSBID = b.SSB_CRMSYSTEM_CONTACT_ID AND b.SourceSystem = 'crm_contact' --updateme for source system --TCF 09112017
    AND a.[ObjectType] = 'Contact'
JOIN mergeprocess_new.tmp_pccontact c
    ON b.SSID = CAST(c.contactid AS NVARCHAR(100))
    --AND c.statuscodename = 'Active'
WHERE MergeComplete = 0;
 
 
 

GO
