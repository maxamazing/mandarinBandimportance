function siiDist=getSii(signalFileNames,noiseFileName,refNoiseLevel,snr,bif)
%return the reference SII as the average over the given files for the given
%SNRs
%ARGUMENTS:
%   signalFileNames     datastructure as returned by malab dir() with a list of paths to the signal files
%   noiseFileName       path to the noise File
%   refNoiseLevel       noise level in dB SPL that was used during the experiment 
%   snr                 snr of the speech reception threshold. same Order
%       as in signalFileNames assumed
%   bif                 band importance function (see ita_SII_BIF())
%RETURNS
%   siiDist             distribution of SII values,filenames and snrs as a table
%       as a reference
%AUTHOR
%   max scharf Fr 23. Jul 13:25:32 CEST 2021 maximilian.scharf@uol.de

%errorcheck
if length(signalFileNames)~=length(snr)
    error("signalFileNames snr: length mismatch")
end

%function body
sii=[];
noise=fileToIta(noiseFileName,"noise","Fs");
%wtb=waitbar(0,"");

namesList=strings(size(signalFileNames));
for n=1:length(signalFileNames)
    %waitbar(n/length(signalFileNames),wtb,"calculating the reference Sii");
    namesList(n)=convertCharsToStrings(signalFileNames(n).name);
    signal=fileToIta(signalFileNames(n).folder+"/"+signalFileNames(n).name,"signal","Pa");
    [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,snr(n));
    
    sii(n)=ita_SII(signalCal,noiseCal,bif);
end
%close(wtb)

% mu=mean(sii);
% err=std(sii);

sii=sii';
snr=snr';
siiDist=table(namesList,sii,snr);
return;