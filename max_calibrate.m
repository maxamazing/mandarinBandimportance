function [noiseCal,signalCal]=max_calibrate(noise,refLevel,signal,snr)
    %[noiseCal,signalCal]=calibrate(noise,refLevel,signal,snr)
    %   scale noise and signal such that the noiselevel in dB FS (rel 1) matches
    %   the refLevel and scale the signal such that the snr in dB is fulfilled. This
    %   calibration is crucial for any digital processing with objective
    %   measures.
    %
    %PARAMETERS:
    %   noise       itaAudioObject      distraction signal, first channel
    %                                       is used and units are copied
    %   refLevel    double              level of noise during the measurement   
    %                                       typically 65 dB SPL. The
    %                                       calibrated signal will be
    %                                       scaled to this value
    %                                       irrespective of the units.
    %   signal      itaAudioObject      signal carrying nonzero information
    %   snr         double              signal to noise ratio in dB
    %
    %AUTHOR:
    %   max scharf Do 22. Jul 11:27:34 CEST 2021 maximilian.scharf@uol.de
   
    units=noise.channelUnits{1};
    
    n=noise.ch(1).time;
    noiseLevel=20*log10(rms(n));
    noiseCal=matrixToIta(n.*10^((refLevel-noiseLevel)/20),noise.samplingRate,"noise scaled to match reference level",units);
    %disp(20*log10(rms(noiseCal.time))); %should equal refLevel
    
    signalCal=itaAudio();
    for i=1:length(signal.channelNames)
        signalLevel=20*log10(rms(signal.ch(i).time));
        signalTemp=matrixToIta(signal.ch(i).time.*10^((refLevel+snr-signalLevel)/20),signal.samplingRate,"signal scaled to match SNR",units);
        %disp(20*log10(rms(signalTemp.time))); %should equal snr+refLevel
        signalCal=ita_merge(signalCal,signalTemp);
    end    

end
