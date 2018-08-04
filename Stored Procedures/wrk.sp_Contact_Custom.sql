SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





















CREATE PROCEDURE [wrk].[sp_Contact_Custom]
AS 

MERGE INTO dbo.Contact_Custom Target
USING dbo.Contact source
ON source.[SSB_CRMSYSTEM_CONTACT_ID] = target.[SSB_CRMSYSTEM_CONTACT_ID]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID]) VALUES (source.[SSB_CRMSYSTEM_ACCT_ID], Source.[SSB_CRMSYSTEM_CONTACT_ID])
WHEN NOT MATCHED BY SOURCE THEN
DELETE ;

EXEC dbo.sp_CRMProcess_ConcatIDs 'Contact'


EXEC dbo.sp_CRMLoad_Contact_ProcessLoad_Criteria


--UPDATE a
--SET SeasonTicket_Years = recent.SeasonTicket_Years
----SELECT *
--FROM dbo.[Contact_Custom] a
--INNER JOIN dbo.CRMProcess_DistinctContacts recent ON [recent].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]

UPDATE a
SET a.new_ssbcrmsystemssidwinner = b.[SSID], a.new_ssbcrmsystemSSIDWinnerSourceSystem = b.SourceSystem, a.mobilephone = b.phonecell, telephone2 = b.PhoneHome
FROM [dbo].Contact_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]



/*================================================
Archtics Secondary Contacts
==================================================*/

UPDATE contact_custom 
SET new_TMSecondaryContact = ConcatIDs1
--SELECT query.ConcatIDs1
FROM contact_custom cc INNER JOIN 
(
SELECT [GUID]
,ISNULL(LEFT(STUFF((    SELECT  ', ' + name_first + ' ' + name_last  AS [text()]

FROM (
SELECT DISTINCT cc.SSB_CRMSYSTEM_CONTACT_ID AS [GUID], secondaries.FirstName name_first, secondaries.LastName name_last
		FROM contact_custom cc INNER JOIN dbo.vwDimCustomer_ModAcctId mai 
		ON mai.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND mai.sourcesystem = 'tm'
		INNER JOIN dbo.vwDimCustomer_ModAcctId secondaries
		ON mai.accountid = secondaries.accountid 
		AND secondaries.sourcesystem = 'tm'
		AND mai.dimcustomerid != secondaries.dimcustomerid 
		AND secondaries.CustomerType = 'Secondary' --I believe this is the only change needed for the Secondary account owner
		AND mai.firstname + mai.lastname != secondaries.firstname + secondaries.lastname 
		WHERE mai.CustomerType IN ('Primary') AND mai.SSB_CRMSYSTEM_PRIMARY_FLAG = 1 AND ISNULL(secondaries.firstname,'') + ISNULL(secondaries.lastname,'') != ''
		--AND  cc.SSB_CRMSYSTEM_CONTACT_ID = '9D523431-BCFE-42DB-8C8B-C9BE0C02F6E0'
		AND secondaries.IsDeleted = 0

) TM
WHERE TM.[GUID] = z.[GUID] 

ORDER BY name_first
FOR XML PATH('')), 1, 1, ''),8000),'') AS ConcatIDs1

FROM (SELECT DISTINCT GUID FROM [stg].tbl_CRMProcess_NonWinners
) z
) query ON query.[GUID] = cc.SSB_CRMSYSTEM_CONTACT_ID



/*================================================
Archtics Other Contacts
==================================================*/

UPDATE contact_custom 
SET new_TMOtherContact  = ConcatIDs1
--SELECT query.ConcatIDs1, query.guid
FROM contact_custom cc INNER JOIN 
(
SELECT [GUID]
,ISNULL(LEFT(STUFF((    SELECT  ', ' + name_first + ' ' + name_last  AS [text()]
FROM (
SELECT DISTINCT cc.SSB_CRMSYSTEM_CONTACT_ID AS [GUID], other.FirstName name_first, other.LastName name_last
		FROM contact_custom cc INNER JOIN dbo.vwDimCustomer_ModAcctId mai 
		ON mai.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID AND mai.sourcesystem = 'tm'
		INNER JOIN dbo.vwDimCustomer_ModAcctId other
		ON mai.accountid = other.accountid 
		AND other.sourcesystem = 'tm'
		AND mai.dimcustomerid != other.dimcustomerid 
		AND other.CustomerType = 'Other' --I believe this is the only change needed for the Secondary account owner
		AND mai.firstname + mai.lastname != other.firstname + other.lastname 
		WHERE mai.CustomerType IN ('Primary') AND mai.SSB_CRMSYSTEM_PRIMARY_FLAG = 1 AND ISNULL(other.firstname,'') + ISNULL(other.lastname,'') != ''
			AND other.IsDeleted = 0
) TM
WHERE TM.[GUID] = z.[GUID] 
ORDER BY name_first
FOR XML PATH('')), 1, 1, ''),8000),'') AS ConcatIDs1

FROM (SELECT DISTINCT GUID FROM [stg].tbl_CRMProcess_NonWinners
) z
) query ON query.[GUID] = cc.SSB_CRMSYSTEM_CONTACT_ID

WHERE ISNULL(query.ConcatIDs1,'') != ''


/*============================
STR Category
============================*/
--Select sub.SSB_CRMSYSTEM_CONTACT_ID, Sub.Category 
--INTO  #str_category_prep
--FROM (   
--       select distinct c.SSB_CRMSYSTEM_CONTACT_ID, case 
--when p.PlanCode like '17DFS%' and (f.TM_ticket_type = 'STH New Sale' or f.TM_ticket_type like 'Ducks New%') and f.TM_ticket_type not like '%F&B%'  then '17 Full New' 
--when p.plancode like '17DFS%' and (f.TM_Ticket_type in ('STH Upgrade','STH Add-On','STH Renewal') or f.TM_Ticket_type like 'Ducks Renewal%' or f.TM_Ticket_type like '%Upgrade%') and f.TM_Ticket_type not like '%F&B%'  then '17 Full Renewal'
--when p.plancode like '17DFS%' and f.TM_Ticket_type in ('OC Business Plan') and f.TM_Ticket_type not like '%F&B%'  then '17 Full OCB'
--when (p.plancode IN('17PICKHS','17HALF') or f.TM_Ticket_type in ('Half Season Renewal','Half Season New')) and S.ETL__SSID_TM_season_id not in ('224','235','243','255') then '17 Half'
--when (p.plancode in ('17BLK','17WKND','17ORN','17GOLD','17PICK','17MPFlex','17STAR') or f.TM_Ticket_type like 'Mini Plan%') and S.ETL__SSID_TM_season_id not in ('224','235','243','255') then '17 Mini'
--when p.plancode IN ('17CLB','17CBWT') then '17 Annual Club'
--when p.plancode = '17STE' then '17 Annual Suite'
--when p.PlanCode IN( '17ORGNL6','17HOLDAY','17CLBRTE','17START') or p.plancode like '17START%' then '17 Micro'
--when p.plancode like '16DFS%' and (f.TM_Ticket_type = 'STH New Sale' or f.TM_Ticket_type like 'Ducks New%') and f.TM_Ticket_type not like '%F&B%' then '16 Full New' 
--when p.plancode like '16DFS%' and (f.TM_Ticket_type in ('STH Upgrade','STH Add-On','STH Renewal') or f.TM_Ticket_type like 'Ducks Renewal%' or f.TM_Ticket_type like '%Upgrade%') and f.TM_Ticket_type not like '%F&B%' then '16 Full Renewal'
--when p.plancode like '16DFS%' and (f.TM_Ticket_type in ('OC Business Plan') and f.TM_Ticket_type not like '%F&B%' ) then '16 Full OCB'
--when ((p.plancode = '16HALF' or f.TM_Ticket_type in ('Half Season Renewal','Half Season New')) or p.plancode = '16PICKHS') and (S.ETL__SSID_TM_season_id = '243')  then '16 Half'
--when (p.plancode in ('16BLK','16WKND','16ORN','16GOLD','16PICK','16MPFlex','16STAR') or f.TM_Ticket_type like 'Mini Plan%') and (S.ETL__SSID_TM_season_id = '243') then '16 Mini'
--when (p.plancode = '16CLB' or p.plancode =  '16CBWT') then '16 Annual Club'
--when (p.plancode = '16STE') then '16 Annual Suite'
--when ( p.plancode in ('16ORGNL6','16CLBRTE','16HOLDAY') or  p.plancode like '16START%'  ) then '16 Micro'
--       else NULL end as 'Category'
--       from contact_custom cc
--       INNER JOIN contact c 
--            ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
--       INNER JOIN dbo.vwDimCustomer_ModAcctId ma 
--            ON ma.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
--		INNER JOIN ducks.dbo.factticketsales_v2 F
--			ON f.ETL__SSID_TM_acct_id = ma.AccountId AND ma.SourceSystem = 'TM' AND ma.CustomerType = 'Primary'
--		INNER JOIN ducks.dbo.DimEvent_V2 e
--			ON e.DimEventId = f.DimEventId
--		INNER JOIN Ducks.dbo.DimPlan_V2 p
--			ON p.DimPlanId = F.DimPlanId
--		INNER JOIN Ducks.dbo.DimSeason_V2 s
--			ON s.DimSeasonId = f.DimSeasonId




Select sub.SSB_CRMSYSTEM_CONTACT_ID, Sub.Category 
INTO   #str_category_prep
FROM (   
       select distinct c.SSB_CRMSYSTEM_CONTACT_ID, case 
WHEN s.dimseasonID = 47 AND f.dimticketclassid = '3'  then '18 Full New' 
when s.dimseasonID = 47 AND f.dimticketclassid = '5' then '18 Full Renewal'
when s.dimseasonID = 47 AND f.dimticketclassid = '7' then '18 Full Upgrade'
when p.plancode like '18DFS%' and f.TM_Ticket_type in ('OC Business Plan') and f.TM_Ticket_type not like '%F&B%'  then '17 Full OCB'
WHEN s.dimseasonID = 47  AND f.dimtickettypeID IN(3) then '18 Half'
when s.dimseasonID = 47  AND f.dimtickettypeID IN(4) then '18 Mini'
when s.dimseasonID = 47  AND f.dimtickettypeID IN(8) then '18 Annual Club'
when s.dimseasonID IN (47,55)  AND f.dimtickettypeID IN(10) then '18 Annual Suite'
when s.dimseasonID = 47  AND f.dimtickettypeID IN(9) THEN '18 Micro'
when s.dimseasonID = 27 AND f.dimticketclassid = '3'  then '17 Full New' 
when s.dimseasonID = 27 AND f.dimticketclassid = '5' then '17 Full Renewal'
when s.dimseasonID = 27 AND f.dimticketclassid = '7' then '17 Full Upgrade'
when p.plancode like '17DFS%' and f.TM_Ticket_type in ('OC Business Plan') and f.TM_Ticket_type not like '%F&B%'  then '17 Full OCB'
WHEN s.dimseasonID = 27  AND f.dimtickettypeID IN(3) then '17 Half'
when s.dimseasonID = 27  AND f.dimtickettypeID IN(4) then '17 Mini'
when s.dimseasonID = 27  AND f.dimtickettypeID IN(8) then '17 Annual Club'
when s.dimseasonID IN (27,35)  AND f.dimtickettypeID IN(10) then '17 Annual Suite'
when s.dimseasonID = 27  AND f.dimtickettypeID IN(9) THEN '17 Micro'
when s.dimseasonID = 10 AND f.dimticketclassid = '3' then '16 Full New' 
WHEN  s.dimseasonID = 10 AND f.dimticketclassid = '5' then '16 Full Renewal'
when p.plancode like '16DFS%' and (f.TM_Ticket_type in ('OC Business Plan') and f.TM_Ticket_type not like '%F&B%' ) then '16 Full OCB'
when s.dimseasonID = 10  AND f.dimtickettypeID IN(3)  then '16 Half'
when s.dimseasonID = 10  AND f.dimtickettypeID IN(4)  then '16 Mini'
when s.dimseasonID = 10  AND f.dimtickettypeID IN(8) then '16 Annual Club'
when s.dimseasonID IN  (10,17)  AND f.dimtickettypeID IN(10)then '16 Annual Suite'
when s.dimseasonID = 10  AND f.dimtickettypeID IN(9) then '16 Micro'
       else NULL end as 'Category'
       from contact_custom cc
       INNER JOIN contact c 
            ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
       INNER JOIN dbo.vwDimCustomer_ModAcctId ma 
            ON ma.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
		INNER JOIN ducks.dbo.factticketsales_v2 F
			ON f.ETL__SSID_TM_acct_id = ma.AccountId AND ma.SourceSystem = 'TM' AND ma.CustomerType = 'Primary'
		INNER JOIN ducks.dbo.DimEvent_V2 e
			ON e.DimEventId = f.DimEventId
		INNER JOIN Ducks.dbo.DimPlan_V2 p
			ON p.DimPlanId = F.DimPlanId
		INNER JOIN Ducks.dbo.DimSeason_V2 s
			ON s.DimSeasonId = f.DimSeasonId






       ) Sub where Sub.Category is not NULL



--SELECT DISTINCT f.ETL__SSID_TM_acct_id FROM ducks.dbo.FactTicketSales_V2 f
--JOIN dbo.vwDimCustomer_ModAcctId d
--ON d.AccountId = f.ETL__SSID_TM_acct_id AND d.CustomerType = 'primary' AND d.SourceSystem = 'TM'
--WHERE f.DimSeasonId in ('27','35')
--AND (d.EmailPrimary ='' OR d.EmailPrimary IS NULL)

--SELECT * FROM ducks.dbo.DimTicketType_V2
       


SELECT [GUID]
,ISNULL(LEFT(STUFF((    SELECT  ' | ' + Category  AS [text()]
FROM #str_category_prep TM
WHERE TM.SSB_CRMSYSTEM_CONTACT_ID = z.[GUID] 
ORDER BY TM.Category
FOR XML PATH('')), 1, 3, ''),8000),'') AS ConcatIDs1
INTO #str_category_final
FROM (SELECT DISTINCT GUID FROM [stg].tbl_CRMProcess_NonWinners
) z
UPDATE contact_custom 
SET str_category = NULLIF(ConcatIDs1,'')
FROM dbo.Contact_Custom cc
INNER JOIN #str_category_final f
ON cc.SSB_CRMSYSTEM_CONTACT_ID = f.GUID




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																											---Ticket Buyers----
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Premium Lead 
UPDATE a 
SET a.new_ssb_NewPremiumLead = CAST(x.Premium_Lead AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN ( SELECT distinct SSB_CRMSYSTEM_CONTACT_ID, MAX(Premium_Lead) AS Premium_Lead
				
			FROM(SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID, MAX( CASE WHEN fts.TM_purchase_price >=1500 AND fts.dimtickettypeID NOT IN (2,8,10) THEN fts.OrderDate ELSE null END) AS Premium_Lead
					FROM Ducks.dbo.FactTicketSales_V2 fts
					JOIN ducks.dbo.DimTicketCustomer_V2 t
						ON t.dimticketcustomerID = fts.DimTicketCustomerId
					JOIN ducks.dbo.DimCustomer d
						ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
					JOIN ducks.dbo.dimcustomerssbid ssbid
						ON ssbid.DimCustomerId = d.DimCustomerId
					JOIN Ducks.dbo.DimDate dd
						ON dd.DimDateId = fts.DimDateId
					JOIN ducks.dbo.DimSeattype_V2 ss
						ON ss.DimSeatTypeId = fts.DimSeatTypeId
					WHERE 1 =1 --dd.CalDate >= (GETDATE() - 30)
					AND ss.DimSeatTypeId IN(2)
					AND fts.DimSeasonId = 27
					AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
						OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
						OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
						OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
						OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
					AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
						AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
					
					GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID
					
	
					
						
						union
						
						
					select	ssbid.SSB_CRMSYSTEM_CONTACT_ID, MAX( CASE WHEN fts.qtyseat >=1 AND fts.dimseasonid = 27 THEN fts.OrderDate ELSE null END) AS Premium_Lead
					FROM Ducks.dbo.FactTicketSales_V2 fts
					JOIN ducks.dbo.DimTicketCustomer_V2 t
						ON t.dimticketcustomerID = fts.DimTicketCustomerId
					JOIN ducks.dbo.DimCustomer d
						ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
					JOIN ducks.dbo.dimcustomerssbid ssbid
						ON ssbid.DimCustomerId = d.DimCustomerId
					JOIN Ducks.dbo.DimDate dd
						ON dd.DimDateId = fts.DimDateId
					JOIN ducks.dbo.DimSeattype_V2 ss
						ON ss.DimSeatTypeId = fts.DimSeatTypeId
					JOIN ( SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID, MAX( CASE WHEN fts.qtyseat >=1  THEN fts.OrderDate ELSE null END) AS Premium_Lead
									FROM Ducks.dbo.FactTicketSales_V2 fts
									JOIN ducks.dbo.DimTicketCustomer_V2 t
										ON t.dimticketcustomerID = fts.DimTicketCustomerId
									JOIN ducks.dbo.DimCustomer d
										ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
									JOIN ducks.dbo.dimcustomerssbid ssbid
										ON ssbid.DimCustomerId = d.DimCustomerId
									JOIN Ducks.dbo.DimDate dd
										ON dd.DimDateId = fts.DimDateId
									JOIN ducks.dbo.DimSeattype_V2 ss
										ON ss.DimSeatTypeId = fts.DimSeatTypeId
									WHERE 1 =1 --dd.CalDate >= (GETDATE() - 30)
									AND ss.DimSeatTypeId IN(2,4)
									AND fts.DimSeasonId IN(30,31)
									AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
											OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
											OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
											OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
											OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
											OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
									AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
										AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
									GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID) premium
						ON premium.SSB_CRMSYSTEM_CONTACT_ID = ssbid.SSB_CRMSYSTEM_CONTACT_ID
						AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
								OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
								OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
								OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
								OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
						AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
							AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
					
						GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID

					union
					
						
			SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID, MAX( CASE WHEN fts.QtySeat > 6 THEN fts.OrderDate ELSE null END) AS Premium_Lead
					FROM Ducks.dbo.FactTicketSales_V2 fts
					JOIN ducks.dbo.DimTicketCustomer_V2 t
						ON t.dimticketcustomerID = fts.DimTicketCustomerId
					JOIN ducks.dbo.DimCustomer d
						ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
					JOIN ducks.dbo.dimcustomerssbid ssbid
						ON ssbid.DimCustomerId = d.DimCustomerId
					JOIN Ducks.dbo.DimDate dd
						ON dd.DimDateId = fts.DimDateId
					JOIN ducks.dbo.DimSeattype_V2 ss
						ON ss.DimSeatTypeId = fts.DimSeatTypeId
					WHERE 1 =1 --dd.CalDate >= (GETDATE() - 30)
					AND fts.DimTicketTypeId = 12
					AND fts.DimSeasonId = 27
					AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
						OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
						OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
						OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
						OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
					AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
					AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
						GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID
							
					) b
						GROUP BY b.SSB_CRMSYSTEM_CONTACT_ID
						
							) x
ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID



--Group Sales Lead
UPDATE a 
SET a.new_ssb_GroupSalesLead  = CAST(x.Group_Sales_Lead AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN (SELECT b.SSB_CRMSYSTEM_CONTACT_ID
                , MAX(b.Group_Sales_Lead) AS Group_Sales_Lead
				
            FROM (
                SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID
                    , MAX(CASE WHEN fts.qtyseat BETWEEN 8 AND 14  AND fts.RevenueTicket < 1499 THEN fts.OrderDate ELSE null END) AS Group_Sales_Lead
                FROM Ducks.dbo.FactTicketSales_V2 fts
                JOIN ducks.dbo.DimTicketCustomer_V2 t
                    ON t.dimticketcustomerID = fts.DimTicketCustomerId
                JOIN ducks.dbo.DimCustomer d
                    ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
                JOIN ducks.dbo.dimcustomerssbid ssbid
                    ON ssbid.DimCustomerId = d.DimCustomerId
                JOIN ducks.dbo.DimDate dd
                    ON dd.DimDateId = fts.DimDateId
                WHERE fts.DimTicketTypeId NOT IN (2,8,10,6)
				AND fts.DimSeatTypeId IN(2,6)--dd.CalDate  >=(GETDATE() - 30)
				AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
					OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
					OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
					OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
					OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
				AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
				AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
				





              GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID    
                
                UNION
    
                SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID
                , MAX(CASE WHEN tex.num_seats IN (8,9,10,11,12,13,14) AND tex.te_buyer_fees_hidden <1499 THEN Tex.add_datetime ELSE null end ) AS  Group_Sales_Lead
                FROM Ducks.ods.tm_Tex tex
                JOIN ducks.dbo.DimCustomer d
                    ON tex.acct_id = d.AccountId AND d.SourceSystem = 'TM' AND d.CustomerType = 'Primary'
                JOIN ducks.dbo.dimcustomerssbid ssbid
                    ON ssbid.DimCustomerId = d.DimCustomerId
                WHERE tex.activity_name = 'TE Resale'-- add_datetime >= GETDATE() - 30
				AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
					OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
					OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
					OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
					OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
				AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
					AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')

                GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID
                ) b
            GROUP BY b.SSB_CRMSYSTEM_CONTACT_ID
            ) x
 ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID








--UPDATE dbo.Contact_Custom
--SET new_ssb_NewBusinessLead = NULL,new_ssb_GroupSalesLead = NULL,new_ssb_EloquaTicketInformation = NULL,new_ssb_EloquaPromotionalInformation = NULL,
--new_ssb_EloquaPremiumInformation = NULL,new_ssb_EloquaFormSubmission = NULL,new_ssb_NewPremiumLead = NULL,new_ssb_HondaGroupSalesLead = NULL


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_NewBusinessLead DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_GroupSalesLead DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_EloquaTicketInformation DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_EloquaPromotionalInformation DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_EloquaPremiumInformation DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_EloquaFormSubmission DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_NewPremiumLead DATE


--ALTER TABLE dbo.Contact_Custom
--ALTER COLUMN new_ssb_HondaGroupSalesLead DATE






--SELECT COUNT(*)
--FROM dbo.Contact_Custom
--WHERE new_ssb_EloquaPromotionalInformation IS NOT NULL

--SELECT COUNT(*)E
--FROM dbo.Contact_Custom
--WHERE new_ssb_EloquaPremiumInformation IS NOT NULL

--SELECT COUNT(*)
--FROM dbo.Contact_Custom
--WHERE new_ssb_EloquaFormSubmission IS NOT NULL

--SELECT COUNT(*)
--FROM dbo.Contact_Custom
--WHERE new_ssb_NewPremiumLead IS NOT NULL

--SELECT COUNT(*)
--FROM dbo.Contact_Custom
--WHERE new_ssb_HondaGroupSalesLead IS NOT NULL

--SELECT COUNT(*)
--FROM dbo.Contact_Custom
--WHERE new_ssb_NewBusinessLead IS NOT null







-- Honda Center Group Sales Lead
UPDATE a 
SET a.new_ssb_HondaGroupSalesLead  = CAST(x.Honda_Group_Sales_Lead AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN (SELECT SSB_CRMSYSTEM_CONTACT_ID, MAX(Honda_Group_Sales_Lead) Honda_Group_Sales_Lead
			FROM (
			SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID
                , MAX(CASE WHEN RNT.num_seats IN (8,9,10,11,12,13,14) THEN RNT.add_datetime ELSE null end ) AS  Honda_Group_Sales_Lead
                FROM Ducks.ods.TM_RetailNonTicket RNT
                JOIN ducks.dbo.DimCustomer d
                    ON RNT.acct_id = d.AccountId AND d.SourceSystem = 'TM' AND d.CustomerType = 'Primary'
                JOIN ducks.dbo.dimcustomerssbid ssbid
                    ON ssbid.DimCustomerId = d.DimCustomerId
                WHERE RNT.add_datetime >= GETDATE() - 30
				AND RNT.event_name LIKE 'EAA%'
				AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
					OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
					OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
					OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
					OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
				AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
					AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
                GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID

				UNION

				SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID
                    , MAX(CASE WHEN fts.qtyseat BETWEEN 8 AND 14 THEN fts.OrderDate ELSE null END) AS Group_Sales_Lead
                FROM Ducks.dbo.FactTicketSales_V2 fts
                JOIN ducks.dbo.DimTicketCustomer_V2 t
                    ON t.dimticketcustomerID = fts.DimTicketCustomerId
                JOIN ducks.dbo.DimCustomer d
                    ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
                JOIN ducks.dbo.dimcustomerssbid ssbid
                    ON ssbid.DimCustomerId = d.DimCustomerId
                JOIN ducks.dbo.DimDate dd
                    ON dd.DimDateId = fts.DimDateId
				JOIN ducks.dbo.DimEvent_V2 e
					ON e.DimEventId = fts.DimEventId
                WHERE dd.CalDate  >=(GETDATE() - 30)
				AND e.EventCode LIKE 'EAA%'
				AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
					OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
					OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
					OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
					OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
				AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
					AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
                GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID  
                ) b
				GROUP BY b.SSB_CRMSYSTEM_CONTACT_ID  
			) x
 ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID






--New Business Lead
UPDATE a 
SET a.new_ssb_NewBusinessLead = CAST(b.New_Business_Lead AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN (SELECT SSB_CRMSYSTEM_CONTACT_ID
                , MAX(New_Business_Lead) AS New_Business_Lead
				
            FROM (SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID, MAX(CASE WHEN fts.RevenueTotal >=150 AND fts.dimtickettypeID NOT IN(2,8,10) THEN fts.OrderDate ELSE null END) AS New_Business_Lead
					FROM Ducks.dbo.FactTicketSales_V2 fts
					JOIN ducks.dbo.DimTicketCustomer_V2 t
						ON t.dimticketcustomerID = fts.DimTicketCustomerId
					JOIN ducks.dbo.DimCustomer d
						ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
					JOIN ducks.dbo.dimcustomerssbid ssbid
						ON ssbid.DimCustomerId = d.DimCustomerId
					JOIN Ducks.dbo.DimDate dd
						ON dd.DimDateId = fts.DimDateId
					WHERE 1=1 --dd.CalDate >= (GETDATE() - 30)
					AND fts.DimSeatTypeId IN(2,6)
					AND fts.DimSeasonId = 27
					AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
						OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
						OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
						OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
						OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
					AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
					AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
					GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID	

					union


					SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID, MAX(CASE WHEN( (fts.QtySeat <= 7 AND  fts.revenuetotal >= 150 AND fts.dimtickettypeID NOT IN(2,8,10)) or (fts.qtyseat <= 5  AND fts.revenuetotal >= 150 AND fts.dimtickettypeid =12) )  THEN fts.OrderDate ELSE null END) AS New_Business_Lead
					FROM Ducks.dbo.FactTicketSales_V2 fts
					JOIN ducks.dbo.DimTicketCustomer_V2 t
						ON t.dimticketcustomerID = fts.DimTicketCustomerId
					JOIN ducks.dbo.DimCustomer d
						ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
					JOIN ducks.dbo.dimcustomerssbid ssbid
						ON ssbid.DimCustomerId = d.DimCustomerId
					JOIN Ducks.dbo.DimDate dd
						ON dd.DimDateId = fts.DimDateId
					WHERE 1=1 --dd.CalDate >= (GETDATE() - 30)
					AND fts.DimSeatTypeId IN(2,6)
					AND fts.DimSeasonId = 27
					AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
						OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
						OR d.EmailPrimary NOT LIKE '%@the-rinks.com'
						OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
						OR d.EmailPrimary NOT LIKE '%@ticketmaster.com' 
						OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
					AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
						AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')
					GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID	
					
					) x
					GROUP BY x.SSB_CRMSYSTEM_CONTACT_ID	
				)b
ON a.SSB_CRMSYSTEM_CONTACT_ID =b.SSB_CRMSYSTEM_CONTACT_ID




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																											---Eloqua Details----
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Eloqua Ticket Information

SELECT distinct  ssbid.SSB_CRMSYSTEM_CONTACT_ID, C.ID
INTO  #WebVisitDate
FROM ducks.[ods].[Eloqua_ActivityWebVisit] wv
JOIN ducks.[ods].[Eloqua_Contact] c
	ON wv.ContactId = c.ID
JOIN ducks.dbo.dimcustomerssbid ssbid
	ON ssbid.ssid = c.id AND ssbid.SourceSystem = 'Eloqua'
WHERE 1=1 --wv.CreatedAt >= (GETDATE() - 30)



SELECT distinct  ssbid.SSB_CRMSYSTEM_CONTACT_ID, wv.ID
INTO  #TicketTypeCriteria
FROM Ducks.dbo.FactTicketSales_V2 fts
	JOIN ducks.dbo.DimTicketCustomer_V2 t
		ON t.dimticketcustomerID = fts.DimTicketCustomerId
	JOIN ducks.dbo.DimCustomer d
		ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
	JOIN ducks.dbo.dimcustomerssbid ssbid
		ON ssbid.DimCustomerId = d.DimCustomerId
	JOIN #WebVisitDate wv
		ON wv.SSB_CRMSYSTEM_CONTACT_ID = ssbid.SSB_CRMSYSTEM_CONTACT_ID
	JOIN Ducks.dbo.DimDate dd
		ON dd.DimDateId = fts.DimDateId
	JOIN ducks.dbo.DimTicketType_V2 tt
		ON tt.DimTicketTypeId = fts.DimTicketTypeId
	WHERE 1=1 --dd.CalDate >= (GETDATE() - 30)
	AND fts.DimTicketTypeId NOT IN (2,3,4,9)
	AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
		OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
		OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
		OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
		OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
		OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
	AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
		AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')




SELECT  ssbid.SSB_CRMSYSTEM_CONTACT_ID, wv.CreatedAt
INTO   #URL
FROM #TicketTypeCriteria tt
JOIN ducks.[ods].[Eloqua_Contact] c
	ON C.Id = TT.id
JOIN ducks.[ods].[Eloqua_ActivityWebVisit] wv
	ON wv.ContactId = c.ID
JOIN ducks.dbo.dimcustomerssbid ssbid
	ON ssbid.SSB_CRMSYSTEM_CONTACT_ID = tt.SSB_CRMSYSTEM_CONTACT_ID
WHERE wv.firstpageviewurl IN ('https://www.nhl.com/ducks/tickets/season-tickets'
,'https://www.nhl.com/ducks/tickets/seating-map-pricing'
,'https://www.nhl.com/ducks/tickets/dedication-program'
,'https://www.nhl.com/ducks/tickets/request-more-ticketing-info'
,'https://www.nhl.com/ducks/tickets/mini-plans'
,'https://www.nhl.com/ducks/tickets/mini-plans/weekend'
,'https://duckshondacenter.formstack.com/forms/13gameweekendplan_201718'
,'https://www.nhl.com/ducks/tickets/mini-plans/15-game-pick-em'
,'https://duckshondacenter.formstack.com/forms/15gamepickemplan201718'
,'https://www.nhl.com/ducks/tickets/mini-plans/12-game-gold'
,'https://duckshondacenter.formstack.com/forms/12gamegoldplan_201718'
,'https://www.nhl.com/ducks/tickets/mini-plans/12-game-orange'
,'https://duckshondacenter.formstack.com/forms/12gameorangeplan_201718 '
,'https://www.nhl.com/ducks/tickets/mini-plans/22-game-half-season'
,'https://duckshondacenter.formstack.com/forms/22gamehalfseasonplan_201718'
,'https://www.nhl.com/ducks/tickets/miniplans-24gamepickem'
,'https://duckshondacenter.formstack.com/forms/24gamepickemplan201718'
,'https://www.nhl.com/ducks/tickets/partial-sth-terms-and-conditions'
,'https://www.nhl.com/ducks/tickets/micro-plans'
,'https://duckshondacenter.formstack.com/forms/hall_of_fame_pack'
,'https://duckshondacenter.formstack.com/forms/hall_of_fame_flex_plan'
,'https://www.nhl.com/ducks/tickets/group-opportunities'
,'https://www.nhl.com/ducks/tickets/group-seating'
,'https://www.nhl.com/ducks/tickets/group-theme-nights-2017-18'
,'https://www.nhl.com/ducks/tickets/group-tickets-fundraising'
,'https://www.nhl.com/ducks/tickets/group-tickets-faqs'
,'https://www.nhl.com/ducks/tickets/request-more-group-information')
and 1=1 --wv.createdat >= (GETDATE() - 30)
GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID,wv.CreatedAt



UPDATE a 
SET a.new_ssb_EloquaTicketInformation  = CAST(x.Eloqua_Ticket_Information AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN ( SELECT SSB_CRMSYSTEM_CONTACT_ID, MAX(CreatedAt) as Eloqua_Ticket_Information
			 FROM #URL
			 GROUP BY SSB_CRMSYSTEM_CONTACT_ID)x
ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID


--2870
--SELECT COUNT(new_ssb_NewBusinessLead) FROM dbo.Contact_Custom
--WHERE new_ssb_NewBusinessLead  IS NOT NULL
--29
--SELECT COUNT(new_ssb_GroupSalesLead) FROM dbo.Contact_Custom
--WHERE new_ssb_GroupSalesLead  IS NOT NULL
--269
--SELECT COUNT(new_ssb_EloquaTicketInformation) FROM dbo.Contact_Custom
--WHERE new_ssb_EloquaTicketInformation  IS NOT NULL
--500
--SELECT COUNT(new_ssb_EloquaPromotionalInformation) FROM dbo.Contact_Custom
--WHERE new_ssb_EloquaPromotionalInformation  IS NOT NULL
--186
--SELECT COUNT(new_ssb_EloquaPremiumInformation) FROM dbo.Contact_Custom
--WHERE new_ssb_EloquaPremiumInformation  IS NOT NULL
--0
--SELECT COUNT(new_ssb_EmailActivity) FROM dbo.Contact_Custom
--WHERE new_ssb_EmailActivity  IS NOT NULL
--14
--SELECT COUNT(new_ssb_NewPremiumLead) FROM dbo.Contact_Custom
--WHERE new_ssb_NewPremiumLead  IS NOT NULL
--4
--SELECT COUNT(new_ssb_HondaGroupSalesLead) FROM dbo.Contact_Custom
--WHERE new_ssb_HondaGroupSalesLead  IS NOT null




--------------------------------Eloqu Promotional Infomration----------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  ssbid.SSB_CRMSYSTEM_CONTACT_ID, C.ID
INTO  #PromoWebVisitDate
FROM ducks.[ods].[Eloqua_ActivityWebVisit] wv
JOIN ducks.[ods].[Eloqua_Contact] c
	ON wv.ContactId = c.ID
JOIN ducks.dbo.dimcustomerssbid ssbid
	ON ssbid.ssid = c.id AND ssbid.SourceSystem = 'Eloqua'
WHERE 1=1 --wv.CreatedAt >= (GETDATE() - 30)



SELECT distinct  ssbid.SSB_CRMSYSTEM_CONTACT_ID, wv.ID
INTO  #PromoTicketTypeCriteria
FROM Ducks.dbo.FactTicketSales_V2 fts
	JOIN ducks.dbo.DimTicketCustomer_V2 t
		ON t.dimticketcustomerID = fts.DimTicketCustomerId
	JOIN ducks.dbo.DimCustomer d
		ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
	JOIN ducks.dbo.dimcustomerssbid ssbid
		ON ssbid.DimCustomerId = d.DimCustomerId
	JOIN #PromoWebVisitDate wv
		ON wv.SSB_CRMSYSTEM_CONTACT_ID = ssbid.SSB_CRMSYSTEM_CONTACT_ID
	JOIN Ducks.dbo.DimDate dd
		ON dd.DimDateId = fts.DimDateId
	JOIN ducks.dbo.DimTicketType_V2 tt
		ON tt.DimTicketTypeId = fts.DimTicketTypeId
	WHERE 1=1 -- dd.CalDate >= (GETDATE() - 30)
	AND fts.DimTicketTypeId NOT IN (2,3,4,9) 
	AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
		OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
		OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
				OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
		OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
		OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
	AND d.AddressPrimaryStreet <> '2695 E Katella Ave'
		AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')


SELECT  ssbid.SSB_CRMSYSTEM_CONTACT_ID, wv.createdat
INTO   #PromoURL
FROM #TicketTypeCriteria tt
JOIN ducks.[ods].[Eloqua_Contact] c
	ON C.Id = TT.id
JOIN ducks.[ods].[Eloqua_ActivityWebVisit] wv
	ON wv.ContactId = c.ID
JOIN ducks.dbo.dimcustomerssbid ssbid
	ON ssbid.SSB_CRMSYSTEM_CONTACT_ID = tt.SSB_CRMSYSTEM_CONTACT_ID
WHERE (wv.firstpageviewurl IN('https://www.nhl.com/ducks/tickets/promo-packs'
,'https://www.nhl.com/ducks/schedule/2017-10-01/PT'
,'https://www.nhl.com/ducks/schedule/2017-10-01/PT/list'
,'https://www.nhl.com/ducks/schedule/2017-11-01/PT'
,'https://www.nhl.com/ducks/schedule/2017-11-01/PT/list'
,'https://www.nhl.com/ducks/schedule/2017-12-01/PT'
,'https://www.nhl.com/ducks/schedule/2017-12-01/PT/list'
,'https://www.nhl.com/ducks/schedule/2018-01-01/PT'
,'https://www.nhl.com/ducks/schedule/2018-01-01/PT/list'
,'https://www.nhl.com/ducks/schedule/2018-02-01/PT'
,'https://www.nhl.com/ducks/schedule/2018-02-01/PT/list'
,'https://www.nhl.com/ducks/schedule/2018-03-01/PT'
,'https://www.nhl.com/ducks/schedule/2018-03-01/PT/list'
,'https://www.nhl.com/ducks/schedule/2018-04-01/PT'
,'https://www.nhl.com/ducks/schedule/2018-04-01/PT/list'
,'https://www.nhl.com/ducks/fans/promo-schedule'
,'https://www.nhl.com/ducks/tickets'
,'https://www.nhl.com/ducks/tickets/single-game-tickets'
,'https://www1.ticketmaster.com/'
,'https://www.ticketmaster.com/ ')
OR (wv.firstpageviewurl LIKE '%Ticketmaster.com%' AND (wv.firstpageviewurl LIKE '%did=beer%' OR wv.firstpageviewurl LIKE '%did=soda%')))
AND 1=1 --wv.CreatedAt >= (GETDATE() - 30)

GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID,wv.CreatedAt



UPDATE a 
SET a.new_ssb_EloquaPromotionalInformation  = CAST(x.Eloqua_Promotional_information AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN ( SELECT SSB_CRMSYSTEM_CONTACT_ID, MAX(createdat) Eloqua_Promotional_information
			 FROM #PromoURL
			 GROUP BY SSB_CRMSYSTEM_CONTACT_ID)x
ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID



--------------------------------Eloqua Premium Infomration----------------------------------------------------------------------------------------------------------------------------------

SELECT distinct  ssbid.SSB_CRMSYSTEM_CONTACT_ID, C.ID, wv.CreatedAt
INTO  #PremiumWebVisitDate
FROM ducks.[ods].[Eloqua_ActivityWebVisit] wv
JOIN ducks.[ods].[Eloqua_Contact] c
	ON wv.ContactId = c.ID
JOIN ducks.dbo.dimcustomerssbid ssbid
	ON ssbid.ssid = c.id AND ssbid.SourceSystem = 'Eloqua'
WHERE 1=1 --wv.CreatedAt >= (GETDATE() - 30)
and wv.firstpageviewurl IN('http://www.hondacenter.com/premium-seating/luxury-suites/'
,'http://www.hondacenter.com/premium-seating/club-seats/'
,'http://www.hondacenter.com/premium-seating/ducks-rental-suites/'
,'http://www.hondacenter.com/premium-seating/premium-perks/'
,'http://www.hondacenter.com/premium-seating/seating-map/')


union

SELECT distinct  ssbid.SSB_CRMSYSTEM_CONTACT_ID, C.ID, fs.CreatedAt
FROM ducks.ods.Eloqua_ActivityFormSubmit fs
JOIN ducks.[ods].[Eloqua_Contact] c
	ON fs.ContactId = c.ID
JOIN ducks.dbo.dimcustomerssbid ssbid
	ON ssbid.ssid = c.id AND ssbid.SourceSystem = 'Eloqua'
WHERE 1=1 --fs.CreatedAt >= (GETDATE() - 30)
AND fs.assetname IN('Ducks_BetweenBenches_Interest_2017.09.15' ,'Ducks_SuiteMiniPlans_2017.08.16') --need to add in the form submittes associated to the URLs below
--,'http://www.hondacenter.com/premium-seating/premium-seating-experience'
--,'http://www.hondacenter.com/premium-seating/my-account/')




SELECT DISTINCT  ssbid.SSB_CRMSYSTEM_CONTACT_ID, wv.createdat
INTO  #PremiumTicketTypeCriteria
FROM Ducks.dbo.FactTicketSales_V2 fts
	JOIN ducks.dbo.DimTicketCustomer_V2 t
		ON t.dimticketcustomerID = fts.DimTicketCustomerId
	JOIN ducks.dbo.DimCustomer d
		ON CAST(d.AccountId AS NVARCHAR(255)) = t.ETL__SSID AND d.SourceSystem = t.ETL__SourceSystem AND d.CustomerType = 'Primary'
	JOIN ducks.dbo.dimcustomerssbid ssbid
		ON ssbid.DimCustomerId = d.DimCustomerId
	JOIN #PremiumWebVisitDate wv
		ON wv.SSB_CRMSYSTEM_CONTACT_ID = ssbid.SSB_CRMSYSTEM_CONTACT_ID
	JOIN Ducks.dbo.DimDate dd
		ON dd.DimDateId = fts.DimDateId
	JOIN ducks.dbo.DimTicketType_V2 tt
		ON tt.DimTicketTypeId = fts.DimTicketTypeId
	WHERE 1=1 -- dd.CalDate >= (GETDATE() - 30)
	AND fts.DimTicketTypeId NOT IN (2,4)
	AND (d.EmailPrimary NOT LIKE '%@anaheimducks.com' 
		OR d.EmailPrimary NOT LIKE '%@hondacenter.com' 
		OR d.EmailPrimary NOT LIKE '%@the-rinks.com' 
				OR d.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
		OR d.EmailPrimary NOT LIKE '%@ticketmaster.com'
		OR  d.EmailPrimary NOT LIKE '%@hsventures.org')
	AND d.AddressPrimaryStreet <> '2695 E Katella Ave'  
		AND d.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')


UPDATE a 
SET a.new_ssb_EloquaPremiumInformation  = CAST(x.Eloqua_Premium_information AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN ( SELECT SSB_CRMSYSTEM_CONTACT_ID, MAX(createdat) Eloqua_Premium_information
			 FROM #PremiumTicketTypeCriteria
			 GROUP BY SSB_CRMSYSTEM_CONTACT_ID)x
ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID




--------------------------------Eloqua Form Submission----------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT  ssbid.SSB_CRMSYSTEM_CONTACT_ID, C.ID, fs.CreatedAt
INTO  #FormSubmissionWebVisitDate
FROM ducks.[ods].[Eloqua_ActivityFormSubmit] fs
JOIN ducks.[ods].[Eloqua_Contact] c
	ON fs.ContactId = c.ID
JOIN ducks.dbo.vwDimCustomer_ModAcctId ssbid
	ON ssbid.ssid = c.id AND ssbid.SourceSystem = 'Eloqua'
WHERE 1=1 --fs.CreatedAt >= (GETDATE() - 30)
AND fs.AssetName = 'Ducks_Schedule_Relase_Boost_TicketInterest_2017.06.22'
AND (ssbid.EmailPrimary NOT LIKE '%@anaheimducks.com' 
	OR ssbid.EmailPrimary NOT LIKE '%@hondacenter.com' 
	OR ssbid.EmailPrimary NOT LIKE '%@the-rinks.com' 
			OR ssbid.EmailPrimary NOT LIKE '%@ticketexchangebyticketmaster.com'
		OR ssbid.EmailPrimary NOT LIKE '%@ticketmaster.com'
	OR  ssbid.EmailPrimary NOT LIKE '%@hsventures.org')
AND ssbid.AddressPrimaryStreet <> '2695 E Katella Ave'
	AND SSBID.PhonePrimary NOT IN('(714) 940-2900','(877) 945-3946')

UPDATE a 
SET a.new_ssb_EloquaFormSubmission= CAST(x.Eloqua_Form_Submission AS DATE)
FROM dbo.Contact_Custom a
INNER JOIN ( SELECT SSB_CRMSYSTEM_CONTACT_ID, MAX(CreatedAt) Eloqua_Form_Submission
			 FROM #FormSubmissionWebVisitDate
			 GROUP BY SSB_CRMSYSTEM_CONTACT_ID)x
ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID



--------------------------------Eloqua Email Activity----------------------------------------------------------------------------------------------------------------------------------
--UPDATE a 
--SET a.new_ssb_EmailActivity= x.EmailActivity
--FROM dbo.Contact_Custom a
--INNER JOIN ( )x
--ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																											---NULL Lead Values where STH----
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------







IF OBJECT_ID('tempdb.Ducks.#STH2017')IS NOT NULL DROP TABLE #STH2017
SELECT DISTINCT SSB_CRMSYSTEM_CONTACT_ID
INTO #STH2017
FROM ducks.dbo.vwDimCustomer_ModAcctId m
JOIN ducks.dbo.FactTicketSales_V2 f
ON f.ETL__SSID_TM_acct_id = m.AccountId AND m.CustomerType = 'primary' AND sourcesystem = 'TM'
WHERE f.DimTicketTypeId IN (2,8,10)
AND f.DimSeasonId = 27




UPDATE contact_custom 
SET new_ssb_NewBusinessLead				= NULL
, new_ssb_GroupSalesLead				 = NULL
, new_ssb_EloquaTicketInformation		 = NULL
, new_ssb_EloquaPromotionalInformation = NULL
, new_ssb_EloquaPremiumInformation		= NULL
, new_ssb_EloquaFormSubmission			= NULL
, new_ssb_NewPremiumLead				= NULL
, new_ssb_EmailActivity					= NULL
FROM dbo.Contact_Custom c
JOIN #STH2017 s
ON s.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																											---TM Acct Type----
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID('tempdb.Ducks.#sourcepriorityranking')IS NOT NULL DROP TABLE #sourcepriorityranking
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY x.SSB_CRMSYSTEM_CONTACT_ID ORDER BY x.SourceSystemPriority desc) sourcerank
INTO #sourcepriorityranking
FROM (
SELECT d.DimCustomerId
      ,d.SSB_CRMSYSTEM_CONTACT_ID
      ,d.AccountId
      ,d.AccountType
        , CASE WHEN  d.SourceSystem = 'TM' THEN 99
               WHEN  d.SourceSystem = 'CRM_Contact' THEN 89
               WHEN  d.SourceSystem = 'CRM_Account' THEN 79
               WHEN  d.SourceSystem = 'Eloqua' THEN 69
               WHEN  d.SourceSystem = 'SkiData' THEN 59
               WHEN  d.SourceSystem = 'LiveAnalytics' THEN 49
               ELSE 0 END AS SourceSystemPriority
        ,d.UpdatedDate
        ,d.SourceSystem
--select count (*)
FROM dbo.vwDimCustomer_ModAcctId d --4364879
WHERE d.CustomerType = 'primary' AND d.SourceSystem = 'TM'
--GROUP BY d.DimCustomerId, d.EmailPrimary,d.SourceSystem
)x


--SELECT count(*) FROM #sourcepriorityranking


--SELECT SSB_CRMSYSTEM_CONTACT_ID, COUNT(*) 
--FROM #sourcepriorityranking
--WHERE SourceSystem = 'TM'
--GROUP BY SSB_CRMSYSTEM_CONTACT_ID
--HAVING COUNT(*)  >1
--ORDER BY SSB_CRMSYSTEM_CONTACT_ID



IF OBJECT_ID('tempdb.Ducks.#TMTicketRank')IS NOT NULL DROP TABLE #TMTicketRank
SELECT xx.DimCustomerId, xx.SSB_CRMSYSTEM_CONTACT_ID, xx.AccountId, 
CASE 
WHEN xx.AccountType = 'Broker' THEN 'Broker'
WHEN xx.AccountType in ('Canceled',	'Cancelled Club',	'Employee',	'H & S Ventures',	'Hockey Ops',	'House',	'League',	'Opt Out',	'Player',	'Sponsor') THEN 'CRM CRM' --'Acxiom',	'Comp',	'Marketing', 'Media Dept',	'Onyx',	'Premium',	'Representative',	'TM Host Import',	'Trickler'	
WHEN xx.AccountType IN ('Group',	'Group - Church',	'Group - College',	'Group - Military',	'Group - Nonprofi',	'Group - Outlets',	'Group - School',	'Group - Scouts') THEN 'Group'
WHEN xx.AccountType IN ('1 Year-Corp-CLB',	'1 Year-Pers-CLB',	'Auto - Corp-CLB',	'Auto - Pers-CLB',	'Corporate - CLUB',	'Corporate - SUIT',	'Personal - CLUB',	'Suite', 'Personal - SUITE') THEN 'Premium'
WHEN xx.AccountType IN ('1 Year - Corp',	'1 Year - Pers',	'Auto  - Corp',	'Auto - Personal',	'Corporate',	'Personal',  'Member - Pers', 'Marketing', 'Member - Corp', 'TM Host Import', 'Window Account') THEN 'SalesPerson'
ELSE NULL END AS AccountType
,PremiumSeason 
,MiniMicroGroup
,Single        
,ROW_NUMBER() OVER(PARTITION BY xx.ssb_crmsystem_contact_id ORDER BY xx.PremiumSeason desc,xx.MiniMicroGroup desc, xx.Single desc)TMTicketRank
INTO  #TMTicketRank
FROM (
SELECT DISTINCT d.DimCustomerId
      ,d.ssb_crmsystem_contact_id
      ,d.accountid
      ,d.AccountType
        
        , MAX(CASE WHEN f.DimTicketTypeId IN(2,8,10)AND f.DimSeasonId  IN(27,10) THEN 99 ELSE 0 END) AS PremiumSeason
        , MAX(CASE WHEN f.DimTicketTypeId IN(4,9) AND f.DimSeasonId  IN(27,10) THEN 89 ELSE 0 END) AS MiniMicroGroup
        , MAX(CASE WHEN f.DimTicketTypeId = 5 and f.DimSeasonId  IN(27,10) THEN 79 ELSE 0 END) AS Single
--select count (*)
FROM #sourcepriorityranking d --4364879
LEFT join ducks.dbo.FactTicketSales_v2 f
ON f.ETL__SSID_TM_acct_id = d.AccountId AND d.SourceSystem = 'TM' --1107337
LEFT JOIN ducks.dbo.DimSeason_V2 s
ON f.DimSeasonId = s.DimSeasonId
WHERE d.SourceSystem = 'TM'
AND d.DimCustomerId <>-1     --1107190
--AND d.AccountId = 17848333
GROUP BY d.DimCustomerId
      ,d.ssb_crmsystem_contact_id
      ,d.accountid
	  ,d.AccountType

) xx
--WHERE xx.SSB_CRMSYSTEM_CONTACT_ID = '1541CB9F-6846-4F32-BBA9-0003AD0B711B'
--ORDER BY 3

/*
IF OBJECT_ID('tempdb.Ducks.#TMRanks')IS NOT NULL DROP TABLE #TMRanks
SELECT t.DimCustomerID                  as Ticket_DimCustomerID,    
       t.SSB_CRMSYSTEM_CONTACT_ID       as Ticket_SSB_CRMSYSTEM_CONTACT_ID,
       t.AccountID                      as Ticket_AccountId,
       t.AccountType                    AS Ticket_AccountType,
       t.PremiumSeason                  as Ticket_PremiumSeason,
       t.MiniMicroGroup                 as Ticket_MiniMicroGroup,
       t.Single                         as Ticket_Single,
       t.TMTicketRank                   as Ticket_TMTicketRank,
       s.DimCustomerId                  as Source_DimCustomerId,
       s.SSB_CRMSYSTEM_CONTACT_ID       as Source_SSB_CRMSYSTEM_CONTACT_ID,
       s.AccountId                      as Source_AccountId,
       s.AccountType                    AS source_AccountType,
       s.SourceSystemPriority           as Source_SourceSystemPriority,
       s.UpdatedDate                    as Source_UpdatedDate,
       s.SourceSystem                   as Source_SourceSystem,
       s.sourcerank                     as Source_sourcerank,
ROW_NUMBER() OVER(PARTITION BY t.ssb_crmsystem_contact_id ORDER BY t.PremiumSeason desc,t.MiniMicroGroup desc, t.Single desc)TMwinner
INTO  #TMRanks
FROM #TMTicketRank t
JOIN #sourcepriorityranking s
ON s.SSB_CRMSYSTEM_CONTACT_ID = t.SSB_CRMSYSTEM_CONTACT_ID AND s.SourceSystem = 'tm'
*/



--------------------------------Archtics Reps----------------------------------------------------------------------------------------------------------------------------------

UPDATE Ducks_Reporting.prodcopy.SystemUser SET fullname = 'Michael Munoz' FROM Ducks_Reporting.prodcopy.SystemUser WHERE systemuserid = '13067DE1-E076-E711-8113-5065F38A7BF1'



----Start Fresh
UPDATE dbo.Contact_Custom SET ownerid = NULL, owneridtype = NULL


--BUILD TEMP TABLE
--SELECT tmcr.acct_id, tmcr.rep_user_id, ma.SSB_CRMSYSTEM_CONTACT_ID, tmcr.acct_rep_type, tmcr.acct_rep_type_name, tmcr.rep_full_name 
--, su.systemuserid, ma.SSCreatedDate
--INTO #UserTemp
--FROM ducks.ods.TM_CustRep tmcr
--INNER JOIN dbo.vwDimCustomer_ModAcctId ma ON ma.accountid = tmcr.acct_id AND ma.sourcesystem = 'tm' and ma.CustomerType = 'primary'
--INNER JOIN ducks_reporting.prodcopy.SystemUser su ON su.new_tmuserid  = tmcr.rep_user_id  --add back in once prodcopy is updated
--WHERE tmcr.rep_user_id IS NOT NULL
--AND tmcr.acct_rep_type_name = 'sales rep'
--AND su.isdisabled = 0
IF OBJECT_ID('tempdb.Ducks.#UserTemp')IS NOT NULL DROP TABLE #UserTemp
SELECT tmcr.acct_id, tmcr.rep_user_id, ma.SSB_CRMSYSTEM_CONTACT_ID, tmcr.acct_rep_type, tmcr.acct_rep_type_name, tmcr.rep_full_name, tmcr.rep_name_first, tmcr.rep_name_last
, ISNULL(ISNULL(su.systemuserid,suname.systemuserid),suemail.systemuserid) AS systemuserid, ma.SSCreatedDate
INTO #UserTemp
FROM ducks.ods.TM_CustRep tmcr
INNER JOIN dbo.vwDimCustomer_ModAcctId ma ON ma.accountid = tmcr.acct_id AND ma.sourcesystem = 'tm' and ma.CustomerType = 'primary'
left JOIN ducks_reporting.prodcopy.SystemUser su ON su.new_tmuserid  = tmcr.rep_user_id  --add back in once prodcopy is updated
LEFT JOIN ducks_reporting.prodcopy.SystemUser suname ON suname.fullname = tmcr.rep_name_first + ' ' + tmcr.rep_name_last
LEFT JOIN ducks_reporting.prodcopy.systemuser suemail ON ISNULL(suemail.internalemailaddress,'') = ISNULL(tmcr.rep_email_addr,'') AND isnull(su.internalemailaddress,'') != '' 
WHERE 1=1
AND tmcr.acct_rep_type_name = 'sales rep'



IF OBJECT_ID('tempdb.Ducks.#RankingByType')IS NOT NULL DROP TABLE #RankingByType
SELECT ut.SSB_CRMSYSTEM_CONTACT_ID, tmtr.AccountType, ut.rep_user_id, ut.rep_full_name, ut.systemuserid,ut.rep_name_first,ut.rep_name_last, tmtr.TMTicketRank, ROW_NUMBER() OVER(PARTITION BY ut.SSB_CRMSYSTEM_CONTACT_ID, tmtr.AccountType order BY  tmtr.TMTicketRank, sscreateddate) xrank
INTO  #RankingByType
FROM #UserTemp ut
INNER JOIN #TMTicketRank tmtr
ON tmtr.AccountId = ut.acct_id



IF OBJECT_ID('tempdb.Ducks.#group')IS NOT NULL DROP TABLE #group
SELECT DISTINCT rbt.SSB_CRMSYSTEM_CONTACT_ID,rbt.accounttype, rbt.systemuserid , rbt.TMTicketRank, rbt.Xrank, su.fullname--, c.crm_id, pcc.new_groupssalespersonname
INTO  #group
FROM #RankingByType rbt
JOIN ducks_reporting.prodcopy.SystemUser su 
ON su.systemuserid  = rbt.systemuserid  --add back in once prodcopy is updated
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = rbt.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN dbo.Contact_Custom cc
ON cc.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN ducks_reporting.prodcopy.teammembership mem
ON su.systemuserid = mem.systemuserid
INNER JOIN ducks_reporting.prodcopy.team team
ON team.teamid = mem.teamid
INNER JOIN ducks_reporting.prodcopy.contact pcc 
ON CAST(pcc.contactid AS NVARCHAR(100)) = c.crm_id
WHERE rbt.AccountType = 'Group' 
AND rbt.xrank = 1
AND team.name IN (
'Group',
'Ticket',
'Service',
'Premium'
)


IF OBJECT_ID('tempdb.Ducks.#premium')IS NOT NULL DROP TABLE #premium
SELECT DISTINCT rbt.*, su.fullname, c.crm_id, pcc.str_clientpremiumsalespersonname
INTO #premium
FROM #RankingByType rbt
JOIN ducks_reporting.prodcopy.SystemUser su 
ON su.systemuserid  = rbt.systemuserid
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = rbt.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN dbo.Contact_Custom cc
ON cc.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN ducks_reporting.prodcopy.teammembership mem
ON su.systemuserid = mem.systemuserid
INNER JOIN ducks_reporting.prodcopy.team team
ON team.teamid = mem.teamid
INNER JOIN ducks_reporting.prodcopy.contact pcc 
ON CAST(pcc.contactid AS NVARCHAR(100)) = c.crm_id
WHERE rbt.AccountType = 'Premium'
AND rbt.xrank = 1
AND team.name IN (
'Group',
'Ticket',
'Service',
'Premium'
)

IF OBJECT_ID('tempdb.Ducks.#salesperson')IS NOT NULL DROP TABLE #salesperson
SELECT DISTINCT rbt.*, su.fullname,  c.crm_id, pcc.owneridname
INTO  #salesperson
FROM #RankingByType rbt
JOIN ducks_reporting.prodcopy.SystemUser su 
ON su.systemuserid  = rbt.systemuserid
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = rbt.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN dbo.Contact_Custom cc
ON cc.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN ducks_reporting.prodcopy.teammembership mem
ON su.systemuserid = mem.systemuserid
INNER JOIN ducks_reporting.prodcopy.team team
ON team.teamid = mem.teamid
INNER JOIN ducks_reporting.prodcopy.contact pcc 
ON CAST(pcc.contactid AS NVARCHAR(100)) = c.crm_id
WHERE rbt.AccountType = 'SalesPerson'
AND rbt.xrank = 1
AND team.name IN (
'Group',
'Ticket',
'Service',
'Premium'
)


--Update and make sure that ownerid follows the gropu or premium as well.
UPDATE dbo.Contact_Custom
SET new_groupssalesperson = sp.systemuserid, ownerid = sp.systemuserid
FROM dbo.Contact_Custom cc
inner JOIN #group sp
ON sp.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

UPDATE dbo.Contact_Custom
SET str_clientpremiumsalesperson = sp.systemuserid, ownerid = sp.systemuserid
FROM dbo.Contact_Custom cc
inner JOIN #premium sp
ON sp.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

UPDATE dbo.Contact_Custom
SET ownerid = sp.systemuserid
FROM dbo.Contact_Custom cc
inner JOIN #salesperson sp
ON sp.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID

--NULL OUT WHERE Group/Premium has dropped off
UPDATE dbo.Contact_Custom
SET new_groupssalesperson = sp.systemuserid
FROM dbo.Contact_Custom cc
left JOIN #group sp
ON sp.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
WHERE sp.systemuserid IS null

UPDATE dbo.Contact_Custom
SET str_clientpremiumsalesperson = sp.systemuserid
FROM dbo.Contact_Custom cc
left JOIN #premium sp
ON sp.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
WHERE sp.systemuserid IS null





--Update contact_custom where TM has no value.
UPDATE contact_custom 
SET ownerid = pcc.ownerid
FROM contact_custom cc
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.Contact pcc
ON c.crm_id = CAST(pcc.contactid AS NVARCHAR(100))
WHERE cc.ownerid IS NULL



--Now potentially update with whatever valid user is already in the field in CRM (don't overwrite CRM if valid user)
--Update contact_custom where TM has no value.
UPDATE contact_custom 
SET ownerid = su.systemuserid
--select cc.*
FROM contact_custom cc
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.Contact pcc
ON c.crm_id = CAST(pcc.contactid AS NVARCHAR(100))
INNER JOIN Ducks_Reporting.prodcopy.SystemUser su
ON pcc.ownerid = su.systemuserid
INNER JOIN ducks_reporting.prodcopy.teammembership mem
ON su.systemuserid = mem.systemuserid
INNER JOIN ducks_reporting.prodcopy.team team
ON team.teamid = mem.teamid
WHERE cc.ownerid != pcc.ownerid
AND team.name IN (
'Group',
'Ticket',
'Service',
'Premium'
) AND (su.fullname != 'CRM CRM' and su.fullname != '# CRM SSB')
AND su.isdisabled = 0


UPDATE contact_custom 
SET new_groupssalesperson = su.systemuserid
FROM contact_custom cc
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.Contact pcc
ON c.crm_id = CAST(pcc.contactid AS NVARCHAR(100))
INNER JOIN Ducks_Reporting.prodcopy.SystemUser su
ON pcc.new_groupssalesperson = su.systemuserid
INNER JOIN ducks_reporting.prodcopy.teammembership mem
ON su.systemuserid = mem.systemuserid
INNER JOIN ducks_reporting.prodcopy.team team
ON team.teamid = mem.teamid
WHERE cc.ownerid != pcc.ownerid
AND team.name IN (
'Group',
'Ticket',
'Service',
'Premium'
) AND (su.fullname != 'CRM CRM' and su.fullname != '# CRM SSB')
AND su.isdisabled = 0

UPDATE contact_custom 
SET str_clientpremiumsalesperson = su.systemuserid
FROM contact_custom cc
INNER JOIN dbo.Contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.Contact pcc
ON c.crm_id = CAST(pcc.contactid AS NVARCHAR(100))
INNER JOIN Ducks_Reporting.prodcopy.SystemUser su
ON pcc.str_clientpremiumsalesperson = su.systemuserid
INNER JOIN ducks_reporting.prodcopy.teammembership mem
ON su.systemuserid = mem.systemuserid
INNER JOIN ducks_reporting.prodcopy.team team
ON team.teamid = mem.teamid
WHERE cc.ownerid != pcc.ownerid
AND team.name IN (
'Group',
'Ticket',
'Service',
'Premium'
) AND (su.fullname != 'CRM CRM' and su.fullname != '# CRM SSB')
AND su.isdisabled = 0



--default for new records being created that don't have an owner --Process Load Criteria sproc must run before this in order for this to work.
UPDATE contact_custom 
SET ownerid = '216B86D6-9677-E711-8113-5065F38A7BF1'
--SELECT COUNT(*)
 FROM contact_custom cc
INNER JOIN dbo.CRMLoad_Contact_ProcessLoad_Criteria pl
ON pl.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
WHERE pl.LoadType = 'upsert' AND cc.ownerid IS NULL




--must be a systemuser to successfully update
UPDATE contact_custom SET owneridtype = 'systemuser' WHERE ownerid IS NOT NULL





/*========================
STR Eloqua Rollup Field'E4F26034-D73F-43F6-AC43-219B8C1AB913's
========================*/

 SELECT SSB_CRMSYSTEM_CONTACT_ID, new_ssb_EloquaTicketInformation AS eloquadate, 'Ticket Information' AS [str_clientrecenteloquainfo]
 INTO #eloquarecenttable
 FROM contact_custom
UNION SELECT SSB_CRMSYSTEM_CONTACT_ID,new_ssb_EloquaPromotionalInformation, 'Promotional Information'		FROM contact_custom
UNION SELECT SSB_CRMSYSTEM_CONTACT_ID,new_ssb_EloquaPremiumInformation, 'Premium Information'	FROM contact_custom
UNION SELECT SSB_CRMSYSTEM_CONTACT_ID,new_ssb_EloquaFormSubmission,	'Form Submission'			FROM contact_custom
UNION SELECT SSB_CRMSYSTEM_CONTACT_ID,new_ssb_EmailActivity, 'Email Activity'						FROM contact_custom 


 SELECT ssb_crmsystem_contact_id, MAX(eloquadate) AS str_clientrecenteloquadate
 INTO #str_clientrecenteloquadate
 FROM #eloquarecenttable
GROUP BY ssb_crmsystem_contact_id


UPDATE dbo.Contact_Custom
SET str_clientrecenteloquadate = s.str_clientrecenteloquadate
FROM dbo.contact_custom cc
INNER JOIN #str_clientrecenteloquadate s
ON s.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID           

   
                       
UPDATE dbo.Contact_Custom
SET [str_clientrecenteloquainfo] = rt.str_clientrecenteloquainfo
FROM contact_custom cc
LEFT JOIN #eloquarecenttable rt
ON rt.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
AND cc.str_clientrecenteloquadate = rt.eloquadate



/*========================
Distance from Arena
========================*/


UPDATE cc
SET new_distancefromarena = x.[distance from Honda Center]
FROM dbo.Contact_Custom cc
INNER JOIN (SELECT  * FROM ducks.mdm.compositerecord c
JOIN ducks.ods.Distance_from_arena_lookup l
ON l.[zip code] = c.AddressPrimaryZip) x ON x.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID


--SELECT cc.ssb_crmsystem_contact_id,
--CASE WHEN ISNULL(dimcustomer.AddressPrimaryLatitude, '') <> '' AND ISNULL(dimcustomer.AddressPrimaryLongitude, '') <> ''
--				THEN geography::Point(dimcustomer.AddressPrimaryLatitude, dimcustomer.AddressPrimaryLongitude, 4326).STDistance(geography::Point(dist_att.Latitude, dist_att.Longitude, 4326)) / 1609.344
--				END AS Distance_From_HondaCenter 
--INTO #distance				 
--FROM ducks.dbo.DimCustomer dimcustomer WITH ( NOLOCK )
--                JOIN ducks.dbo.dimcustomerssbid ssbid WITH ( NOLOCK ) ON ssbid.DimCustomerId = dimcustomer.DimCustomerId
--				JOIN dbo.Contact_Custom cc WITH (NOLOCK) ON cc.SSB_CRMSYSTEM_CONTACT_ID = ssbid.SSB_CRMSYSTEM_CONTACT_ID
--				JOIN ducks.ods.Distances dist_att ON dist_att.[Location] = 'Honda Center'
-- WHERE ssbid.SSB_CRMSYSTEM_PRIMARY_FLAG = 1



--UPDATE cc
--SET new_distancefromarena = d.Distance_From_HondaCenter 
--FROM dbo.Contact_Custom cc
--INNER JOIN #distance d
--ON cc.SSB_CRMSYSTEM_CONTACT_ID = d.SSB_CRMSYSTEM_CONTACT_ID



/*========================
Data Uploader TIcket interest fields
========================*/

 EXEC ducks.[etl].[Dimcustomer_Attributes_Pivot]


 IF OBJECT_ID('tempdb.Ducks.#datauploaderfields')IS NOT NULL DROP TABLE #datauploaderfields
SELECT m.SSB_CRMSYSTEM_CONTACT_ID, a.Dimcustomerid,
                                  a.SSID,
                                  a.SOURCESYSTEM,
                                  CASE WHEN a.FanNewsletterOptIn = 'YES' THEN 1 WHEN a.FanNewsletterOptIn = 'No' THEN 0 ELSE NULL END FanNewsletterOptIn,
                                  CASE WHEN  a.GroupInterest = 'YES' THEN 1 WHEN a.GroupInterest = 'No' THEN 0 ELSE NULL END GroupInterest,
                                  CASE WHEN a.MiniPlanInterest = 'YES' THEN 1 WHEN a.MiniPlanInterest = 'No' THEN 0 ELSE NULL END MiniPlanInterest,
                                  CASE WHEN a.SingleGameTicketInterest= 'YES' THEN 1 WHEN a.SingleGameTicketInterest= 'No' THEN 0 ELSE NULL END SingleGameTicketInterest,
                                  CASE WHEN a.SuiteInterest= 'YES' THEN 1 WHEN a.SuiteInterest= 'No' THEN 0 ELSE NULL END SuiteInterest ,
                                  CASE WHEN a.TextClubOptIn= 'YES' THEN 1 WHEN a.TextClubOptIn= 'No' THEN 0 ELSE NULL END TextClubOptIn,
                                  CASE WHEN a.TicketDealsOptIn= 'YES' THEN 1 WHEN a.TicketDealsOptIn= 'No' THEN 0 ELSE NULL END  TicketDealsOptIn
INTO #datauploaderfields
FROM ducks.[ODS].[Dimcustomer_Attributes_Pivot] a
JOIN ducks.dbo.vwDimCustomer_ModAcctId m
ON m.DimCustomerId = a.dimcustomerid


UPDATE dbo.Contact_Custom 
SET new_ssb_SuiteInterest_yesno = d.SuiteInterest
,new_ssb_SingleGameTicketInterest_yesno = d.SingleGameTicketInterest
,new_ssb_MiniPlanInterest_yesno = d.MiniPlanInterest
,new_ssb_GroupInterest_yesno = d.GroupInterest
FROM dbo.Contact_Custom c 
JOIN #datauploaderfields d 
ON d.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID



/*========================
Email2 Field
========================*/



UPDATE c
SET c.new_ssb_EmailAddress2 = m.EmailTwo
FROM dbo.Contact_Custom c
JOIN dbo.vwCompositeRecord_ModAcctID m
ON c.SSB_CRMSYSTEM_CONTACT_ID = m.SSB_CRMSYSTEM_CONTACT_ID    
WHERE m.emailtwo IS NOT NULL OR m.EmailTwo <>'' --AND m.EmailPrimary <> m.EmailTwo           
                          
        

                          
                          

GO
