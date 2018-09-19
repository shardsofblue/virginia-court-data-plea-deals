/* 001 Count the number of each type of finding aka DispositionCode across all hearings */
SELECT "CircuitCriminalCase"."DispositionCode", count(*)
FROM "CircuitCriminalCase" 
GROUP BY "CircuitCriminalCase"."DispositionCode"
ORDER BY count(*) DESC;

/* 002 Count the number of each type of plea across all hearings */
SELECT "CircuitCriminalHearing"."Plea", count(*) 
FROM "CircuitCriminalHearing" 
GROUP BY "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** 
There are: 
12,737,368 NULL
855,656 Guilty
455,995 Not Guilty
63,467 No contest (aka nolo contendre)
14,920 Tried in Absentia
10,235 Alford
--Need to figure out what NULL pleas have in common 
*/

/* 003 Count the number of Plea=NULL that are each ChargeType, Felony or Misdemeanor */
SELECT "CircuitCriminalCase"."ChargeType", "CircuitCriminalHearing"."Plea", count(*) as count 
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."ChargeType", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/*** 
The majority of the cases with NULL pleas (1,699,078) are of ChargeType=Felony,
compared with 618,685 Misdemeanors.
Let's dig down.
*/

/* 004 Count the number of Plea=NULL that are each CodeSection, indicating the same specific crime */
SELECT "CircuitCriminalCase"."CodeSection", "CircuitCriminalHearing"."Plea", count(*) as count 
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
	"h1"."Type",
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

The majority of NULL pleas, 18.6% are for "Revocation of suspension of sentence and probation". This makes sense (?), because this is something that a judge simply decides and (probably??) does not require a plea (need to confirm with a lawyer).
Next highest (~5%) is 18.2.95, "Grand Larceny" 
Followed closely by: 
18.2-172 (4.8%), forgery
18.2-248 (4.7%), drug sales
18.2-250 (4.7%), drug possession
Next lowest, 18.2-456 is ~2%, Contempt

BUT we still don't know why there are NULL pleas in the other types of crime.
*/