# UCSD-Research
This repository contains the code that I wrote for the electrogram signal quality project that I completed with [Rappel Laboratory at UCSD](https://rappel.ucsd.edu/) and [the Computational Arrhythmia Research Laboratory Stanford](http://web.stanford.edu/group/narayanlab/cgi-bin/wordpress/#:~:text=Welcome%20to%20the%20Computational%20Arrhythmia,clarify%20mechanisms%20and%20improve%20therapy.). The goal of the project was to improve ablation techniques in cardiac arrhythmia patients by developing an algorithm in MATLAB to quantify the quality of egms of patients. The software program contained here was coded entirely by me in MATLAB. This project has been completed, with a paper submitted to [Frontiers in Physiology](https://www.frontiersin.org/journals/physiology) which has not been published yet but is currently under review.

![Fig1](UCSD_Github_Images/Fig1.png)

Three different calculus based methods are used to compute the quality of electrograms, MAM, MIM and AMM. MAM looks at the positive derivative of the electrogram, MIM looks at the negative derivative of the electrogram and AMM simply takes on whichever value is larger- MIM or MAM. The software program creates heat maps to visualize egm quality in specific locations of the heart. Additionally, ROC curves and histograms are computed to visualize how well the program can differentiate between low quality and high quality electrograms. After rigorous testing of the program, successful results were found in an analysis of 60 patient electrograms.

**High quality color map. The results from the program indicate that patients with higher quality will be more likely to have a successful ablation of atrial fibrillation.**

![Fig3](UCSD_Github_Images/LowQ_Colormap.jpeg)

**Low quality color map.**
