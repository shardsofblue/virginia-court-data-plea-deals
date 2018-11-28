# Process Notes for va-court-analysis

*Last updated: Nov. 28*

Overall Goal: Compare sentence lengths from charges that ended with guilty pleas to those that ended with a trial.

## 1. Data overview in SQL
  * Familiarization queries
  * Understanding NULL pleas
  	* Per legal expert: NULL pleas are primarily because the prosecutor dismissed the charge before a plea was entered.

## 2. Pull the following data from SQL to Excel for analysis:
  * Using _CircuitCriminalCase_ table
    * Count of cases
    * Average sentence time
    * Filtered by how concluded: Trial by jury, trial by judge AND guilty plea
    * Grouped together by charge code
    * For years 2007-2017
  
## 3. Prepare data and group by crime type
  * **VA criminal code key:**
    * Source: _https://law.lis.virginia.gov/law-library_
    * Each chapter is in a separate _.csv_ file
    * Chapters have varying levels of specificity. Some include subsections, some do not.
    * Subsections and chapters are sometimes vague. (e.g. "Attempts")
    * Fields sometimes included "through" or were otherwise not straight numeric lookups
    * **Solution:**
      * Imported all _.csv_ files into a single "key" sheet
      * Created a standardized clean field capturing the chapter with a maximum of one level of subsection
  * **SQL export cleaning:**
  	* Some charges listed with two crime codes in one field
  	* Crime codes sometimes entered with subsections
  	  * Subsections are delineated with varying punctuation
  	  * Not all subsections are in the imported criminal code lookup key
  	  * Some subsections have been removed from the law entirely since the charge was filed
  	  * Data capturing _18.2-91_ has multiple entries beginning with a letter (e.g. _Z.18.2-91_). Frederick County Circuit Court clerk's office looked up some old cases and theorized that these were later merged into subsections of _18.2-91_ (e.g. _18.2-91.1_). **We need to verify this.** Example cases in Frederick:
  	    * VA Frederick County case lookup: <http://ewsocis1.courts.state.va.us/CJISWeb/MainMenu.do>
  	    * CR03000665-00 (Z.)
  	    * CR02000376-00 (Z.)
  	    * CR07000120-00 (Z.)
  	    * CR05000712-00 (A.)
  	    * CR03000449-00 (B.)
  	    * CR07000117-00 (Z.)
  	* **Solution:** 
  	  * _Combination of hand cleaning, Excel functions, and [OpenRefine.org](www.openrefine.org)_
  	  * Reduced many crime codes to one level of subsection
  	  * Standardized punctuation
  	  * In some cases, pulled the subsection name instead of the chapter name
  	  * Stripped prefix letters
  	  * Broke multiple crime code entries into two fields. Dropped info for charges that were paired.
  	    * If I append these to the bottom, it will create more records. But if I ignore them, they are effectively being erased. Analysis shows they make up less than 1% of the data (.33%).
  * **Grouping by crime type**
    * Excel pivot table grouped by crime code chapter or subsection's looked-up text
    * Compute difference between average sentence times of plea vs. trial (judge and jury combined)
  * **Verification**
  	* Checked rough totals between Excel and SQL
  	
## 4. Preliminary analysis
  * A quick preliminary analysis of the charges resulted in some unexpected findings, but these findings are not reliable because they do not take into account life sentences, sentence suspensions or multiple charges brought at the same time.
  * See file _[preliminary\_findings.md](https://github.com/shardsofblue/va-court-analysis/blob/master/old\_code\_archive/preliminary\_findings.md)_
    
## 5. Capital Murder analysis
  * The story evolving at the copy desk required an analysis of capital murder cases.
  * Accurate understanding of the issue required aggregation of cases brought with multiple charges
    * Hand-entered aggregations of cases grouped by name for five years (146 records)
  * Coded Y/N for whether capital murder charges:
    * were amended
    * resulted in a life sentence
    * included a sentence suspension
  * Totalled sentence times per case and adjusted them for suspensions
  * Noticed during data entry that a high number of cases were brought as attempted capital murder of a police officer and then amended upon appeal to a lesser charge (usually assault).
    * Coded to search the charge description (a hand-entered summary of the charges) for key words and crime codes that aligned with this noted pattern
  * Please see [this memo](https://github.com/shardsofblue/va-court-analysis/blob/master/memo\_nov20.md) for a full description of the findings and limitations of this analysis.