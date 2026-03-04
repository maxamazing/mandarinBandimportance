function [outsig,ff,P,E] = my_oct3bank(insig,fs,exact) 
%[outsig,ff,P] = my_oct3bank(insig,fs) 
%   third octave band fiterbank for the application in the SII (ANSI
%   S3.5-1997)
%   use of stable filters meeting specifications of ANSI S1.11-2004
%   for class 0 1/3 octave filters
%PARMETERS:
%   insig   vector containing the signal in units of uPa in the time domain
%   fs      Sampling frequnency, samplingrate in Hz
%   exact   Boolean, use exact 1/3 octave center frequencies in a base ten system or "nominal"
%               as used in ANSIS3.5-1997 (+-2% Hz difference)
%
%DESCRIPTION:
%   calculate the input parameters for the SII along with additional data
%   for error checking. This script is intended to replace the one by 
%   Christophe Couvreur, Aug. 25, 1997 using modern specifications and
%   syntax.
%
%OUTPUT:
%   outsig  filtered time signals in units of uPa
%   ff      1x18 vector     center frequency according to ANSI S1.6-1984 in Hz
%   P       1x18 vector     RMS level in dB SPL
%   E       1x18 vector     Speech spectrum level according to ANSI S3.5-1997
%
%
%AUTHOR: 
% maxScharf Feb 26 2021 maximilian.scharf@uol.de
%
%REQUIREMENTS:
%   
% Matlab Audio toolbox

%INIT

% Design filters and filter signals in one third oct. bands
filt = octaveFilter(1000,'Bandwidth','1/3 octave','SampleRate',fs);

%checks for agreement with ANSI S1.11-2004: indicated by green dashed outline
%visualize(filt,'class 0') 

%exact center frequencies of 1/3 octave filterbank
fc=getANSICenterFrequencies(filt);

% filter parameters according to ANSI S3.5-1997 and DOI:10.1016/j.specom.2016.07.009
f = [     ...              % definition of filterbank. 
%    center[Hz]  upper[Hz]   bandwidth adj. [dB]
    0,      160,    180,    15.65; ...
    180,    200,    224,    16.65; ...
    224,    250,    280,    17.65; ...
    280,    315,    355,    18.56; ...
    355,    400,    450,    19.65; ...
    450,    500,    560,    20.65; ...
    560,    630,    710,    21.65; ...
    710,    800,    900,    22.65; ...
    900,    1000,   1120,   23.65;...
    1120,   1250,   1400,   24.65;...
    1400,   1600,   1800,   25.65;...
    1800,   2000,   2240,   26.65;...
    2240,   2500,   2800,   27.65;...
    2800,   3150,   3550,   28.65;...
    3550,   4000,   4500,   29.65;...
    4500,   5000,   5600,   30.65;...
    5600,   6300,   7100,   31.65;...
    7100,   8000,   9000,   32.65]  ;  

m = length(insig); 
outsig = zeros(m,length(f));%filtered signals
ff= zeros(1,length(f));     %center frequency
P = zeros(1,length(f));     %mean power

%BODY
for i = 1:length(f)
    if exact==true
        [~,id]=min(abs(fc-f(i,2)));
        filt.CenterFrequency=fc(id);
    else
        filt.CenterFrequency=f(i,2);
    end  
   outsig(:,i)=filt(insig); 
   ff(i)=filt.CenterFrequency; 
   P(i) = rms(outsig(:,i));
end

%consistency check: mean power conserved?
%disp(dot(insig,insig)/m);
%disp(sum(P^2));

% Convert to decibels. 
Pref = 1; 				% Reference level for dB scale.  
idx = (P>0);
P(idx) = 20*log10(P(idx)/Pref);
P(~idx) = NaN*ones(sum(~idx),1);

% speech spectrum level
df=transpose(f(:,3)-f(:,1));%Hz
E=P-10*log10(df);

end
