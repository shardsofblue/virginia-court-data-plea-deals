# File to store To Do tasks and make notes between collaborators

## Overall Notes:
* Roxanne has been working on this data within SQLPro for Postgre, which is installed on computer 3210-09. 
* Excel file export2 has the latest work

TODO on 10/1:
* In SQL, pull back to 10 years instead of just 2017
* In XLS clean data by: sort-by Charge, combine similar charges

What I have learned:
As of... 9/26
* The REF_NOT_FOUND crimes were a data error. 
* Null pleas at hearings were because so many of the charges are dropped by the prosecutor.
* Instead of looking at the Hearings table at all, we can use the main Case table and use the ConcludedBy field to tell us whether a case was determined based on a guilty plea or a trial.
* 90% of the pleas are NULL.
* 70% of the NULL pleas are Felonies
* 19% of NULL pleas are for CodeSection 19.2-306, "Revocation of suspension of sentence and probation", followed by Grand Larceny, Forgery, drug sales, and drug possession, all within the 4th percent. 
	* 90.8% of all Revocation charges are NULL pleas (I should see whether this is true across all crime types)
* Trials account for the highest percentage of NULL pleas, at 14%, 
	* 72% of Trial Hearings have a NULL plea.
* followed by Grand Jury Hearings, at 12.9%. 
* Plea Hearings account for 5.3% of NULL pleas, somewhere in the middle of the pack.
	* 64% of Plea Hearings have a NULL plea.
* 

<<<<<<< HEAD
###To-do:
* [DONE] Figure out why so many values are NULL
* [IN PROGRESS] Compare sentence time with plea
=======
### To-do:
* [DONE] Figure out why so many values are NULL
* Compare time served with hearing plea
* Count the number of charges per person_id
* [IN PROGRESS] Discover the mean sentence time of plea  vs. trial
* Find average sentence time per race


## SQL Notes:
* 
* 

## R Notes:
* The _analysis.R_ file has been set up with a connection to the database, but has no analysis in it. See file _analysis-circuitcourt-prelim.R_ for some functions written with the old, incomplete database.
