/*A self-joined table*/
SELECT "h2"."Plea", count(*) AS "Count_in_Plea_Hearings", SUM(count(*)) OVER() AS "Total_Count"
FROM "CircuitCriminalHearing" AS "h1"
INNER JOIN "CircuitCriminalHearing" AS "h2"
ON "h1"."id" = "h2"."id"
WHERE "h1"."Type" LIKE 'Plea'
GROUP BY "h1"."Type", "h2"."Plea";

/* Subquery to get percentage of a count. Using "OVER()" is more effficient */
SELECT "h1"."Plea", 
	count(*) AS "Count_in_Plea_Hearings", 
	/*SUM(count(*)) OVER() AS "Total_Count",*/
	(count(*)*100.0) / 
		/* A nested SELECT allows me to count only what I want */
		(SELECT count(*)
		FROM "CircuitCriminalHearing"
		WHERE "CircuitCriminalHearing"."Type" LIKE 'Plea'
		)
	 AS "Perc_of_Total"
FROM "CircuitCriminalHearing" AS "h1"
WHERE "h1"."Type" LIKE 'Plea'
GROUP BY "h1"."Type", "h1"."Plea"
ORDER BY "Perc_of_Total" DESC;



/**/
UNION ALL /* A union appends the "totals" row to the bottom */
SELECT 
	NULL, /* choosing null columns gives the two tables column parity without adding multiple extra rows */
	NULL,
	SUM(count(*)) OVER(),
	count(*) * 100.0 / SUM(count(*)) OVER()
FROM "CircuitCriminalHearing" AS "h1"
WHERE 
	"h1"."Type" NOT LIKE 'Plea'
	AND "h1"."Plea" IS NULL
ORDER BY "Perc_of_Total" DESC;