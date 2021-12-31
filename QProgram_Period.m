%Program to look at quality. Where quality is defined as longer period = higher quality
%The program saves color maps, histograms,2-tailed t-test p values, and
%ROC Curves

clear all;
close all;
clc

tt=1;
nn=1;
bb=1;
gg=1;
oo=1;

TermPatients = ["S-0003", "S-0010","S-0011","S-0012",...
    "S-0014","S-0022","S-0033","S-0142","S-0072","S-0127",...
    "S-0080","S-0235","S-0312","S-0334","S-0341","S-0423",...
    "S-0427","S-0013","S-0024","S-0091","S-0106","S-0111", "S-0137","S-0154",...
    "S-0159","S-0162","S-0168","S-0183","S-0193"]; %modify this to hold all of your term patients
% leave out "S-0049" for now

NonTermPatients = ["S-0171", "S-0275","S-0302","S-0323",...
    "S-0325","S-0338","S-0342","S-0346","S-0352","S-0355",...
    "S-0356","S-0362","S-0367","S-0368","S-0369","S-0370",...
    "S-0371","S-0374","S-0380","S-0383","S-0104","S-0290","S-0348","S-0472","S-0481","S-0526",...
    "S-0574","S-0658","S-0705","S-0722"]; %modify this to hold all of your non term patients

locData = '60 LA1 txt File EGMs'; %Modify to the location of the folder that contains the EGM's as txt files

nTs = length(TermPatients); %# of Term Patients
nNTs = length(NonTermPatients); %# of Non Term Patients

qAvPT = zeros(1,nTs);
qAvPNT = zeros(1,nNTs);

nPs = nTs+nNTs; %Total # of Patients

AllPatients= cat(2,TermPatients,NonTermPatients); %Array to hold all patients starts w term patients

%The folder that the results are saved in is UCSD Research Project
locResults = 'Quality Results Period Metric'; %Modify to name of folder you want to save data to

%Location of T-test p-vals,spreadsheet, patient averages,AUC, OCTROCPTS
qResultsOtherRF = strcat(locResults,'/VIP Vars Q Program/Vars.mat');

%Location of ROC Curve
ROCLoc = strcat(locResults,'/ROC Curves/ROCPeriod.fig');

%Location of Histogram Results
HistogramAvP=strcat(locResults,'/Histograms/HistogramAvP.fig');
HistogramEgmP=strcat(locResults,'/Histograms/HistogramEgmP.fig');

%Initialize Av. patient quality array with zeros for speed
qAvP = zeros(1,nPs);

%Initialize arrays that hold all egm period #s with zeros for speed 
TegmQ = zeros(1, nTs*64);
NTegmQ = zeros(1, nNTs*64);
AllEGMPers = zeros(1, nPs*64);

%Sampling rate
fs = 1000;

%Cutoff frequency
cf = 9;

%% For loop for n Patients
for y = 1:nPs %y = 1: # Patients

%Initialize quality array per egm with zeros for speed
qual = zeros(1, 64);

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

%% For loop for determining quality of 64 electrograms
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
    Period = 0;
else
    Period = int64(timeOccurs(maxIndex+1) - timeOccurs(maxIndex)); %int64 rounds up or down
end

    qual(p) = Period; % This array holds the period for all 64 egms. Should have length of 64.
    
    if strcmp(s4,'/Term/') == 1
        TegmQ(tt)= Period;
        tt= tt+1;
    elseif strcmp(s4,'/Non Term/') == 1
        NTegmQ(nn)= Period;
        nn=nn+1;
    end
    AllEGMPers(oo) = Period;
    oo=oo+1;
end

if strcmp(s4,'/Term/') == 1
   qAvPT(bb) = mean(qual); % This array holds the average period per term patient
   bb=bb+1;
elseif strcmp(s4,'/Non Term/') == 1
   qAvPNT(gg) = mean(qual); % This array holds the average period per non term patient
   gg=gg+1;
end

qAvP(y) = mean(qual); % This array holds the average period per patient

end %end of code to analyze all patients quality

%% Get max average patient period and max egm period for normalization to make ROC Curves
normAV = max(qAvP);
AvPTNormed = qAvPT/normAV;
AvPNTNormed = qAvPNT/normAV;
%% Calculate average term and non term period per patient
averageTPer = mean(qAvPT);
averageNTPer = mean(qAvPNT);
%% End of quality analyzation: Make Histograms
%Code for creating average patient term and non term arrays for doing the
%ttest

%% ttest
[hh,pVal] = ttest2(qAvPT,qAvPNT);

%% vvvvvv Histogram Comparison for Average Periods Per Patient vvvvvv
[NNAv,edges] = histcounts(qAvPT); %Calculate bin size
NBins = length(NNAv); %Calculate bin size

AvPHist = figure; Aa = histogram(qAvPT, NBins);
title('Histogram for Average Period Per Patient','FontSize',36);
xlabel('Average Period','FontSize',24);
ylabel('Number of Patients','FontSize',24);
%figure; 
hold on
Bb = histogram(qAvPNT, NBins);
title('Histogram for Average Period Per Patient','FontSize',36);
xlabel('Average Period','FontSize',24);
ylabel('Number of Patients','FontSize',24);
legend('term','non-term','FontSize',24)
hold off
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%% vvvvvv Histogram Comparison for Period Per Egm vvvvvv
[NN,edgesEgm] = histcounts(TegmQ); %Calculate bin size
NBinsEgm = length(NN); %Calculate bin size

EgmPHist = figure; Cc = histogram(TegmQ, NBinsEgm);
title('Histogram for Period Per Egm','FontSize',36);
xlabel('Period','FontSize',24);
ylabel('Number of Patients','FontSize',24);
%figure; 
hold on
Dd = histogram(NTegmQ, NBinsEgm);
title('Histogram for Period Per Egm','FontSize',36);
xlabel('Period','FontSize',24);
ylabel('Number of Patients','FontSize',24);
legend('term','non-term','FontSize',24)
hold off
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

%% Save histograms
savefig(AvPHist,HistogramAvP);
savefig(EgmPHist,HistogramEgmP);

%% Make ROC Curves
termLabels = ones(1,nTs);
nonTermLabels = zeros(1,nNTs);

Scores = cat(2,AvPTNormed,AvPNTNormed);
%Add Arrays together to form labels array
labels = cat(2,termLabels,nonTermLabels); %Labels is the same for abs, max, min, but not same for kulkik

%AMM ROC
[Xx, Yy,Tt,AUC,OPTROCPT] = perfcurve(labels,Scores,'1');
ROC = figure; plot(Xx,Yy);
title('ROC Curve Using Period as Quality Metric','FontSize',36)
ylabel('True Positive Rate','FontSize',24);
xlabel('False Positive Rate','FontSize',24);

%% vvvvvv Save ROC Curves vvvvvv
savefig(ROC, ROCLoc);
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%% Save T-test p vals, patient averages
save(qResultsOtherRF,'pVal','TegmQ','NTegmQ','qAvPT','qAvPNT', 'averageTPer', 'averageNTPer',...
    'AUC','OPTROCPT');

%% Prash's Filtering method
function filteredData = uniFilter(dataIn, Fs)

    %butterworth bandpass filter and notch

    lowf = 2.5; highf = 30 ; % default frequency settings

    [b, a] = butter(4, [lowf highf]/(Fs/2), 'bandpass'); %prep bandpass filter

    filteredData = filtfilt(b, a, dataIn);

    [b, a] = butter(4, [55 65]/(Fs/2), 'stop'); %prep notch filter

    filteredData = filtfilt(b, a, filteredData);

end