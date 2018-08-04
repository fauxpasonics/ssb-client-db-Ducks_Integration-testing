SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [dbo].[vwCRMLoad_Contact_Custom_Update]
AS

SELECT  z.[crm_id] contactid
,CASE WHEN ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') LIKE 'CRM%' THEN c.new_ssbcrmsystemssidwinner ELSE b.new_ssbcrmsystemssidwinner END new_ssbcrmsystemssidwinner											--,c.new_ssbcrmsystemssidwinner
,CASE WHEN ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') LIKE 'CRM%' THEN c.new_ssbcrmsystemSSIDWinnerSourceSystem ELSE b.new_ssbcrmsystemSSIDWinnerSourceSystem END 	new_ssbcrmsystemSSIDWinnerSourceSystem		--,c.new_ssbcrmsystemSSIDWinnerSourceSystem																																
--, TM_Ids [new_ssbcrmsystemarchticsids]																																												--
--, DimCustIDs new_ssbcrmsystemdimcustomerids																																											-- ,c.new_ssbcrmsystemdimcustomerids
--, b.AccountId [new_ssbcrmsystemarchticsids]																																											-- ,c.[new_ssbcrmsystemarchticsids]
, ISNULL(NULLIF(b.AccountId,''), c.str_number) [str_number]																																								--,c.str_number										--updateme for STR clients
, z.EmailPrimary AS emailaddress1																																														--,c.emailaddress1
,b.str_category-- ISNULL(b.str_category, c.str_category) str_category		changed 3/26 ssales becuase CRM was not reflecting null values																																							--,c.str_category
, b.new_ssb_NewBusinessLead																																																--,c.new_ssb_NewBusinessLead
, b.new_ssb_GroupSalesLead																																																--,c.new_ssb_GroupSalesLead
, b.new_ssb_EloquaTicketInformation																																														--,c.new_ssb_EloquaTicketInformation
, b.new_ssb_EloquaPromotionalInformation																																												--,c.new_ssb_EloquaPromotionalInformation
, b.new_ssb_EloquaPremiumInformation																																													--,c.new_ssb_EloquaPremiumInformation
, b.new_ssb_EloquaFormSubmission																																														--,c.new_ssb_EloquaFormSubmission
, b.new_ssb_EmailActivity																																																--,c.new_ssb_EmailActivity
, b.new_TMOtherContact																																																	--,c.new_TMOtherContact
, b.new_TMSecondaryContact																																																--,c.new_TMSecondaryContact
, ISNULL(b.ownerid,c.ownerid) ownerid																																													--						--,c.ownerid
, ISNULL(b.owneridtype, c.owneridtype) owneridtype																																										--								--,c.owneridtype
, ISNULL(b.new_groupssalesperson, c.new_groupssalesperson)			 new_groupssalesperson																																--,c.new_groupssalesperson 
, ISNULL(b.str_clientpremiumsalesperson, c.str_clientpremiumsalesperson) str_clientpremiumsalesperson																													--,c.str_clientpremiumsalesperson
, b.new_ssb_NewPremiumLead																																																--,c.new_ssb_newpremiumlead
, b.mobilephone																																																			--,c.mobilephone
, b.telephone2																																																			--,c.telephone2
, b.[new_ssb_HondaGroupSalesLead]																																														--,c.[new_ssb_HondaGroupSalesLead]
, b.str_clientrecenteloquainfo																																															--,c.str_clientrecenteloquainfo
, b.str_clientrecenteloquadate																																															--,c.str_clientrecenteloquadate
, b.new_distancefromarena

--,b.[new_ssb_GroupInterest]																																																--,c.[new_ssb_GroupInterest]				
--,b.[new_ssb_MiniPlanInterest]																																															--,c.[new_ssb_MiniPlanInterest]			
--,b.[new_ssb_SingleGameTicketInterest]																																													--,c.[new_ssb_SingleGameTicketInterest]	
--,b.[new_ssb_SuiteInterest]																																																--,c.[new_ssb_SuiteInterest]
,b.[new_ssb_GroupInterest_yesno]																																														--,c.[new_ssb_GroupInterest_yesno]					
,b.[new_ssb_MiniPlanInterest_yesno]																																														--,c.[new_ssb_MiniPlanInterest_yesno]			
,b.[new_ssb_SingleGameTicketInterest_yesno]																																												--,c.[new_ssb_SingleGameTicketInterest_yesno]	
,b.[new_ssb_SuiteInterest_yesno]																																														--,c.[new_ssb_SuiteInterest_yesno]					
,b.new_ssb_EmailAddress2 emailaddress2																																																					   

	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.mobilephone AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.mobilephone AS NVARCHAR(50)))),''))																												 then 1 else 0 end as mobilephone
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.telephone2 AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.telephone2 AS NVARCHAR(50)))),''))																													 then 1 else 0 end as telephone2
	--,case when CAST(CASE WHEN ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') LIKE 'CRM%' THEN c.new_ssbcrmsystemssidwinner ELSE b.new_ssbcrmsystemssidwinner END AS NVARCHAR(100)) <> CAST(ISNULL(c.new_ssbcrmsystemssidwinner,'') AS NVARCHAR(100)) 												 then 1 else 0 end as new_ssbcrmsystemssidwinner
	--,case when CAST(CASE WHEN ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') LIKE 'CRM%' THEN c.new_ssbcrmsystemSSIDWinnerSourceSystem ELSE b.new_ssbcrmsystemSSIDWinnerSourceSystem END AS NVARCHAR(100))  <> CAST(ISNULL(c.new_ssbcrmsystemSSIDWinnerSourceSystem,'') AS NVARCHAR(100))			 then 1 else 0 end as new_ssbcrmsystemSSIDWinnerSourceSystem
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.AccountId)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_number AS VARCHAR(MAX)))),''))																																		 then 1 else 0 end as str_number
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(z.EmailPrimary)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.emailaddress1 AS NVARCHAR(MAX)))),''))																																	 then 1 else 0 end as emailaddress1
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_NewBusinessLead)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_NewBusinessLead AS DATETIME))),''))																													 then 1 else 0 end as new_ssb_NewBusinessLead
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_GroupSalesLead)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_GroupSalesLead AS DATETIME))),''))																													 then 1 else 0 end as new_ssb_GroupSalesLead
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaTicketInformation)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaTicketInformation AS DATETIME))),''))																									 then 1 else 0 end as new_ssb_EloquaTicketInformation
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaPromotionalInformation)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaPromotionalInformation AS DATETIME))),''))																						 then 1 else 0 end as new_ssb_EloquaPromotionalInformation
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaPremiumInformation)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaPremiumInformation AS DATETIME))),''))																								 then 1 else 0 end as new_ssb_EloquaPremiumInformation
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaFormSubmission)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaFormSubmission AS DATETIME))),''))																										 then 1 else 0 end as new_ssb_EloquaFormSubmission
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EmailActivity)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EmailActivity AS DATETIME))),''))																														 then 1 else 0 end as new_ssb_EmailActivity
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.[str_category])),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_category AS NVARCHAR(500)))),''))																																 then 1 else 0 end as str_category
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_TMOtherContact)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_TMOtherContact AS NVARCHAR(500)))),''))																														 then 1 else 0 end as new_TMOtherContact
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_TMSecondaryContact)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_TMSecondaryContact AS NVARCHAR(500)))),''))																												 then 1 else 0 end as new_TMSecondaryContact
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.ownerid AS NVARCHAR(100)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.ownerid AS NVARCHAR(500)))),''))																														 then 1 else 0 end as ownerid
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.new_groupssalesperson AS NVARCHAR(100)))),CAST(c.new_groupssalesperson AS NVARCHAR(100))) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_groupssalesperson AS NVARCHAR(500)))),''))												 then 1 else 0 end as new_groupssalesperson
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.str_clientpremiumsalesperson AS NVARCHAR(100)))),CAST(c.str_clientpremiumsalesperson AS NVARCHAR(100))))  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientpremiumsalesperson AS NVARCHAR(500)))),''))							 then 1 else 0 end as str_clientpremiumsalesperson
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_NewPremiumLead)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_NewPremiumLead AS DATETIME))),''))																													 then 1 else 0 end as new_ssb_NewPremiumLead
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.[new_ssb_HondaGroupSalesLead])),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssb_HondaGroupSalesLead] AS DATETIME))),''))												 													 then 1 else 0 end as [new_ssb_HondaGroupSalesLead]
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.str_clientrecenteloquadate)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientrecenteloquadate AS DATETIME))),''))																											 then 1 else 0 end as str_clientrecenteloquadate
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.str_clientrecenteloquainfo AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientrecenteloquainfo AS NVARCHAR(50)))),''))																				 then 1 else 0 end as str_clientrecenteloquainfo
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.new_distancefromarena AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_distancefromarena AS NVARCHAR(50)))),''))																							 then 1 else 0 end as new_distancefromarena




-- SELECT *
-- SELECT COUNT(*) 
FROM dbo.[Contact_Custom] b 
INNER JOIN dbo.Contact z ON b.SSB_CRMSYSTEM_CONTACT_ID = z.[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN  prodcopy.vw_contact c ON z.[crm_id] = c.contactID
INNER JOIN dbo.CRMLoad_Contact_ProcessLoad_Criteria pl ON b.SSB_CRMSYSTEM_CONTACT_ID = pl.SSB_CRMSYSTEM_CONTACT_ID
LEFT JOIN dbo.vw_KeyAccounts k ON k.ssbid = z.SSB_CRMSYSTEM_CONTACT_ID
WHERE z.[SSB_CRMSYSTEM_CONTACT_ID] <> z.[crm_id]

AND k.ssbid IS NULL
AND  (1=2
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.mobilephone AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.mobilephone AS NVARCHAR(50)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.telephone2 AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.telephone2 AS NVARCHAR(50)))),''))	
	OR  CAST(CASE WHEN ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') LIKE 'CRM%' THEN c.new_ssbcrmsystemssidwinner ELSE b.new_ssbcrmsystemssidwinner END AS NVARCHAR(100)) <> CAST(ISNULL(c.new_ssbcrmsystemssidwinner,'') AS NVARCHAR(100)) 							
	OR  CAST(CASE WHEN ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') LIKE 'CRM%' THEN c.new_ssbcrmsystemSSIDWinnerSourceSystem ELSE b.new_ssbcrmsystemSSIDWinnerSourceSystem END AS NVARCHAR(100))  <> CAST(ISNULL(c.new_ssbcrmsystemSSIDWinnerSourceSystem,'') AS NVARCHAR(100))
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.AccountId)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_number AS VARCHAR(MAX)))),''))															
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(z.EmailPrimary)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.emailaddress1 AS NVARCHAR(MAX)))),''))													
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_NewBusinessLead)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_NewBusinessLead AS DATETIME))),''))									
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_GroupSalesLead)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_GroupSalesLead AS DATETIME))),''))										
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaTicketInformation)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaTicketInformation AS DATETIME))),''))					
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaPromotionalInformation)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaPromotionalInformation AS DATETIME))),''))			
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaPremiumInformation)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaPremiumInformation AS DATETIME))),''))					
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EloquaFormSubmission)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EloquaFormSubmission AS DATETIME))),''))							
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_EmailActivity)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_EmailActivity AS DATETIME))),''))										
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.[str_category])),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_category AS NVARCHAR(500)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_TMOtherContact)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_TMOtherContact AS NVARCHAR(500)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_TMSecondaryContact)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_TMSecondaryContact AS NVARCHAR(500)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.ownerid AS NVARCHAR(100)))),c.ownerid) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.ownerid AS NVARCHAR(500)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.new_groupssalesperson AS NVARCHAR(100)))),CAST(c.new_groupssalesperson AS NVARCHAR(100))) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_groupssalesperson AS NVARCHAR(500)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.str_clientpremiumsalesperson AS NVARCHAR(100)))),CAST(c.str_clientpremiumsalesperson AS NVARCHAR(100))))  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientpremiumsalesperson AS NVARCHAR(500)))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssb_NewPremiumLead)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssb_NewPremiumLead AS DATETIME))),''))		
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.[new_ssb_HondaGroupSalesLead])),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssb_HondaGroupSalesLead] AS DATETIME))),''))												 
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.str_clientrecenteloquadate)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientrecenteloquadate AS DATETIME))),''))	
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.str_clientrecenteloquainfo AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.str_clientrecenteloquainfo AS NVARCHAR(50)))),''))
	OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.new_distancefromarena AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_distancefromarena AS NVARCHAR(50)))),''))
	--OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.[new_ssb_GroupInterest] AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssb_GroupInterest] AS NVARCHAR(50)))),''))
	--OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.[new_ssb_MiniPlanInterest] AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssb_MiniPlanInterest] AS NVARCHAR(50)))),''))
	--OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.[new_ssb_SingleGameTicketInterest] AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssb_SingleGameTicketInterest] AS NVARCHAR(50)))),''))
	--OR  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(b.[new_ssb_SuiteInterest] AS NVARCHAR(50)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssb_SuiteInterest] AS NVARCHAR(50)))),''))
	OR isnull(b.[new_ssb_GroupInterest_yesno]				,0)				!= isnull(c.[new_ssb_GroupInterest_yesno]					,0)
	OR isnull(b.[new_ssb_MiniPlanInterest_yesno]			,0)				!= isnull(c.[new_ssb_MiniPlanInterest_yesno]				,0)
	OR isnull(b.[new_ssb_SingleGameTicketInterest_yesno]	,0)				!= isnull(c.[new_ssb_SingleGameTicketInterest_yesno]		,0)
	OR isnull(b.[new_ssb_SuiteInterest_yesno]				,0)				!= isnull(c.[new_ssb_SuiteInterest_yesno]			       	,0)
	OR isnull(b.new_ssb_EmailAddress2				,'')				!= isnull(c.emailaddress2			       	,'')

	)












GO
