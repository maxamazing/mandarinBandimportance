function [sii]=ita_SII(signal,noise,bif)
%[refSii]=ita_SII(refSignal,refNoise,bif,srt,noiseLevel)
% Return the SII which can be used as a reference
% based on normal hearing with provided band importance
% function, which can be chosen with the command 
%       bif=ita_SII_BIF();
% Calculation based on ANSI S1.11-2004 1/3 octave filters.
% Calculation of SII according to ANSIS3.5-1997.
%
% 
% PARAMETER:
%   signal      itaAudio Object     signal; first channel is used    
%   noise       itaAudio Object     noise; first channel is used
%   bif         1x18 vector         band importance function (see ita_SII_BIF())
% 
% OUTPUT
%   sii     double [0,1] describing the SII
%
% 
%AUTHOR: 
% max scharf Mo 19. Jul 16:05:17 CEST 2021 maximilian.scharf@uol.de
%
%REQUIREMENTS:
%   
%   Matlab Audio toolbox
%   ITA-Toolbox(freeware)
%
%PROCESS:
%   The digital noise and signal (in units of dBFS) is converted to units dBSPL
%   After this conversion, the resulting signal and noise
%   correspond to the presented levels in dBSPL during the experiment.
%   These values are processed according to ANSIS3.5-1997


%speech level
[~,~,~,E]=my_oct3bank(signal.ch(1).time,signal.samplingRate,true);

%noise level
[~,~,~,N]=my_oct3bank(noise.ch(1).time,noise.samplingRate,true);

%hearing threshold level
T=zeros(length(E));

%band importance function
I=bif;

%insertion gain (through hearing aid)
G=zeros(length(E));

%output of function
sii=SII(E,N,T,I,G);

end