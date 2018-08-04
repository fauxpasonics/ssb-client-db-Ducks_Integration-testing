SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Prep]
AS 
SELECT --updateme - hashes
	  a.[SSB_CRMSYSTEM_ACCT_ID] new_ssbcrmsystemacctid
	  , a.[SSB_CRMSYSTEM_CONTACT_ID] new_ssbcrmsystemcontactid
	  , a.[Prefix]
      , CASE WHEN ISNULL(dc.FirstName,'') = '' AND ISNULL(dc.LastName,'') NOT LIKE '% %' AND ISNULL(dc.lastname,'') != '' AND dc.nameiscleanstatus = 'Invalid (First name is blank)' THEN dc.FirstName ELSE a.FirstName END AS Firstname
	  , CASE WHEN ISNULL(dc.FirstName,'') = '' AND ISNULL(dc.LastName,'') NOT LIKE '% %' AND ISNULL(dc.lastname,'') != ''  AND dc.nameiscleanstatus = 'Invalid (First name is blank)' THEN dc.LastName ELSE a.LastName END AS Lastname
	  , LEFT(a.[Suffix],10) AS Suffix
      ,a.[AddressPrimaryStreet] address1_line1
      ,a.[AddressPrimaryCity] address1_city
      ,a.[AddressPrimaryState] address1_stateorprovince
      ,a.[AddressPrimaryZip] address1_postalcode
      ,a.[AddressPrimaryCountry] address1_country
      ,a.[Phone] telephone1
      ,a.[crm_id] contactid
	  ,a.EmailPrimary emailaddress1
	  ,c.[LoadType]	  
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.FirstName))),'')) AS Hash_FirstName						--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.LastName))),'')) AS Hash_LastName						--	DCH 2017-02-19 
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.Suffix))),'')) AS Hash_Suffix 							--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.AddressPrimaryStreet))),'')) AS Hash_Address1_Line1 		--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.EmailPrimary))),'')) AS Hash_EmailAddress1 		--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(a.Phone,')',''),'(',''),'-',''),' ','')))),'')) AS Hash_Telephone1					--	DCH 2017-02-19
	  --, dc.NameIsCleanStatus
	  --INTO #temp
  FROM [dbo].Contact a 
INNER JOIN dbo.[CRMLoad_Contact_ProcessLoad_Criteria] c ON [c].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
INNER JOIN dbo.vwCompositeRecord_ModAcctID comp ON a.SSB_CRMSYSTEM_CONTACT_ID = comp.SSB_CRMSYSTEM_CONTACT_ID
LEFT JOIN ducks.dbo.DimCustomer dc WITH (NOLOCK) ON dc.DimCustomerId = comp.DimCustomerId AND dc.SourceSystem = 'TM'









GO
