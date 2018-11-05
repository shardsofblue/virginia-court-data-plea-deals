/* 001 Count the number of each type of finding aka DispositionCode across all hearings */
SELECT "CircuitCriminalCase"."DispositionCode", count(*)
FROM "CircuitCriminalCase" 
GROUP BY "CircuitCriminalCase"."DispositionCode"
ORDER BY count(*) DESC;

/* 002 Count the number of each type of plea across all hearings */
SELECT 
	"CircuitCriminalHearing"."Plea", 
	count(*), 
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
GROUP BY "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** 
There are: 
12,737,368 NULL 90.1%
855,656 Guilty 6.1%
455,995 Not Guilty 3.2%
63,467 No contest (aka nolo contendre) .5%
14,920 Tried in Absentia .1%
10,235 Alford .1%
--Need to figure out what NULL pleas have in common 
*/

/* 003 Count the number of Plea=NULL that are each ChargeType, Felony or Misdemeanor */
SELECT 
	"CircuitCriminalCase"."ChargeType", 
	"CircuitCriminalHearing"."Plea", 
	count(*) as count,
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."ChargeType", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** 
The majority of the cases with NULL pleas (1,699,078, 69.8%) are of ChargeType=Felony,
compared with 618,685 (25.4%) Misdemeanors.
Let's dig down.
*/

/* 004 Count the number of Plea=NULL that are each CodeSection, indicating the same specific crime */
SELECT 
	"CircuitCriminalCase"."CodeSection", 
	"CircuitCriminalHearing"."Plea", 
	count(*) as count,
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."CodeSection", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** 
The majority of NULL pleas (453,494) are from CodeSection 19.2-306, "Revocation of suspension of sentence and probation". This makes sense, because this is something that a judge simply decides and (probably??) does not require a plea (need to confirm with a lawyer).
Next highest (121,390) is 18.2.95, "Grand Larceny" 
Followed closely by: 
18.2-172 (117,952), forgery
18.2-248 (115,319), drug sales
18.2-250 (114,133), drug possession
*/

/* 005 Wait a sec, there are different types of hearings! Let's find out what they are. */
/* Count the number of each type of hearing */
SELECT "h"."Type", count(*) AS count
FROM "CircuitCriminalHearing" AS "h"
GROUP BY "h"."Type"
ORDER BY count DESC;

/*** 
It would make sense for hearings that are not actually plea hearings to not have a plea entered, leading to a NULL value. We need to confirm that. So, let's see how many hearings of type Plea have a null vs how many hearings of other types.
*/

/* 006 Let's start by figuring out how many of each plea type is entered in each type of hearing.*/
SELECT "h1"."Type", "h1"."Plea", count(*)
FROM "CircuitCriminalHearing" AS "h1"
GROUP BY "h1"."Type", "h1"."Plea";

/* 007 Then I will filter by hearing type as Plea.*/
SELECT "h1"."Type", "h1"."Plea", count(*)
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea'
GROUP BY "h1"."Type", "h1"."Plea";

/* 008 Now I need to know the total count of Plea hearings
This outputs the total as a column... */
SELECT 
	"h1"."Plea", count(*) AS "Count_in_Plea_Hearings", 
	SUM(count(*)) OVER() AS "Total_Count"
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea'
GROUP BY "h1"."Type", "h1"."Plea";

/* 009 ...but I would like the ability to see it with reduced redundancy as a row, which I can do using a UNION to append the row to the bottom */
SELECT "h1"."Plea", count(*)
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea'
GROUP BY "h1"."Type", "h1"."Plea"
UNION ALL /* A union appends the totals row to the bottom */
SELECT 
	NULL, /* choosing a single null column gives the two tables column parity without adding multiple extra rows */
	SUM(count(*)) OVER() AS "Total_Count"
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea';

/* 010 Now, I can get the percentage of the total for each row, rounded to 2 decimal places. */
SELECT 
	"h1"."Plea", 
	count(*) AS "Count_in_Plea_Hearings", 
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea' /*counting only the hearings that are Plea hearings*/
GROUP BY "h1"."Type", "h1"."Plea"
UNION ALL /* A union appends the "totals" row to the bottom */
SELECT 
	NULL, /* choosing a single null column gives the two tables column parity without adding multiple extra rows */
	SUM(count(*)) OVER(),
	count(*) * 100.0 / SUM(count(*)) OVER()
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea'
ORDER BY "Perc_of_Total";

/*** 
So it looks like 63.9% of Plea Hearings do not have a Plea entered.
*/

/* 011 What percentage of EACH hearing type, compared to all, does not have a Plea entered? */
SELECT 
	"h1"."Type",
	count(*) AS "Null_Pleas", 
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" AS "h1"
WHERE 
	"h1"."Plea" IS NULL
GROUP BY "h1"."Type", "h1"."Plea"
UNION ALL /* A union appends the "totals" row to the bottom */
SELECT 
	NULL, /* choosing null columns gives the two tables column parity without adding multiple extra rows */
	SUM(count(*)) OVER(),
	count(*) * 100.0 / SUM(count(*)) OVER()
FROM "CircuitCriminalHearing" AS "h1"
WHERE 
	"h1"."Plea" IS NULL
ORDER BY "Perc_of_Total" DESC;

/*** 
Trials account for the highest percentage of NULL pleas, at 14%, 
followed by Grand Jury Hearings, at 12.9%. 
Plea Hearings account for 5.3% of NULL pleas, somewhere in the middle of the pack. 
*/

/* 012 What percentage of Trial Hearings are NULL? */
SELECT 
	"h1"."Plea",
	count(*) AS "Null_Pleas", 
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" AS "h1"
WHERE 
	"h1"."Type" LIKE 'Trial'
GROUP BY "h1"."Type", "h1"."Plea"
UNION ALL /* A union appends the "totals" row to the bottom */
SELECT 
	NULL, /* choosing null columns gives the two tables column parity without adding multiple extra rows */
	SUM(count(*)) OVER(),
	count(*) * 100.0 / SUM(count(*)) OVER()
FROM "CircuitCriminalHearing" AS "h1"
WHERE 
	"h1"."Type" LIKE 'Trial'
ORDER BY "Perc_of_Total" DESC;

/*** 
So ~72% of Trial Hearings don't have a plea entered. That's not too far off from the percentage of Plea Hearings (which was ~64% per query 010). 
I think it's safe to say that Hearing Type isn't the key to the reason for all these NULLs.
I think I should go back to looking at crime type by Code Section.
*/

/* 013 Revisiting query 004 to determine percentages of total. */
SELECT 
	"CircuitCriminalCase"."CodeSection", 
	count(*) as "Num_of_NULL_Pleas",
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."CodeSection", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** 
Returned 14,499 records (aka types of crime). Out of those...

The majority of NULL pleas, 18.6% are for 19.2-306, "Revocation of suspension of sentence and probation". This makes sense (?), because this is something that a judge simply decides and (probably??) does not require a plea (need to confirm with a lawyer).
Next highest (~5%) is 18.2.95, "Grand Larceny" 
Followed closely by: 
18.2-172 (4.8%), forgery
18.2-248 (4.7%), drug sales
18.2-250 (4.7%), drug possession
Next lowest, 18.2-456 is ~2%, Contempt

BUT we still don't know why there are NULL pleas in the other types of crime.
*/

/* 014 What percent of Revocation (19.2-306) charges have a NULL plea within each type of trial? */
SELECT 
	"h1"."Type",
	count(*) AS "Null_Pleas", 
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" AS "h1"
INNER JOIN "CircuitCriminalCase" AS "c1"
ON "h1"."id" = "c1"."id"
WHERE "h1"."Plea" IS NULL
	AND "c1"."CodeSection" = '19.2-306'
GROUP BY "h1"."Type", "h1"."Plea"

UNION ALL /* A union appends the "totals" row to the bottom */
SELECT 
	NULL, /* choosing null columns gives the two tables column parity without adding multiple extra rows */
	SUM(count(*)) OVER(),
	count(*) * 100.0 / SUM(count(*)) OVER()
FROM "CircuitCriminalHearing" AS "h1"
INNER JOIN "CircuitCriminalCase" AS "c1"
ON "h1"."id" = "c1"."id"
WHERE "h1"."Plea" IS NULL
	AND "c1"."CodeSection" = '19.2-306'

ORDER BY "Perc_of_Total" DESC;

/*** Again I notice that within the Revocation (19.2-306) charge, the highest percentages (11.8 and 11.9) of NULLs are in Trial and Grand Jury. */

/* 014 What percentage of Revocation (19.2-306) charges have a NULL plea? */
SELECT 
	"h1"."Plea",
	count(*) AS "Null_Pleas", 
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" AS "h1"
INNER JOIN "CircuitCriminalCase" AS "c1"
ON "h1"."id" = "c1"."id"
WHERE "c1"."CodeSection" = '19.2-306'
GROUP BY "h1"."Plea", "h1"."Plea"

/*** 90.8% of all Revocation charges are NULL pleas */

/* 015 Does DispositionCode factor into this? */
SELECT 
	"CircuitCriminalCase"."DispositionCode", 
	count(*) as "Num_of_NULL_Pleas",
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."DispositionCode", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** NULL pleas resulted in...
46.4% Guilty verdicts
17% Nolle Posequi
15.3% Sentence/Probation Revoked
10.14% Dismissed
3.7% Resolved
3.4% NULL
*/

/* 016 What about Commencedby? */
SELECT 
	"CircuitCriminalCase"."Commencedby", 
	count(*) as "Num_of_NULL_Pleas",
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."Commencedby", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** Commenced by...
Indictment	30.61
Reinstatement	21.71
Direct Indictment	21.09
General District Court Appeal	17.91
Other	3.04
...
*/

/* 017 What about ConcludedBy? */
SELECT 
	"CircuitCriminalCase"."ConcludedBy", 
	count(*) as "Num_of_NULL_Pleas",
	ROUND(count(*) * 100.0 / SUM(count(*)) OVER() ,2) AS "Perc_of_Total"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** Concluded by...
Guilty Plea	34.07
Trial - Judge With Witness	17.85
Nolle Prosequi	17.12
Revoked		11.48
Dismissal	8.07
Other	4.81
NULL	3.35
Withdrawn Prior To Trial	1.87
Trial - Jury	1.22
Transferred	0.17
*/

/*** After talking with a legal expert, we determined that the number of NULL pleas are primarily because the prosecutor dismissed the charge before a plea was entered. */

/* Deb requested a few random case numbers to check this theory */
SELECT 	*
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
LIMIT 300;

/*** B. Let's take a different track and stop looking at the hearing table. */

/* B01 What is in CircuitCriminalCase again? */
SELECT * FROM "CircuitCriminalCase"
LIMIT 100;

/* B02 What are the types of Commencedby? */
SELECT "CircuitCriminalCase"."Commencedby", COUNT(*) as "Count" 
FROM "CircuitCriminalCase" 
GROUP BY "CircuitCriminalCase"."Commencedby";
/* seems irrelevant. */

/* B03 What are the types of ConcludedBy? */
SELECT "CircuitCriminalCase"."ConcludedBy", COUNT(*) as "Count" 
FROM "CircuitCriminalCase" 
GROUP BY "CircuitCriminalCase"."ConcludedBy";
/* This looks better. */

/* We need to compare trials that ended with guilty pleas to those that ended with a trial. 
"Guilty Plea" "Trial - Jury" "Trial - Judge With Witness" */

/* B04 How many trials ended with each type of conclusion aka DispositionCode (guilty, dismissed, etc.)? */
SELECT "CircuitCriminalCase"."DispositionCode", COUNT(*) as "Count" 
FROM "CircuitCriminalCase" 
GROUP BY "CircuitCriminalCase"."DispositionCode";
/* Need to see "Guilty" */

/* B05 Now, let's look just at all info for FELONIES ConcludedBy a GUILTY PLEA or a TRIAL, for only year 2017  */
SELECT *, 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") AS "YearFiled" /* year column */
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND /* found guilty */
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND /* felony */
	"CircuitCriminalCase"."SentenceTime" is not null AND /* was sentenced to jail time */
	("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' /* ended with a GUILTY PLEA */
		OR "CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' /* ended with a JURY TRIAL */
		OR "CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND /* ended with a JUDGE TRIAL */
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017; /* in 2017 */

/* B06 Same as above, but adding an average sentence time for each charge */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."Charge", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence" /* average sentence time */
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
	"CircuitCriminalCase"."SentenceTime" is not null AND
	("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' 
		OR "CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' 
		OR "CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."Charge"; /* grouped by guiltyplea/trial and charge */

/* B07 How many cases ended with a guilty plea or a trial? */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	COUNT("CircuitCriminalCase"."ConcludedBy") as "Count_ConcludedBy" /* count of each */
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
	"CircuitCriminalCase"."SentenceTime" is not null AND
	("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR "CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND
EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy" /* grouped by guiltyplea/trial */
ORDER BY "Count_ConcludedBy" DESC;

/* B08 How many of each type of case (aka charge type) ended with a guilty plea or a trial? */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."SentenceTime") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence"
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
	"CircuitCriminalCase"."SentenceTime" is not null AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection"; /* grouped by guiltyplea/trial and charge code */

/* B09 This is already checking for people found guilty by DispositionCode, so I think I should also look at sentence times that were zero (aka NULL). */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection";

SELECT *
FROM "CircuitCriminalCase"
LIMIT 100; 

/* B10 Let me count how many got zero sentence time (a NULL sentence time) for each */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."CodeSection") as "Count_of_No_Jail_Time"
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND
	"CircuitCriminalCase"."SentenceTime" IS NULL AND
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection";

/***
NOTE: Concurrent analysis in an Excel file starts here
***/

/* C01 Pull some alford pleas for Deb */

/* id fields didn't line up, so I ran some checks to figure out which fields to join them on */
SELECT *
FROM "CircuitCriminalCase"
LIMIT 10;

SELECT *
FROM "CircuitCriminalHearing"
LIMIT 10;

SELECT *
FROM "CircuitCriminalHearing"
WHERE "CircuitCriminalHearing"."Plea" = 'Alford';

SELECT *
FROM "CircuitCriminalCase"
WHERE "CircuitCriminalCase"."id" = 1234545;
/*CR120F0014-01 2012-03-19 */

SELECT *
FROM "CircuitCriminalHearing"
WHERE "CircuitCriminalHearing"."id" = 1234545;
/*237752 2016-03-02 */

SELECT *
FROM "CircuitCriminalHearing"
WHERE "CircuitCriminalHearing"."case_id" = 1133818;
/* 3094150: 2017-11-01 to 2018-01-10  */
/* 741150: 2012-09-04 to 2013-01-25 */
/* 1133818: 2012-03-26 to 2012-07-10*/

SELECT *
FROM "CircuitCriminalCase"
WHERE "CircuitCriminalCase"."id" = 1133818;
/* 3094150: 2017-11-01  */
/* 741150: 2013-01-25 */
/* 1133818: 2012-07-10*/

SELECT *
FROM "CircuitCriminalCase"
WHERE "CircuitCriminalCase"."id" = 3241370;

SELECT 
	"CircuitCriminalCase"."id", 
	"CircuitCriminalCase"."CaseNumber", 
	"CircuitCriminalCase"."fips", 
	"CircuitCriminalCase"."Filed",
	"CircuitCriminalCase"."Defendant",
	"CircuitCriminalCase"."Charge",
	"CircuitCriminalCase"."CodeSection",
	"CircuitCriminalHearing"."Plea",
	"CircuitCriminalCase"."DispositionCode",
	"CircuitCriminalCase"."ConcludedBy",
	"CircuitCriminalCase"."SentenceTime",
	"CircuitCriminalCase"."FineAmount",
	"CircuitCriminalCase"."OperatorLicenseSuspensionTime"
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."case_id"
WHERE "CircuitCriminalHearing"."Plea" = 'Alford'
	AND extract(year from "CircuitCriminalCase"."Filed") BETWEEN 2012 AND 2017
ORDER BY "CircuitCriminalCase"."Filed";


/***
NOTE: New Excel analysis file starts here
***/

/* C02 Pull back to 10 years instead of just 2017 (sql) */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence",
	AVG("CircuitCriminalCase"."SentenceTime" - "CircuitCriminalCase"."SentenceSuspended") as "Average_Sentence_Adjusted" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection";

/* C03 Count of how many got zero sentence time (a NULL sentence time) for each */
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."CodeSection") as "Count_of_No_Jail_Time"
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND
	"CircuitCriminalCase"."SentenceTime" IS NULL AND
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection";

/* Clean data by: sort-by Charge, combine similar charges (xls) */
/* ^^ IN PROGRESS--left off in file "analysis_2007-2017", sheet "main_cleaned", row 628 when sorted by Charge_Code */

/* Next, pivot table to group (xls) */
/* After data clean, do location analysis */


/* */
SELECT *, 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence" 
FROM "CircuitCriminalCase" 
WHERE 
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017
GROUP BY "CircuitCriminalCase"."CodeSection", "CircuitCriminalCase"."id", "CircuitCriminalCase"."ConcludedBy"
ORDER BY "CircuitCriminalCase"."CodeSection" DESC;


SELECT *, 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."CodeSection" LIKE '%18.2-91'
GROUP BY "CircuitCriminalCase"."CodeSection", "CircuitCriminalCase"."id", "CircuitCriminalCase"."ConcludedBy"
ORDER BY "CircuitCriminalCase"."CodeSection" DESC;

SELECT *
FROM "CircuitCriminalCase";

SELECT *
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."CaseNumber" LIKE 'CR01000029-01'
AND "CircuitCriminalCase"."fips" = 47;

SELECT *
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."fips" = 47
AND EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017;

/* Group by disposition date and person
if same name, subset of 
*/

SELECT "CircuitCriminalCase"."CodeSection",
	"CircuitCriminalCase"."ConcludedBy", 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."CodeSection" LIKE '%18.2-95' AND
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017
GROUP BY ROLLUP("CircuitCriminalCase"."CodeSection", "CircuitCriminalCase"."id", "CircuitCriminalCase"."ConcludedBy");

/* adjusted sentence time for sentence suspension*/
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence",
	AVG("CircuitCriminalCase"."SentenceTime" - "CircuitCriminalCase"."SentenceSuspended") as "Average_Sentence_Adjusted" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017
GROUP BY ROLLUP("CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection");

/* Looking at only 18.2-%*/
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence",
	AVG("CircuitCriminalCase"."SentenceTime" - "CircuitCriminalCase"."SentenceSuspended") as "Average_Sentence_Adjusted" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."CodeSection" LIKE '%18.2-3%' AND
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017
GROUP BY ROLLUP("CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection");

/* Looking at only HOMICIDES 18.2-3%*/
SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."LifeDeath",
	"CircuitCriminalCase"."CodeSection", 
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases"
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."LifeDeath" IS NOT NULL AND
	("CircuitCriminalCase"."CodeSection" LIKE '%18.2-3%' AND
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") BETWEEN 2007 AND 2017)
GROUP BY ROLLUP("CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection", "CircuitCriminalCase"."LifeDeath");

SELECT *
FROM "CircuitCriminalCase"
WHERE "CircuitCriminalCase"."LifeDeath" IS NOT NULL;

/*

-do again taking into account suspended sentence
-look at life sentence counts (not average) by percentage
-build a dataset of everyone charged with X, join on (birthday+name or person_id)+date-of-charge
-Homicides are highest prio, others are for developing out if they show a penalty
-rate of charges dropped for X: how often does someone get charged for a more serious crime vs convicted of said crime
--how many who were charged with X were convicted of that charge, vs. lower charge and how does that relate to guilty pleas

-pick one year, one (big) fips
-charges stored as temp table, joined to original dataset
*/

SELECT "CircuitCriminalCase"."ConcludedBy", 
	"CircuitCriminalCase"."CodeSection", 
	"CircuitCriminalCase"."fips",
	COUNT("CircuitCriminalCase"."id") as "Count_of_cases", 
	AVG("CircuitCriminalCase"."SentenceTime") as "Average_Sentence",
	AVG("CircuitCriminalCase"."SentenceTime" - "CircuitCriminalCase"."SentenceSuspended") as "Average_Sentence_Adjusted" 
FROM "CircuitCriminalCase" 
WHERE "CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."ConcludedBy", "CircuitCriminalCase"."CodeSection", "CircuitCriminalCase"."fips"
ORDER BY "CircuitCriminalCase"."fips";

/* Count of murder cases by fips*/
SELECT "CircuitCriminalCase"."fips",
	COUNT("CircuitCriminalCase"."fips") as "Count_of_cases" 
FROM "CircuitCriminalCase" 
WHERE 
	"CircuitCriminalCase"."CodeSection" LIKE '%18.2-31%' AND
	/*OR "CircuitCriminalCase"."CodeSection" LIKE '%18.2-32%') AND*/
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
GROUP BY "CircuitCriminalCase"."fips"
ORDER BY "CircuitCriminalCase"."fips";

/* All capital murders  */
CREATE TEMP TABLE capital_murders AS
SELECT *  
FROM "CircuitCriminalCase" 
WHERE 
	"CircuitCriminalCase"."CodeSection" LIKE '%18.2-31%' AND
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017
ORDER BY "CircuitCriminalCase"."fips";

SELECT *
FROM "capital_murders";

/* Mr. Contreras' 8 charges, guilty plea, none dropped */
SELECT *  
FROM "CircuitCriminalCase" 
WHERE 
	"CircuitCriminalCase"."Defendant" LIKE '%CONTRERAS%' AND
	"CircuitCriminalCase"."fips" = 165 AND
	"CircuitCriminalCase"."DispositionCode" = 'Guilty' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017;

/* unique defendant values for capital murders, for use as a filter for future queries */
CREATE TEMP TABLE cap_murder_defs AS
SELECT DISTINCT "CircuitCriminalCase"."Defendant"
FROM "CircuitCriminalCase" 
WHERE 
	"CircuitCriminalCase"."CodeSection" LIKE '%18.2-31%' AND
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017;

SELECT *
FROM "cap_murder_defs";

DROP TABLE cap_murder_defs;

/* all charges for people who were charged with capital murder (requires creation of temp table above) */
SELECT *
FROM "CircuitCriminalCase"
JOIN "cap_murder_defs"
ON "CircuitCriminalCase"."Defendant" = "cap_murder_defs"."Defendant"
WHERE 
	"CircuitCriminalCase"."ChargeType" = 'Felony' AND
		("CircuitCriminalCase"."ConcludedBy" = 'Guilty Plea' OR 
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Jury' OR
		"CircuitCriminalCase"."ConcludedBy" = 'Trial - Judge With Witness') AND 
	EXTRACT(YEAR FROM "CircuitCriminalCase"."Filed") = 2017;
	
