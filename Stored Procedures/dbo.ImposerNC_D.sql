CREATE PROCEDURE "dbo"."ImposerNC_D"

AS
SELECT pkid, orderNo, opid, outputName, surface1, surface2, surface3, barcode, auxiliaryText, quantity, pUnitCount, productCount, shipColor, shipsWith, shipsWithAlt, shipType, resubmit, expedite, shipLine1, shipLine2, shipLine3, shipLine4, shipLine5, customProducts, fasTrakProducts, stockProduct1, stockProduct2, stockProduct3, stockProduct4, stockProduct5, stockProduct6, storeLogo FROM ImposerNCTickets
where resubmit = 0;
SELECT pkid, orderNo, opid, surface1, surface2, surface3, ticketName, resubmit, expedite, firstInstance FROM IMPOSERNCCavities
where opid in (
SELECT opid FROM ImposerNCCavities WHERE ticketName is Null AND surface2 is not null
);