function [sign]=matrixToIta(fullDat,sampleRate,name,units)
    %load the given data to the itaAudio-object
    %uneven number of samples is made even to reduce fft-problems
    %if file contains several channels, these are saved as different
    %channels in the ita Audio file, names are numbered according to
    %channel
    %
    %PARAMETERS:
    %fullDat  	matrix, containing the signals
    %sampleRate
    %name       string: name to assign the the generated itaAudio-object
    %units      string: units to assign the the generated itaAudio-object
    %
    %AUTHOR:
    %   max scharf Fr 12. Mär 11:16:35 CET 2021 maximilian.scharf@uol.de
    
    
    %init container
    sign=itaAudio;
    sign.samplingRate=sampleRate;
    
    %iterate through channels
    for channel=1:size(fullDat,2)
        tempSign=itaAudio;
        tempSign.samplingRate=sampleRate;
        clip=false;
        chanDat=fullDat(:,channel);
        if mod(size(chanDat),2)>0
            clip=true;
            %disp("odd datapoint number was made even");
        end

        %save data to itaAudio
        tempSign.time=chanDat(1:end-clip);
        tempSign.channelNames{1}=char(name+" "+channel);
        tempSign=tempSign* itaValue(1,char(units));
        sign=ita_merge(sign,tempSign);
    end
end