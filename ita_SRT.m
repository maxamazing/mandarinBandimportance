function [srt]=ita_SRT(signal,noise,refSii,bif)
%[refSii]=ita_SII(signal,noise,refSii,bif)
% Return the SII based on normal hearing with givel band importance
% function, which can be chosen with the command 
%       bif=ita_SII_BIF();
%
% 
% PARAMETER:
%   signal   itaAudio Object    first channel is used    
%   noise    itaAudio Object    first channel is used
%   refSii   double             SII of reference condition
%   bif      1x18 vector        band importance function (see
%                                   ita_SII_BIF())
% 
% OUTPUT
%   srt     signal gain (db rel 20uPa) required to match the given reference SII
%
% 
%AUTHOR: 
% maxScharf Feb 26 2021 maximilian.scharf@uol.de
%
%REQUIREMENTS:
%   
%   Audio toolbox
%   ITA-Toolbox(freeware)

%speech level
[~,~,~,E]=my_oct3bank(signal.ch(1).time,signal.samplingRate,true);

%noise level
[~,~,~,N]=my_oct3bank(noise.ch(1).time,noise.samplingRate,true);

%hearing threshold level
T=zeros(length(E));

%band importance function
I=bif;

%insertion gain
G=zeros(length(E));


%search for matching gain
L    = -64;
fSII =   0;
vSteps = 2.^[4:-2:-12];  %mxs: changed for higher resolution
iSign  = 1;

for step = 1:length(vSteps)
    while fSII*iSign < refSii*iSign
        fSII = SII(E+L,N,T,I,G);
        L = L + iSign * vSteps(step);
    end
    iSign = iSign * -1;
end

srt = L;

end