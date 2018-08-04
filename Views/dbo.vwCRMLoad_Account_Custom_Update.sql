SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwCRMLoad_Account_Custom_Update]
AS

SELECT  z.[crm_id] accountid							 
, b.new_ssbcrmsystemSSIDWinner							  --,c.new_ssbcrmsystemSSIDWinner
, b.new_ssbcrmsystemSSIDWinnerSourceSystem				  --,c.new_ssbcrmsystemSSIDWinnerSourceSystem
--, TM_Ids [new_ssbcrmsystemarchticsids]				  --,c.
, b.DimCustIDs new_ssbcrmsystemdimcustomerids			  --,c.new_ssbcrmsystemdimcustomerids
, b.AccountId AS str_number								  --,c.[str_number]
-- SELECT *
-- SELECT COUNT(*) 
FROM dbo.[Account_Custom] b 
INNER JOIN dbo.Account z ON b.SSB_CRMSYSTEM_Acct_ID = z.[SSB_CRMSYSTEM_Acct_ID]
LEFT JOIN  prodcopy.vw_Account c ON z.[crm_id] = c.AccountID
----INNER JOIN dbo.CRMLoad_Acct_ProcessLoad_Criteria pl ON b.SSB_CRMSYSTEM_Acct_ID = pl.SSB_CRMSYSTEM_Acct_ID
--Left join Ducks.[dbo].[vw_KeyAccounts] k --updateme
--		ON z.crm_ID = k.SSID
WHERE z.[SSB_CRMSYSTEM_Acct_ID] <> z.[crm_id]
--AND k.SSID is NULL
AND  (HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssbcrmsystemSSIDWinner)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemssidwinner AS VARCHAR(MAX)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssbcrmsystemSSIDWinnerSourceSystem)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemSSIDWinnerSourceSystem AS VARCHAR(MAX)))),'')) 
	--OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.DimCustIDs)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemdimcustomerids AS VARCHAR(MAX)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.AccountId)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_number AS VARCHAR(MAX)))),''))
	)


GO
