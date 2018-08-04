IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ssbcloud\ssales')
CREATE LOGIN [ssbcloud\ssales] FROM WINDOWS
GO
CREATE USER [ssbcloud\ssales] FOR LOGIN [ssbcloud\ssales] WITH DEFAULT_SCHEMA=[ssbcloud\ssales]
GO
REVOKE CONNECT TO [ssbcloud\ssales]
