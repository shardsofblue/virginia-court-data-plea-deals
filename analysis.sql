/* Count the number of each type of finding aka DispositionCode */
SELECT "CircuitCriminalCase"."DispositionCode", count(*)
FROM "CircuitCriminalCase" 
GROUP BY "CircuitCriminalCase"."DispositionCode"
ORDER BY count(*) DESC;

/* Count the number of each type of plea in hearings */
SELECT "CircuitCriminalHearing"."Plea", count(*) 
FROM "CircuitCriminalHearing" 
GROUP BY "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/* There are: 
12,737,368 NULL
855,656 Guilty
455,995 Not Guilty
63,467 No contest (aka nolo contendre)
14,920 Tried in Absentia
10,235 Alford
--Need to figure out what NULL pleas have in common */

/* Count the number of Plea=NULL that are each ChargeType, Felony or Misdemeanor */
SELECT "CircuitCriminalCase"."ChargeType", "CircuitCriminalHearing"."Plea", count(*) as count 
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."ChargeType", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/* The majority of the cases with NULL pleas (1,699,078) are of ChargeType=Felony 
Let's dig down. 
Count the number of Plea=NULL that are each CodeSection, indicating the same specific crime */
SELECT "CircuitCriminalCase"."CodeSection", "CircuitCriminalHearing"."Plea", count(*) as count 
FROM "CircuitCriminalHearing" 
JOIN "CircuitCriminalCase"
ON "CircuitCriminalCase"."id" = "CircuitCriminalHearing"."id"
WHERE "CircuitCriminalHearing"."Plea" is NULL
GROUP BY "CircuitCriminalCase"."CodeSection", "CircuitCriminalHearing"."Plea"
ORDER BY count(*) DESC;

/* The majority of NULL pleas (453,494) are from CodeSection 19.2-306, "Revocation of suspension of sentence and probation". This makes sense, because this is something that a judge simply decides and (probably??) does not require a plea (need to confirm with a lawyer).
Next highest (121,390) is 18.2.95, "Grand Larceny" 
Followed closely by: 
18.2-172 (117,952), forgery
18.2-248 (115,319), drug sales
18.2-250 (114,133), drug possession
*/

/* There are different types of hearings! Let's find out what they are. */
/* Count the number of each type of hearing */
SELECT "CircuitCriminalHearing"."Type", count(*) AS count
FROM "CircuitCriminalHearing" 
GROUP BY "CircuitCriminalHearing"."Type"
ORDER BY count DESC;

/* It would make sense for hearings that are not actually plea hearings to not have a plea entered, leading to a NULL value. We need to confirm that. So, let's see how many hearings of type Plea have a null vs how many hearings of other types.
*/

