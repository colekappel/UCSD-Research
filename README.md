# UCSD-Research
This repository contains the code that I wrote for the electrogram signal quality project I completed with [Rappel Laboratory at UCSD](https://rappel.ucsd.edu/) and [the Computational Arrhythmia Research Laboratory Stanford](http://web.stanford.edu/group/narayanlab/cgi-bin/wordpress/#:~:text=Welcome%20to%20the%20Computational%20Arrhythmia,clarify%20mechanisms%20and%20improve%20therapy.) The goal of the project was to improve ablation techniques in cardiac arrhythmia patients by developing an algorithm in MATLAB to quantify the quality of egms of patients. The software programs contained here were coded entirely by me in MATLAB.

![Fig1](UCSD_Github_Images/Fig1.png)

**The Quality Program (QualityProgram.m)**

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

**High quality color map. The results from the program indicate that patients with higher quality will be more likely to have a successful ablation of atrial fibrillation.**

![Fig3](UCSD_Github_Images/LowQ_Colormap.jpeg)

**Low quality color map.**
