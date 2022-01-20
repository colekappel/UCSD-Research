# UCSD-Research
Documentation for the electrogram signal quality quantification project with UCSD and Stanford

![Fig1](UCSD-Github-Images/Fig1.png)

**newProgramMax64Traces.m Documentation (aka ‘The Quality Program’)**

Saving Results
•	locResults – the folder within the folder that contains newProgramMax64Traces.m that holds all of the quality results. This is the only thing you’ll need to change on the program with regards to saving results.

•	6 folders must be in locResults:

1.	‘VIP Vars Q Program’
2.	‘ROC Curves’
3.	‘Histograms’ 
4.	‘Color Maps AMM’ – within this folder there must be a ‘Term’ and ‘Non Term’ Folder
5.	‘Color Maps MAM’ – within this folder there must be a ‘Term’ and ‘Non Term’ Folder
6.	‘Color Maps MIM’ – within this folder there must be a ‘Term’ and ‘Non Term’ Folder

Patient Data Source
•	TermPatients – array that holds term patients. You will need to modify this to have it hold the names of all of your term patients.
•	NonTermPatients - array that holds non term patients. You will need to modify this to have it hold the names of all of your non term patients.
•	locData- This is the folder within the folder that contains newProgramMax64Traces.m that holds the patients EGM’s as txt files. Within this folder there must be a ‘Term’ and ‘Non Term’ Folder holding those patients data. The names within the ‘Term’ and ‘Non Term’ folders should formatted as S-XXXX.txt (i.e. S-0348.txt).
•	‘VIP Vars Q Program’ contains variables with self-explanatory names.

Run Time
Program run time is about 0.74 (min/patient)

**QProgram_Period.m Documentation**

-	Program to look at quality, where quality is defined as longer period = higher quality
The program saves color maps, histograms, 2-tailed t-test p values, and ROC Curves.
-	One histogram displays average period per patient and the other displays period for every single egm. 
-	For the ROC curve, the average period for each patient was normalized by dividing by the maximum average period out of all the patients. So “Quality” then ranges from 0 to 1 with 1 corresponding to the highest quality and 0 corresponding to the lowest quality.
-	Fast runtime. 
-	The variable, ‘locData’ is the same as it is in ‘newProgramMax64Traces.m’
-	The variable, ‘locResults’ is the name of the result folder which should inside it contain three folders named: ‘VIP Vars Q Program’ , ‘Histograms’, and ‘ROC Curves’ – the data will can be found in these locations after the program runs.
-	Inside ‘VIP Vars Q Program’, ‘pVal’ is the 2 tailed t test p value, ‘averageTPer’ is the average term period, ‘averageNTPer’ is the average non term period, ‘AUC’ is the area under the ROC curve and ‘OPTROCPT’ is the optimal operating point of the ROC curve

