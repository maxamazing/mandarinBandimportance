%script to use SII
% for prediction of srt in Mandarin 
%SII-filter according to ANSI S1.11-2004
%
%max scharf Nov 23 maximilian.scharf@uol.de
%basic cleanup mar 26

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

%genderspecificBIF
endId=length(setting)+1;
setting(endId).refshift=0; 
setting(endId).title="";
setting(endId).fileName="siiPred_averageSii_mandGendSpecBIF.";
setting(endId).genspec=true;
setting(endId).nu=22;
setting(endId).flag="Mandarin gender-specific";
setting(endId).legendOn=false;
setting(endId).refSii=getRefSIIAverageGenspec(setting(endId).refshift,dataPath,setting(endId).bif );


%averageBIF
endId=length(setting)+1;
setting(endId).refshift=0;
setting(endId).title="";
setting(endId).fileName="siiPred_averageSii_mandAverageBIF.";
setting(endId).bif=bifDat.chen_2016_chinese_average;
setting(endId).genspec=false;
setting(endId).nu=22;
setting(endId).flag="Mandarin average";
setting(endId).legendOn=false;
setting(endId).refSii=getRefSIIAverage(setting(endId).refshift,dataPath,setting(endId).bif );


%constantBIF
endId=length(setting)+1;
setting(endId).refshift=0;
setting(endId).title="";
setting(endId).fileName="siiPred_averageSii_constantBIF.";
setting(endId).bif=bifDat.constant;
setting(endId).genspec=false;
setting(endId).nu=22;
setting(endId).flag="constant";
setting(endId).legendOn=false;
setting(endId).refSii=getRefSIIAverage(setting(endId).refshift,dataPath,setting(endId).bif );


%nnsBIF
endId=length(setting)+1;
setting(endId).refshift=0;
setting(endId).title="";
setting(endId).fileName="siiPred_averageSii_nnsBIF.";
setting(endId).bif=bifDat.nonsensesyllabletestswheremostofEnglishphonemesoccur;
setting(endId).genspec=false;
setting(endId).nu=22;
setting(endId).flag="nns";
setting(endId).legendOn=false;
setting(endId).refSii=getRefSIIAverage(setting(endId).refshift,dataPath,setting(endId).bif );

%standard table of the sii
endId=length(setting)+1;
setting(endId).refshift=0;
setting(endId).title="";
setting(endId).fileName="siiPred_averageSii_stadardTable3.";
setting(endId).bif=bifDat.standardtable3;
setting(endId).genspec=false;
setting(endId).nu=21;
setting(endId).flag="standard";
setting(endId).legendOn=true;
setting(endId).refSii=getRefSIIAverage(setting(endId).refshift,dataPath,setting(endId).bif );


%%

for id=1:length(setting)
%start prediction

%--------female--------------
%import measurement
load(dataPath+"measuredDataFemale.mat","datLombardF","datPlainF")
if setting(id).genspec
    setting(id).bif=bifDat.chen_2016_chinese_female;
end

%plain
filterPlain=dir(dataPath+"*_F*Plain*");
wtb=waitbar(0,"");
for n=1:length(filterPlain)
    waitbar(n/length(filterPlain),wtb,"calculating SRT in Plain for given test subjects (Female)");

    signal=fileToIta(dataPath+filterPlain(n).name,"signal","Pa");
    for i=1:length(setting(id).refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datPlainF{2+i,n}=ita_SRT(signalCal,noiseCal,setting(id).refSii(i),setting(id).bif);
    end
end
close(wtb)

%lombard
filterLombard=dir(dataPath+"*_F*Lombard*");
wtb=waitbar(0,"");
for n=1:length(filterLombard)
    waitbar(n/length(filterLombard),wtb,"calculating SRT in Lombard for given test subjects (Female)");
    
    signal=fileToIta(dataPath+filterLombard(n).name,"signal","Pa");
    for i=1:length(setting(id).refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datLombardF{2+i,n}=ita_SRT(signalCal,noiseCal,setting(id).refSii(i),setting(id).bif);
    end
end
close(wtb)


%--------male--------------
%import measurement
load(dataPath+"measuredDataMale.mat","datLombardM","datPlainM")
if setting(id).genspec
    setting(id).bif=bifDat.chen_2016_chinese_male;
end

%plain
filterPlain=dir(dataPath+"*_M*Plain*");
wtb=waitbar(0,"");
for n=1:length(filterPlain)
    waitbar(n/length(filterPlain),wtb,"calculating SRT in Plain for given test subjects (Male)");

    signal=fileToIta(dataPath+filterPlain(n).name,"signal","Pa");
    for i=1:length(setting(id).refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datPlainM{2+i,n}=ita_SRT(signalCal,noiseCal,setting(id).refSii(i),setting(id).bif);
    end
end
close(wtb)

%lombard
filterLombard=dir(dataPath+"*_M*Lombard*");
wtb=waitbar(0,"");
for n=1:length(filterLombard)
    waitbar(n/length(filterLombard),wtb,"calculating SRT in Lombard for given test subjects (Male)");
    
    signal=fileToIta(dataPath+filterLombard(n).name,"signal","Pa");
    for i=1:length(setting(id).refSii)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,0);
        datLombardM{2+i,n}=ita_SRT(signalCal,noiseCal,setting(id).refSii(i),setting(id).bif);
    end
end
close(wtb)

%disp results
clear('x')
clear('y')
clear('xe')
clear('yePos')
clear('yeNeg')

%measurement
x{1}=datPlainF{1,:};
x{2}=datLombardF{1,:};
x{3}=datPlainM{1,:};
x{4}=datLombardM{1,:};


%error on measurement: some have 12, others have 13 listeners. The factor
%1/sqrt(N) is allready included in the database
xe{1}=datPlainF{2,:};
xe{2}=datLombardF{2,:};
xe{3}=datPlainM{2,:};
xe{4}=datLombardM{2,:};

%prediction
y{1}=datPlainF{3,:}-setting(id).refshift;
y{2}=datLombardF{3,:}-setting(id).refshift;
y{3}=datPlainM{3,:}-setting(id).refshift;
y{4}=datLombardM{3,:}-setting(id).refshift;

%error on prediction
yePos{1}=zeros(size(y{1}));
yePos{2}=zeros(size(y{2}));
yePos{3}=zeros(size(y{3}));
yePos{4}=zeros(size(y{4}));

yeNeg{1}=zeros(size(y{1}));
yeNeg{2}=zeros(size(y{2}));
yeNeg{3}=zeros(size(y{3}));
yeNeg{4}=zeros(size(y{4}));


color=string(rgb2hex(colorblind(1:4,:)));
label={'Plain,       Female','Lombard, Female','Plain,       Male','Lombard, Male'};

max_plot(x,'empirical SRT_{50} /dB',xe,xe,y,'predicted SRT_{50} /dB',yePos,yeNeg,setting(id).title,color,label,true,-20:-10,0.2,0,setting(id).flag);

set(gcf,'position',[0,0,500,400]);
    exportgraphics(gcf,"figs_paperOnBIF/"+setting(id).fileName+"eps") 
    exportgraphics(gcf,"figs_paperOnBIF/"+setting(id).fileName+"png")
    exportgraphics(gcf,"figs_paperOnBIF/"+setting(id).fileName+"pdf")  


    b = gca;
    legend(b,'off');

    exportgraphics(gcf,"figs_paperOnBIF/noLeg_"+setting(id).fileName+"eps") 
    exportgraphics(gcf,"figs_paperOnBIF/noLeg_"+setting(id).fileName+"png")
    exportgraphics(gcf,"figs_paperOnBIF/noLeg_"+setting(id).fileName+"pdf") 
    
%save the data to work with 

%save(setting(id).flag+"meanSII"+".mat","x","xe","y")

end

