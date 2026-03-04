function refSii=getRefSIIMeasurement(offSet,dataPath,bif )

    if nargin < 3
        bifDat=ita_SII_BIF();
        bif=bifDat.chen_2016_chinese_female; %reference was a woman
    end
    
    %SII reference based on a sacrificial measurement
    refSrt=-14.8+offSet;%dB
    refSrtErr=2.2098/sqrt(13);   %dB
    refNoiseLevel=65;   %dB SPL
   
    signal=fileToIta(dataPath+"original_Mandarin.wav","signal","Fs");
    noise=fileToIta(dataPath+"icra1.wav","noise","Fs");
    refSii=[];
    err=[0,+refSrtErr,-refSrtErr];
    for i=1:length(err)
        [noiseCal,signalCal]=max_calibrate(noise,refNoiseLevel,signal,refSrt+err(i));
        refSii(i)=ita_SII(signalCal,noiseCal,bif);
    end
end