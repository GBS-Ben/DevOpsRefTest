CREATE FUNCTION [dbo].[kk_fn_UTIL_DateRound]
(
	@dtDate		datetime,	-- Date Value to adjust
	@intRound	int		-- 0=Round down [Midnight last night], 1=Round up [Midnight tonight]
)
RETURNS datetime
/* WITH ENCRYPTION */
AS
/*
 * kk_fn_UTIL_DateRound	Convert date to midnight tonight
 *			For a "limit" date of '01-Jan-2000' the test needs to be 
 *				MyColumn < '02-Jan-2000' 
 *			to catch any item with a time during 1st Jan
 *
 *	SELECT	dbo.kk_fn_UTIL_DateRound(GetDate(), 0)	-- Midnight last night
 *	SELECT	dbo.kk_fn_UTIL_DateRound(GetDate(), 1)	-- Midnight tonight
 *
 * Returns:
 *
 * 	datetime
 *
 * HISTORY:
 *
 * 28-Jul-2005 KBM  Started
 */
BEGIN

	SELECT	@dtDate = DATEADD(Day, DATEDIFF(Day, 0, @dtDate)+@intRound, 0)

	RETURN @dtDate
/** TEST RIG

SELECT	'01-Jan-2000', dbo.kk_fn_UTIL_DateRound('01-Jan-2000', 0)
SELECT	'01-Jan-2000', dbo.kk_fn_UTIL_DateRound('01-Jan-2000', 1)

SELECT	'01-Jan-2000 01:02:03', dbo.kk_fn_UTIL_DateRound('01-Jan-2000 01:02:03', 0)
SELECT	'01-Jan-2000 01:02:03', dbo.kk_fn_UTIL_DateRound('01-Jan-2000 01:02:03', 1)

SELECT	'28-Feb-2000 01:02:03', dbo.kk_fn_UTIL_DateRound('28-Feb-2000 01:02:03', 0)
SELECT	'28-Feb-2000 01:02:03', dbo.kk_fn_UTIL_DateRound('28-Feb-2000 01:02:03', 1)

SELECT	'29-Feb-2000 01:02:03', dbo.kk_fn_UTIL_DateRound('29-Feb-2000 01:02:03', 0)
SELECT	'29-Feb-2000 01:02:03', dbo.kk_fn_UTIL_DateRound('29-Feb-2000 01:02:03', 1)

**/
--==================== kk_fn_UTIL_DateRound ====================--
END