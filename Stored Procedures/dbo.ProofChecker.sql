CREATE PROCEDURE [dbo].[ProofChecker]
AS
/*
-------------------------------------------------------------------------------------
 Author     Jeremy Fifer
Created     09/11/19
Purpose     Does things with proofs. See Jeremy.
-------------------------------------------------------------------------------------
Modification History
09/11/19		JF, created. moved out of MIGMISC and made it a job.
11/09/20		JF, added the #tempApprovalCheck section; see inline notes.
11/13/20		JF, added "AND proofResponse = 'Approved'" to ROW69 which limits the recordset to only operate on Approved entries.
-------------------------------------------------------------------------------------
*/

--Import proof data from the remote table
DECLARE @proof INT
SET @proof = (SELECT TOP 1 ISNULL(PKID, 0)
		     FROM tblProof 
			 ORDER BY PKID DESC)

SET IDENTITY_INSERT tblProof ON
		INSERT INTO tblProof (pkid, orderNo, proofResponse, proofVersion, proofNotes, proofSignature, responseDate, ordersProductsID, uploadedFile, importFlag)
		SELECT PKID, orderNo, proofResponse, proofVersion, 
			CASE 
				WHEN proofNotes IS NULL THEN ' ' 
				ELSE proofNotes 
			END, 
			proofSignature, responseDate, ordersProductsID, uploadedFile, 1
		FROM dbo.HOMLIVE_tblProof x
		WHERE NOT EXISTS
			(SELECT TOP 1 1
			FROM tblProof xx
			WHERE x.pkid = xx.pkid)
		AND PKID > @proof
SET IDENTITY_INSERT tblProof OFF

-- For any OPID who has already had an approval immediately proceeding the currently inserted approval, but has not had a successful imposition
--recorded in ImpoLog, do not update the fastTrak_status to 'Good to Go', because in this situation, the OPID has already been picked up by
--Switch (which is on a 3 minute interval). Since 'Good to Go' is an override status, it would cause another entry in the pre-imposition folder
--which would mean that next time the imposition is triggered to run, there would be >1 of this identical OPID which would be thrown
--out. This is all because on the proof pages, sometimes a customer will press the proof button multiple times, thus causing multiple impositions for 
--the given opid. This section prevents this from happening.

IF OBJECT_ID('tempdb..#tempApprovalCheck') IS NOT NULL 
DROP TABLE #tempApprovalCheck

CREATE TABLE #tempApprovalCheck (
RowID INT IDENTITY(1, 1), 
OPID INT)

DECLARE @OPIDX INT,
				 @NumberRecords_x INT, 
				 @RowCount_x INT,
				 @MostRecentPreviousApprovalDate DATETIME,
				 @MostRecentImpositionDate DATETIME

INSERT INTO #tempApprovalCheck (OPID)
SELECT DISTINCT ordersProductsID
FROM tblProof
WHERE importFlag = 1
AND proofResponse = 'APPROVED'

SET @NumberRecords_x = @@ROWCOUNT
SET @RowCount_x = 1

WHILE @RowCount_x <= @NumberRecords_x
BEGIN
	 
	 SELECT @OPIDX = OPID
	 FROM #tempApprovalCheck
	 WHERE RowID = @RowCount_x

	 --@MostRecentPreviousApprovalDate that is not currently being imported
	 SET @MostRecentPreviousApprovalDate = (SELECT TOP 1 responseDate
				FROM tblProof
				WHERE ordersProductsID = @OPIDX
				AND proofResponse = 'APPROVED'
				AND importFlag = 0
				ORDER BY responseDate DESC)

	IF @MostRecentPreviousApprovalDate IS NULL
	BEGIN
		SET @MostRecentPreviousApprovalDate = '19740101' 
	END
	
	--@MostRecentImpositionDate for the opid in question
	SET @MostRecentImpositionDate = (SELECT TOP 1 logTimeStamp
					FROM ImpoLog
					WHERE opid = @OPIDX
					AND impoType <> 'proof'
					AND impoStatus = 'Successful'
					ORDER BY logTimeStamp DESC)

	IF @MostRecentImpositionDate IS NULL
	BEGIN
		SET @MostRecentImpositionDate = '20200101'
	END

	--Compare dates. If @MostRecentPreviousApprovalDate (that is not being imported right now) is more recent than @MostRecentImpositionDate (that is successful),
	--then that means that the OPID in question is actually already queued up for the next run tonight. Therefore, we should not allow the approval now being imported
	--to cause the fasttrak_status to be updated to 'Good to Go'.

	--(A) If there has already been an "APPROVE" received since the last successful imposition, then the OPID is already queued up for imposition; no need to queue it up again (which would cause duplication).
	IF @MostRecentPreviousApprovalDate > @MostRecentImpositionDate
	BEGIN
		UPDATE tblProof
		SET importFlag = 0
		WHERE importFlag = 1
		AND ordersProductsID = @OPIDX

		--Write notes to tbl_notes for new proof info, if available. Mention that it is duplicate proof data and no action was taken.
		INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType, proofNote_ref_PKID)
		SELECT orderNo, 
		REPLACE(('Duplicate Proof Response' + 
					CASE
						WHEN ordersProductsID IS NULL THEN ': '
						ELSE ' for ' + CONVERT(VARCHAR(50), ordersProductsID) + ': ' 
					END
					+ proofResponse + '.  No action taken."' + CONVERT(VARCHAR(2000), proofNotes) + '" - ' + proofSignature + ' (v.' + proofVersion + ')'), '" "', ''), 
		responseDate, 'Online Proof System', 'order', PKID 
		FROM tblProof
		WHERE ordersProductsID = @OPIDX
		AND PKID NOT IN
			(SELECT DISTINCT proofNote_ref_PKID 
			FROM tbl_Notes 
			WHERE proofNote_ref_PKID IS NOT NULL)
	END

	--(B) If an "APPROVE" hasn't happened since the last imposition, then this currently-importing "APPROVE" is legit, and we need to run an imposition again for the OPID. Updating the fastTrak_status to "Good to Go", will push the OPID through the next imposition.
	IF @MostRecentImpositionDate > @MostRecentPreviousApprovalDate
	BEGIN
		UPDATE tblOrders_Products
		SET fastTrak_status = 'Good to Go'
		WHERE ID = @OPIDX
				
		UPDATE tblProof
		SET importFlag = 0
		WHERE importFlag = 1
		AND ordersProductsID = @OPIDX

		--Write notes to tbl_notes for new proof info, if available.
		INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType, proofNote_ref_PKID)
		SELECT orderNo, 
		REPLACE(('Proof Response' + 
					CASE
						WHEN ordersProductsID IS NULL THEN ': '
						ELSE ' for ' + CONVERT(VARCHAR(50), ordersProductsID) + ': ' 
					END
					+ proofResponse + '."' + CONVERT(VARCHAR(2000), proofNotes) + '" - ' + proofSignature + ' (v.' + proofVersion + ')'), '" "', ''), 
		responseDate, 'Online Proof System', 'order', PKID 
		FROM tblProof
		WHERE ordersProductsID = @OPIDX
		AND PKID NOT IN
			(SELECT DISTINCT proofNote_ref_PKID 
			FROM tbl_Notes 
			WHERE proofNote_ref_PKID IS NOT NULL)
	END

SET @RowCount_x = @RowCount_x + 1
END

--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////
--////// ORIGINAL CODE: 
--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////--//////
/*
-- Step 1 of 2
DECLARE @proof INT
SET @proof = (SELECT TOP 1 PKID 
		     FROM tblProof 
			 ORDER BY PKID DESC)
SET IDENTITY_INSERT tblProof ON

INSERT INTO tblProof (pkid, orderNo, proofResponse, proofVersion, proofNotes, proofSignature, responseDate, ordersProductsID, uploadedFile, importFlag)
SELECT PKID, orderNo, proofResponse, proofVersion, 
	CASE 
		WHEN proofNotes IS NULL THEN ' ' 
		ELSE proofNotes 
	END, 
	proofSignature, responseDate, ordersProductsID, uploadedFile, 1
FROM sql01.HOMLIVE.dbo.tblProof
WHERE PKID NOT IN 
	(SELECT DISTINCT PKID 
	FROM tblProof 
	WHERE PKID IS NOT NULL)
AND PKID > @proof

SET IDENTITY_INSERT tblProof OFF

-- update OPID to "good to go" if proof is approved by customer
UPDATE tblOrders_Products
SET fastTrak_status = 'Good to Go'
WHERE ID IN
	(SELECT ordersProductsID
	FROM tblProof
	WHERE importFlag = 1
	AND proofResponse = 'APPROVED')

UPDATE tblProof
SET importFlag = 0
WHERE importFlag = 1

--// Write notes to tbl_notes for new proof info, if available.
INSERT INTO tbl_notes (jobnumber, notes, notedate, author, notesType, proofNote_ref_PKID)
SELECT orderNo, 
REPLACE(('Proof Response' + 
			CASE
				WHEN ordersProductsID IS NULL THEN ': '
				ELSE ' for ' + CONVERT(VARCHAR(50), ordersProductsID) + ': ' 
			END
			+ proofResponse + '. "' + CONVERT(VARCHAR(2000), proofNotes) + '" - ' + proofSignature + ' (v.' + proofVersion + ')'), '" "', ''), 
responseDate, 'Online Proof System', 'order', PKID 
FROM tblProof
WHERE PKID NOT IN
	(SELECT DISTINCT proofNote_ref_PKID 
	FROM tbl_Notes 
	WHERE proofNote_ref_PKID IS NOT NULL)

-- Step 2 of 2
DECLARE @proof_fileName INT
SET @proof_fileName = (SELECT TOP 1 PKID 
					   FROM tblProof_Upload 
					   ORDER BY PKID DESC)

SET IDENTITY_INSERT tblProof_Upload ON
INSERT INTO tblProof_Upload (PKID, ordersProductsID, uploadedFile)
SELECT PKID, ordersProductsID, uploadedFile
FROM sql01.HOMLIVE.dbo.tblProof_Upload
WHERE PKID NOT IN 
	(SELECT DISTINCT PKID 
	FROM tblProof_Upload 
	WHERE PKID IS NOT NULL)
AND PKID > @proof_fileName

SET IDENTITY_INSERT tblProof_Upload OFF 

--Deal with proof uploads
DECLARE @proof_fileName INT
SET @proof_fileName = (SELECT TOP 1 PKID 
					   FROM tblProof_Upload 
					   ORDER BY PKID DESC)

SET IDENTITY_INSERT tblProof_Upload ON
	INSERT INTO tblProof_Upload (PKID, ordersProductsID, uploadedFile)
	SELECT PKID, ordersProductsID, uploadedFile
	FROM sql01.HOMLIVE.dbo.tblProof_Upload x
	WHERE NOT EXISTS
				(SELECT TOP 1 1
				FROM tblProof_Upload xx
				WHERE x.pkid = xx.pkid)
	AND PKID > @proof_fileName
SET IDENTITY_INSERT tblProof_Upload OFF 

*/