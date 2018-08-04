SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
 CREATE view [MERGEPROCESS_New].[DevUpdates] AS 

 SELECT win.targetid, lose.subordinateid, CASE WHEN win.targetid IS NULL THEN lose.subordinateid ELSE win.targetid END contactid, cc.* 
 FROM MERGEPROCESS_New.DetectedMerges dm
 INNER JOIN dbo.Contact c
 ON dm.SSBID = c.SSB_CRMSYSTEM_CONTACT_ID
 INNER JOIN dbo.Contact_Custom cc
 ON cc.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
 left JOIN MERGEPROCESS_New.vw_Cust_Contact_ColumnLogic win
 ON win.targetid = c.crm_id
 LEFT JOIN MERGEPROCESS_New.vw_Cust_Contact_ColumnLogic lose
 ON lose.subordinateid = c.crm_id
 WHERE dm.ObjectType = 'contact'
 AND (win.targetid IS NOT NULL OR lose.subordinateid IS NOT NULL)

GO
