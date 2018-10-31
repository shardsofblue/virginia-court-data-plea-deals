# File to store To-Do tasks and make notes between collaborators

## Overall Notes:
* Roxanne has been working on this data within SQLPro for Postgre, which is installed on computer 3210-09. 
* Excel file _analysis\_2007-2017.xlsx_ and SQL file _analysis.sql_ have the latest work

### Questions to answer:
* [IN PROGRESS] Which crimes have a trial penalty? _Compute the mean sentence time of plea  vs. trial by crime_
* Is there a stronger penalty for people based on race? Gender?
* Are more people of a certain race or gender likely to take plea deals?
* How many charges do people generally receive? Are a large number dropped when a person takes a plea deal? _Count the number of charges per person\_id_

### TODO:
* [IN PROGRESS] Clean crime\_code\_keys so I can use them to examine types of crime
* load cleaned data into R
* compute statistically valid categories using ANOVA
* [DONE] Figure out why so many values are NULL
* [DONE] Get Sean to look over my Excel files for methodology checking (1)


### What I have learned:
As of... 10/17
* Pending analysis of statistical relevance, there appears to be the strongest penalty for crimes involving drugs or welfare.
* Null pleas at hearings were (probably) because so many of the charges are dropped by the prosecutor (per legal expert).
* Instead of looking at the Hearings table at all, we can use the main Case table and use the ConcludedBy field to tell us whether a case was determined based on a guilty plea or a trial.
* NULL values analysis
	* 90% of the pleas are NULL.
	* 70% of the NULL pleas are Felonies
	* 19% of NULL pleas are for CodeSection 19.2-306, "Revocation of suspension of sentence and probation", followed by Grand Larceny, Forgery, drug sales, and drug possession, all within the 4th percent. 
		* 90.8% of all Revocation charges are NULL pleas (I should see whether this is true across all crime types)
	* Trials account for the highest percentage of NULL pleas, at 14%, 
		* 72% of Trial Hearings have a NULL plea.
	* followed by Grand Jury Hearings, at 12.9%. 
	* Plea Hearings account for 5.3% of NULL pleas, somewhere in the middle of the pack.
		* 64% of Plea Hearings have a NULL plea.


## SQL Notes:
* 
* 

## R Notes:
* The _analysis.R_ file has been set up with a connection to the database, but has no analysis in it. See file _old\_code\_archive/analysis-circuitcourt-prelim.R_ for some functions written with the old, incomplete database.
