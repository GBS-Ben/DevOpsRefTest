CREATE proc usp_executeJob_R2P_NameBadges
as
/*
This procedure  starts the R2P job once the Intranet Button is clicked that initiates the manual push of R2P Name Badges to XLS.
*/
EXEC msdb.dbo.sp_start_job N'R2P - Name Badges' 
--DTSRun /~Z0x94842552A1B11CA7AEF20F65E136540EAC604D7F91C8761548FCE1CC3614C938CD79774F863538997EE84BFD66880E318372908B9747E2AD1C630935AAF9F9A1E095C429E313FD759527DA3A65F9C029B6B4C393CF506B0574A2CE19F4280AEC5E597B