SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[KeyAccountRollbackView] as

SELECT contactid, firstname, lastname, emailaddress1, address1_line1, address1_city, address1_stateorprovince, address1_postalcode--, str_number
FROM dbo.keyaccounts_rollback
GO
