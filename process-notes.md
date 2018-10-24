# Process Notes

*Last updated: Oct. 24*

Overall Goal: Compare sentence lengths from charges that ended with guilty pleas to those that ended with a trial.

## 1. Data overview: SQL
  * Familiarization queries
  * Understanding NULL pleas
  	* Per legal expert: NULL pleas are primarily because the prosecutor dismissed the charge before a plea was entered.

## 2. Pull following data from SQL to Excel for analysis:
  * Count of cases
  * Average sentence time
  * Filtered by how concluded: Trial by jury, trial by judge AND guilty plea
  * Grouped together by charge code
  
## 3. Prepare data to be grouped by crime type
  * **VA criminal code key:**
    * Source: _https://law.lis.virginia.gov/law-library_
    * Each chapter is in a separate .csv file
    * Chapters have varying levels of specificity. Some include subsections, some do not.
    * Subsections and chapters are sometimes vague. (e.g. "Attempts")
    * Fields sometimes included "through" or were otherwise not straight numeric lookups
      * **Solution:**
        * Imported all .csv files into a single "key" sheet
        * Created a standardized clean field capturing the chapter with a maximum of one level of subsection
  * **SQL export cleaning:**
  	* Some charges are listed with two crime codes in one field
  	* Crime codes sometimes entered with subsections, sometimes not
  	  * Subsections are delineated with varying punctuation
  	  * Not all subsections are in the imported criminal code lookup key
  	  * Some subsections have been removed from the law entirely
  	  * Some laws have changed over the years. In particular, data capturing 18.2-91 has multiple entries beginning with a letter (e.g. Z.18.2-91). Frederick County Circuit Court clerk's office looked up some old cases and theorized that these were later merged into subsections of 18.2-91 (e.g. 18.2-91.1). **We need to verify this.** Example cases in Frederick:
  	    * http://ewsocis1.courts.state.va.us/CJISWeb/MainMenu.do
  	    * CR03000665-00 (Z.)
  	    * CR02000376-00 (Z.)
  	    * CR07000120-00 (Z.)
  	    * CR05000712-00 (A.)
  	    * CR03000449-00 (B.)
  	    * CR07000117-00 (Z.)
  	* **Solution:** 
  	  * Reduced all crime codes to show a maximum of one level of subsection
  	  * Standardized punctuation
  	  * In some cases, pulled the subsection name instead of the chapter name
  	  * Stripped prefix letters

## 4. Group by crime type
  * 
  	
    
    
  
    
SEAN: Should I be running average of average trial sentence or sum of average trial sentence?