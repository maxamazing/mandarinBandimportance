%script to optimize the BIF for worst performance and show that our method
%can show significantly differences in SRT with special BIFs

% clean up
clc, clear
close all


%import data
dataPath ="bin/";
noise=fileToIta(dataPath+"icra1.wav","noise","Fs");

%taken from the measurement in dB
refNoiseLevel=65;   %dB SPL
bifDat=ita_SII_BIF();

%load colorblindness helper
load('colorblind_colormap.mat')
colorblind=[0,0,1;0,0,1;1,0,0;1,0,0];


%%

%comment and uncomment depending on prediction scheme
setting = struct('refSii',{},'title',{},'genspec',{},'nu',{},'bif',{},'fileName',{},'refshift',{},'flag',{},'legendOn',{});


%constantBIF
endId=length(setting)+1;
setting(endId).refshift=0;
setting(endId).title="";
setting(endId).fileName="siiPred_refCond_constantBIF.";
setting(endId).bif=bifDat.constant;
setting(endId).genspec=false;
setting(endId).nu=22;
setting(endId).flag="worstBIF";
setting(endId).legendOn=false;
setting(endId).refSii=getRefSIIMeasurement(setting(endId).refshift,dataPath,setting(endId).bif );

initialBif      = bifDat.constant;        % a reasonable starting guess
id              = 1;                      % index into your setting array
settingOrig = setting(id);               % a scalar struct, not an array

objFun = @(b) calcR(b, settingOrig, dataPath, noise, refNoiseLevel);

%Simple derivative‑free search (slow but okay)
options = optimset('Display','iter','TolX',1e-4);
[bestBif, fval] = fminsearch(objFun, initialBif, options);

fprintf('\n=== Optimisation finished ===\n');
fprintf('Best bif  = %.6f\n', bestBif);
fprintf('Maximum r = %.4f\n', fval);  

function r = calcR(bif, setting, dataPath, noise, refNoiseLevel)
%CALCR  Compute the correlation coefficient r for a given bifurcation value.
%
%   r = CALCR(bif, setting, dataPath, noise, refNoiseLevel)
%
%   INPUT
%     bif               – scalar, the bifurcation parameter you want to optimise
%     setting           – struct array (as used in your original script)
%                         must contain at least the fields
%                         .bif, .refSii, .refshift
%     dataPath          – string, folder that holds the *.wav* files and the
%                         measuredData*.mat files
%     noise, refNoiseLevel – vectors used by max_calibrate (they are constant
%                         for all calls, so we pass them once)
%
%   OUTPUT
%     r                 – Pearson correlation coefficient between the
%                         measured SPLs (x) and the predicted SPLs (y)
%

setting.bif = abs(bif)/sum(abs(bif));   %normalize and take absolute value

load(fullfile(dataPath,'measuredDataFemale.mat'), ...
     'datLombardF','datPlainF');
load(fullfile(dataPath,'measuredDataMale.mat'), ...
     'datLombardM','datPlainM');

%--------female--------------
%import measurement
load(dataPath+"measuredDataFemale.mat","datLombardF","datPlainF")

%plain
filterPlain=dir(dataPath+"*_F*Plain*");
for n=1:length(filterPlain)

    signal=fileToIta(dataPath+filterPlain(n).name,"signal","Pa");
    for i=1:length(setting.refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datPlainF{2+i,n}=ita_SRT(signalCal,noiseCal,setting.refSii(i),setting.bif);
    end
end

%lombard
filterLombard=dir(dataPath+"*_F*Lombard*");
for n=1:length(filterLombard)
    signal=fileToIta(dataPath+filterLombard(n).name,"signal","Pa");
    for i=1:length(setting.refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datLombardF{2+i,n}=ita_SRT(signalCal,noiseCal,setting.refSii(i),setting.bif);
    end
end


%--------male--------------
%import measurement
load(dataPath+"measuredDataMale.mat","datLombardM","datPlainM")

%plain
filterPlain=dir(dataPath+"*_M*Plain*");
for n=1:length(filterPlain)
    signal=fileToIta(dataPath+filterPlain(n).name,"signal","Pa");
    for i=1:length(setting.refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datPlainM{2+i,n}=ita_SRT(signalCal,noiseCal,setting.refSii(i),setting.bif);
    end
end

%lombard
filterLombard=dir(dataPath+"*_M*Lombard*");
for n=1:length(filterLombard)
    signal=fileToIta(dataPath+filterLombard(n).name,"signal","Pa");
    for i=1:length(setting.refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datLombardM{2+i,n}=ita_SRT(signalCal,noiseCal,setting.refSii(i),setting.bif);
    end
end

% measurement (first row of each cell)
x = {datPlainF{1,:}, datLombardF{1,:}, datPlainM{1,:}, datLombardM{1,:}};

% prediction – third row, corrected by the global shift
y = {datPlainF{3,:}, datLombardF{3,:}, datPlainM{3,:}, datLombardM{3,:}};

xx = cat(2, x{:});   % 1 × N vector
yy = cat(2, y{:});   % 1 × N vector

R  = corrcoef(xx(:), yy(:));   % 2×2 matrix
r  = R(1,2);                   % the off‑diagonal element

end



