%The program has been corrected so it uses autocorrelation to find the
%period of traces. Last Modified: June, 1 2021
%The program saves color maps, histograms,2-tailed t-test p values, a
%spreadsheet of average quality per patient, ROC Curves

clear all;
close all;
clc

TermPatients = ["S-0003", "S-0010","S-0011","S-0012",...
    "S-0014","S-0022","S-0033","S-0142","S-0072","S-0127",...
    "S-0080","S-0235","S-0312","S-0334","S-0341","S-0423",...
    "S-0427","S-0013","S-0024","S-0091","S-0106","S-0111", "S-0137","S-0154",...
    "S-0159","S-0162","S-0168","S-0183","S-0193"]; %modify this to hold all of your term patients -
%,"S-0049" is left out of term pts. for now due to missing epoch

NonTermPatients = ["S-0171", "S-0275","S-0302","S-0323",...
    "S-0325","S-0338","S-0342","S-0346","S-0352","S-0355",...
    "S-0356","S-0362","S-0367","S-0368","S-0369","S-0370",...
    "S-0371","S-0374","S-0380","S-0383","S-0104","S-0290","S-0348","S-0472","S-0481","S-0526",...
    "S-0574","S-0658","S-0705","S-0722"]; %modify this to hold all of your non term patients

locData = '60 LA1 txt File EGMs'; %Modify to the location of the folder that contains the EGM's as txt files

nTs = length(TermPatients); %# of Term Patients
nNTs = length(NonTermPatients); %# of Non Term Patients

nPs = nTs+nNTs; %Total # of Patients

AllPatients= cat(2,TermPatients,NonTermPatients); %Array to hold all patients starts w term patients

%The folder that the results are saved in is UCSD Research Project
locResults = 'Quality Results n59 LA1'; %Modify to name of folder you want to save data to

%Location of T-test p-vals,spreadsheet, patient averages,AUC, OCTROCPTS
qResultsOtherRF = strcat(locResults,'/VIP Vars Q Program/Vars.mat');

%Location of ROC Curves
maxRocRF = strcat(locResults,'/ROC Curves/MaxROC.fig');
minRocRF = strcat(locResults,'/ROC Curves/MinROC.fig');
absRocRF = strcat(locResults,'/ROC Curves/AbsROC.fig');

%Location of Histogram Results
HistogramMIMRF=strcat(locResults,'/Histograms/HistogramMIM.fig');
HistogramMAMRF=strcat(locResults,'/Histograms/HistogramMAM.fig');
HistogramAMMRF=strcat(locResults,'/Histograms/HistogramAMM.fig');

qMAMAvg = zeros(1,nPs); %These will hold the mean quality for each patient
qMIMAvg = zeros(1,nPs);
qAMMAvg = zeros(1,nPs);

%Sampling rate
fs = 1000;

%Cutoff frequency
cf = 9;

for y = 1:nPs %y = 1: # Patients

qMax=zeros(1, 64); %64 for egms
qMin=zeros(1, 64);
qAbs=zeros(1,64);

sX = num2str(AllPatients(y)); 

if y> nTs %After analyzing term patients, analyze non terms
    s4='/Non Term/';
    sTorNT ='NT';
else
    s4 = '/Term/';
    sTorNT ='T';
end

%Location of color maps 
resultFileMaxCM = strcat(locResults,'/Color Maps MAM',s4,sX,'ColorMapMax',sTorNT,'.jpg'); 
resultFileMinCM = strcat(locResults,'/Color Maps MIM',s4,sX,'ColorMapMin',sTorNT,'.jpg');
resultFileAbsCM = strcat(locResults,'/Color Maps AMM',s4,sX,'ColorMapAbs',sTorNT,'.jpg');

A = dlmread(strcat(locData,s4,sX,'.txt')); %Change to Term or Non Term

for p=1:64 %This is always 1 to 64 for electrograms

v=A(:,p);
t=1:length(v);

fclose('all');

%Apply prash's filter settings
vF = uniFilter(v, fs);

%Autocorrelation code for period finding
%Use filtfit to soften the rough edges of the curve:
[b,a] = butter(4,cf/(fs/2));

vS = filtfilt(b,a,vF); %Smooth the raw data

%Use auto correlation to find the period of the curve:

[autocor,lags]= xcorr(vS); %vS is the smoothed voltage  data

[pkHeight,timeOccurs] = findpeaks(autocor); %Find max points - timeOccurs holds the time at which peaks occur

%find the max pkHeight element number
for n = 1:length(pkHeight)
    if max(pkHeight) == pkHeight(n)
        maxIndex = n;
    end
end

if isempty(timeOccurs)
    qMax(p) = 0;
    qMin(p) = 0;
    
else
    Period = int64(timeOccurs(maxIndex+1) - timeOccurs(maxIndex)); %int64 rounds up or down
   
    %% Part added to start the analyzation at half the period
    %v=v(int64(Period/2):end);
    %vF=vF(int64(Period/2):end);
    %t=1:length(vF);
    
    %% Continue code for analyzing quality

%Create a dv/dt array:
dvDtArray = zeros(1, length(vF)-2);
x = zeros(1, length(vF)-2);
for i = 2:(length(vF)-1)
    deltaT = t(i+1)-(t(i-1));
    deltaV = vF(i+1)-vF(i-1);
    dvDtArray(i-1) = deltaV/deltaT;
    x(i) = i;
end

%Now we want to find the peaks in each interval of the trace and create an
%array of first largest peak divided by second largest peak (lets start
%with max points first then do min points
msSearched = (length(dvDtArray)-Period); %Search less amount of time to only look at full periods
numIntervals = floor(msSearched/Period); %Truncate the number so the for b loop doesn't run too many times

low = 1;
high = Period;
qualityArrayMax =zeros(1, numIntervals);
qualityArrayMin =zeros(1, numIntervals);

for b = 1: numIntervals
    searchVct = zeros(1, Period);
    c = zeros(1, Period);
    j=1;
    for a = low:high
        searchVct(j) = dvDtArray(a);
        c(j) = a;
        j=j+1;
    end    

    [maxVSort,xsor] = findpeaks(searchVct,c,'SortStr','descend');
    [minVSort,psor] = findpeaks(-searchVct,c,'SortStr','descend');
   
    rowsToDelete = maxVSort<0;
    maxVSort(rowsToDelete)=[];
    
    newRowsToDelete = minVSort<0;
    minVSort(newRowsToDelete)=[];
  

    if isempty(maxVSort)
        qualityArrayMax(b) = 0;
    elseif length(maxVSort)==1
        qualityArrayMax(b) = 1;
    else
        %mean of maxVsort without absolute max point:
        meanMaxVSort = (sum(maxVSort)-maxVSort(1))/(length(maxVSort)-1);
        
        qualityArrayMax(b) = (maxVSort(1)-meanMaxVSort)/(maxVSort(1));
        
    end
    
    if isempty(minVSort)
        qualityArrayMin(b) = 0;
    elseif length(minVSort)==1
        qualityArrayMin(b) = 1;
    else
        %mean of minVsort without absolute max point:
        meanMinVSort = (sum(minVSort)-minVSort(1))/(length(minVSort)-1);
        
        qualityArrayMin(b) = (minVSort(1)-meanMinVSort)/(minVSort(1));
    end
    
    low = low + Period;
    high= high + Period;
end

%plot(t,vF,x,dvDtArray);
qMax(p) =mean(qualityArrayMax);
qMin(p) = mean(qualityArrayMin);
if qMax(p)>qMin(p)
    qAbs(p)=qMax(p);
elseif qMin(p)>qMax(p)
    qAbs(p)=qMin(p);
end


end
end
qMAMAvg(y)=mean(qMax);
qMIMAvg(y)=mean(qMin);
qAMMAvg(y)=mean(qAbs);

%Make color maps for each patient:

%AMM color Map
iMax = 8;
jMax = 8;
i=1;
rot = zeros(iMax, jMax);
for aIdx = 1:iMax
     for bIdx = 1:jMax
        rot(aIdx,bIdx) = qAbs(i);
        i = i + 1;
     end
end
figure; aMM=heatmap(rot, 'ColorMap',jet);
aMM.YData = {'A','B','C','D','E','F','G','H'};
aMM.Title = {['AMM Color Map of Quality Results for Patient: ',sX]}; %Change each time
caxis(aMM,[0 1]);


%MAM color Map
iMax = 8;
jMax = 8;
i=1;
rot = zeros(iMax, jMax);
for aIdx = 1:iMax
     for bIdx = 1:jMax
        rot(aIdx,bIdx) = qMax(i);
        i = i + 1;
     end
end
figure;mAM=heatmap(rot, 'ColorMap',jet);
mAM.YData = {'A','B','C','D','E','F','G','H'};
mAM.Title = {['MAM Color Map of Quality Results for Patient: ',sX]}; %Change each time
caxis(mAM,[0 1]);

%MIM color Map
iMax = 8;
jMax = 8;
i=1;
rot = zeros(iMax, jMax);
for aIdx = 1:iMax
     for bIdx = 1:jMax
        rot(aIdx,bIdx) = qMin(i);
        i = i + 1;
     end
end
figure; mIM=heatmap(rot, 'ColorMap',jet);
mIM.YData = {'A','B','C','D','E','F','G','H'};
mIM.Title = {['MIM Color Map of Quality Results for Patient: ',sX]}; %Change each time
caxis(mIM,[0 1]);

%Save color maps
exportgraphics(aMM,resultFileAbsCM); 
exportgraphics(mAM,resultFileMaxCM);
exportgraphics(mIM,resultFileMinCM);

end %end of code to analyze all patients quality

%Code for creating average patient term and non term arrays for doing the
%ttest
qMAMAvgT=zeros(1,nTs);
qMIMAvgT=zeros(1,nTs);
qAMMAvgT=zeros(1,nTs);

qMAMAvgNT=zeros(1,nNTs);
qMIMAvgNT=zeros(1,nNTs);
qAMMAvgNT=zeros(1,nNTs);

for k = 1:nTs
    qMAMAvgT(k)=qMAMAvg(k);
    qMIMAvgT(k)=qMIMAvg(k);
    qAMMAvgT(k)=qAMMAvg(k);
end
i=1;
startNumTerms = nTs +1;
for k =startNumTerms:nPs
    qMAMAvgNT(i)=qMAMAvg(k);
    qMIMAvgNT(i)=qMIMAvg(k);
    qAMMAvgNT(i)=qAMMAvg(k);
    i=i+1;
end

%Create spreadsheet of average qualities for each patient (AllPatientAvgSS is the spreadsheet)
AllPatientAvgSS(:,1)=cat(2,"Patients",AllPatients,"Avg. term Q:", "Avg. non-term Q:");
AllPatientAvgSS(:,2) = cat(2,"MAM",qMAMAvg,mean(qMAMAvgT),mean(qMAMAvgNT));
AllPatientAvgSS(:,3) = cat(2,"MIM",qMIMAvg,mean(qMIMAvgT),mean(qMIMAvgNT));
AllPatientAvgSS(:,4) = cat(2,"AMM",qAMMAvg,mean(qAMMAvgT),mean(qAMMAvgNT));

%Add code for T-Tests
[hMAM,pMAM] = ttest2(qMAMAvgT, qMAMAvgNT);
[hMIM,pMIM] = ttest2(qMIMAvgT, qMIMAvgNT);
[hAMM,pAMM] = ttest2(qAMMAvgT, qAMMAvgNT);

%Added code for histograms
amm = figure; a = histogram(qAMMAvgT);
title('Histogram for Average Quality Per Patient Abs Method (AMM)');
xlabel('Average Quality');
ylabel('Number of Patients');
hold on
%figure; 
b = histogram(qAMMAvgNT);
title('Histogram for Average Quality Per Patient Abs. Method (AMM)','FontSize',36);
xlabel('Average Quality','FontSize',24);
ylabel('Number of Patients','FontSize',24);
legend('term','non-term','FontSize',24)
hold off

%vvvvvv Max Histogram Comparison vvvvvv
mam = figure; c = histogram(qMAMAvgT);
title('Histogram for Average Quality Per Patient Max Method (MAM)','FontSize',36);
xlabel('Average Quality','FontSize',24);
ylabel('Number of Patients','FontSize',24);
%figure; 
hold on
d = histogram(qMAMAvgNT);
title('Histogram for Average Quality Per Patient Max Method (MAM)','FontSize',36);
xlabel('Average Quality','FontSize',24);
ylabel('Number of Patients','FontSize',24);
legend('term','non-term','FontSize',24)
hold off
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%vvvvvv Min Histogram Comparison vvvvvv
mim = figure; e = histogram(qMIMAvgT);
title('Histogram for Average Quality Per Patient Min Method (MIM)','FontSize',36);
xlabel('Average Quality','FontSize',24);
ylabel('Number of Patients','FontSize',24);
%figure; 
hold on
f = histogram(qMIMAvgNT);
title('Histogram for Average Quality Per Patient Min Method (MIM)','FontSize',36);
xlabel('Average Quality','FontSize',24);
ylabel('Number of Patients','FontSize',24);
legend('term','non-term','FontSize',24)
hold off
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%Save histograms
savefig(mim,HistogramMIMRF);
savefig(mam,HistogramMAMRF);
savefig(amm,HistogramAMMRF);

%Make ROC Curves:

%Term holds 30 patients
termLabels = ones(1,nTs);
%Non term holds 30 patients
nonTermLabels = zeros(1,nNTs);

absScores = cat(2,qAMMAvgT,qAMMAvgNT);
maxScores = cat(2,qMAMAvgT,qMAMAvgNT);
minScores = cat(2,qMIMAvgT,qMIMAvgNT);

%Add Arrays together to form labels array
labels = cat(2,termLabels,nonTermLabels); %Labels is the same for abs, max, min, but not same for kulkik

%AMM ROC
[Xabs, Yabs,Tabs,AUCabs,OPTROCPTabs] = perfcurve(labels,absScores,'1');
ammROC = figure; plot(Xabs,Yabs);
title('ROC Curve for Abs. Method (AMM)','FontSize',36)
ylabel('True Positive Rate','FontSize',24);
xlabel('False Positive Rate','FontSize',24);

%MAM ROC
[Xmax, Ymax,Tmax,AUCmax,OPTROCPTmax] = perfcurve(labels,maxScores,'1');
mamROC = figure; plot(Xmax,Ymax);
title('ROC Curve for Max Method (MAM)','FontSize',36);
ylabel('True Positive Rate','FontSize',24);
xlabel('False Positive Rate','FontSize',24);

%MIM ROC
[Xmin, Ymin,Tmin,AUCmin,OPTROCPTmin] = perfcurve(labels,minScores,'1');
mimROC=figure; plot(Xmin,Ymin);
title('ROC Curve for Min Method (MIM)','FontSize',36);
ylabel('True Positive Rate','FontSize',24);
xlabel('False Positive Rate','FontSize',24);

%vvvvvv Save ROC Curves vvvvvv
savefig(mamROC, maxRocRF);
savefig(mimROC, minRocRF);
savefig(ammROC, absRocRF);
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%Save T-test p vals,spreadsheet, patient averages, AUC, OCTROCPTS
save(qResultsOtherRF,'pMAM','pMIM','pAMM','AllPatientAvgSS','qMAMAvg', 'qMIMAvg','qAMMAvg',...
    'AUCmin','OPTROCPTmin','AUCmax','OPTROCPTmax','AUCabs','OPTROCPTabs');

%% Prash's Filtering method
function filteredData = uniFilter(dataIn, Fs)

    %butterworth bandpass filter and notch

    lowf = 2.5; highf = 30 ; % default frequency settings

    [b, a] = butter(4, [lowf highf]/(Fs/2), 'bandpass'); %prep bandpass filter

    filteredData = filtfilt(b, a, dataIn);

    [b, a] = butter(4, [55 65]/(Fs/2), 'stop'); %prep notch filter

    filteredData = filtfilt(b, a, filteredData);

end