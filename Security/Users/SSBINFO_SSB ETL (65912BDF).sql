IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'SSBINFO\SSB ETL (65912BDF)')
CREATE LOGIN [SSBINFO\SSB ETL (65912BDF)] FROM WINDOWS
GO
CREATE USER [SSBINFO\SSB ETL (65912BDF)] FOR LOGIN [SSBINFO\SSB ETL (65912BDF)]
GO