CREATE PROC [dbo].[usp_getSwitchMergeTest]
AS
SELECT arb AS 'PKID', Template, DDFName, OutputPath, LogFilePath, OutputStyle, OutputFormat, orderNo, ordersProductsID, productQuantity AS 'QTY', 
productCode, yourName as 'Line 1', yourCompany as 'Line 2', input1 as 'Line 3', input2 as 'Line 4', input3 as 'Line 5', input4 as 'Line 6', input5 as 'Line 7', input6 as 'Line 8', input7 as 'Line 9', input8 as 'Line 10', 
logo1, logo2, photo1, photo2, overflow1, overflow2, overflow3, overflow4, overflow5, groupPicture, topImage, profsymbol1, profsymbol2, profsymbol3, enterDate, previousJobArt, previousJobInfo, artInstructions, backgroundFileName, layoutFileName, productBack, team1FileName, team2FileName, team3FileName, team4FileName, team5FileName, team6FileName, jobProductID
FROM tblSwitchMergeTest
ORDER BY PKID