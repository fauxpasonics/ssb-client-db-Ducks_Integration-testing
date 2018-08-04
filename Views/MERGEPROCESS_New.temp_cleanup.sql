SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE VIEW [MERGEPROCESS_New].[temp_cleanup] AS 
  SELECT distinct cl.* FROM MERGEPROCESS_New.vw_Cust_Contact_ColumnLogic cl
 left JOIN dbo.ManualMerge_12122017 win ON cl.targetid = win.targetid
 LEFT JOIN dbo.ManualMerge_12122017 lose ON cl.subordinateid = lose.subordinateid
 WHERE win.targetid IS NOT NULL OR lose.targetid IS NOT NULL
GO
