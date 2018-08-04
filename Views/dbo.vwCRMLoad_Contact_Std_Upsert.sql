SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Upsert] AS

SELECT u.new_ssbcrmsystemacctid, u.new_ssbcrmsystemcontactid, u.Prefix, u.FirstName, u.LastName, u.Suffix, u.address1_line1, u.address1_city,
	u.address1_stateorprovince, u.address1_postalcode, u.address1_country, u.telephone1, u.LoadType, u.emailaddress1
FROM [dbo].[vwCRMLoad_Contact_Std_Prep] u
left JOIN lions_reporting.prodcopy.contact c WITH (NOLOCK) ON u.firstname = c.firstname AND u.LastName = c.lastname AND ISNULL(u.Suffix,'') = ISNULL(c.suffix,'') AND  c.statecode = 0 AND c.emailaddress1 = u.emailaddress1 AND u.firstname != 'CBFC' AND u.FirstName != 'Suite' AND u.FirstName != 'soldier' AND u.FirstName != 'ticket'
left JOIN lions_reporting.prodcopy.contact d WITH (NOLOCK) ON u.firstname = d.firstname AND u.LastName = d.lastname AND ISNULL(u.Suffix,'') = ISNULL(d.suffix,'') AND  d.statecode = 0 AND isnull(d.address1_line1,'') = isnull(u.address1_line1,'') AND NULLIF(u.address1_line1, ' ') IS NOT NULL AND u.firstname != 'CBFC' AND u.FirstName != 'Suite' AND u.FirstName != 'soldier' AND u.FirstName != 'ticket'
WHERE LoadType = 'Upsert' 
AND c.contactid IS NULL AND d.contactid IS null
AND u.new_ssbcrmsystemcontactid NOT IN ('98A0ED5C-EC18-4C96-BE81-8A4A84C69373',
'D24345B9-C110-481F-8FCC-9680D6248834',
'05C5EF95-9BD4-4CB8-8746-13CDA01B69EE',
'AE1BACBC-7F03-4B09-8396-CA9EC094595C',
'AE1BACBC-7F03-4B09-8396-CA9EC094595C',
'BA6B1124-613A-44CB-A6BA-747665B2A5C8',
'BA6B1124-613A-44CB-A6BA-747665B2A5C8',
'91FB81CD-FF1F-41E2-8149-35D665FEF637',
'D1DBA14B-1350-4B94-81C1-1F044258010D',
'4A3F5393-6250-4D7D-902C-7E52A3F2B6F9', 'FB11810A-C98D-4777-9428-58D445869E5D', '0DEA32BD-CF80-4472-B33D-4E3DB54D07D6',
'0DEA32BD-CF80-4472-B33D-4E3DB54D07D6',
'7B4D8FA5-4E80-422E-A160-A115C4731407',
'A2CE10B4-168B-4EEF-B0E9-C92B13117EF3',
'6B81A6F0-D24D-44E8-BB1A-16E8F8500E1C',
'156A3DEC-62BC-4EAE-BABC-8B05E57E0A44',
'0DECF0A7-9D0E-457D-A582-2BB93CAC7B10',
'D56B2902-F876-4397-8D84-1618D4390C07',
'F0E2F1B3-CE35-498B-825C-19317B5FE973',
'1D3531F8-68F5-4926-A70A-D553577C2405',
'75B5C0FE-9D10-40F4-99E8-32D3B112BA14',
'4B0EFD5E-FBEF-4B10-B5DC-9DD136DE868C', 'A504341B-96C5-41A8-9572-2A3C9317BA91',
'D33F9428-04FA-412A-8AC4-A8F911CC8971', 'E4B68FD6-91C7-4987-BA88-649BA869B9F9',
'9CE1E776-34A8-4FED-9240-34A50F0A9C6C',
'CFB06A80-9D9D-46D3-B3C3-94082FDA2414',
'21FE3AB2-8F33-4117-A219-01EB80CB45F4',
'76FF1C17-CFBF-483B-BE37-8B62FDC3A1E0',
'0F582564-F631-4D19-B6D5-1F7F97318595',
'E20B9218-648B-4A06-A385-E99AB1E8C409',
'E20B9218-648B-4A06-A385-E99AB1E8C409',
'6A4431E0-BC39-47CA-B0F2-3D831C7FF7EE',
'6A4431E0-BC39-47CA-B0F2-3D831C7FF7EE',
'CBB91A15-C4D6-44D9-BB75-0310A6A138A2',
'30398F37-AE3D-4316-8DDD-B3DFD1BB7BFE',
'54E8829E-3195-447A-8472-E06AAEA5C9FE',
'15443C32-5DB0-4904-9E59-1E48FCF1EB06',
'46E4CE8F-A232-4893-ADDF-30C52ADF9565')







GO
