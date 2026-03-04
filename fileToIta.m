%%installing this library with path(path,"C:<path to this file/folder containing this file>");
%%the file has to have the same name as the function
%



function [sign]=fileToIta(fileName,name,units)    
    %load the given data to the itaAudio-object and remove DC-part
    %uneven number of samples is made even to reduce fft-problems
    %if file contains several channels, these are saved as different
    %channels in the ita Audio file, names are numbered according to
    %channel
%    
    %PARAMETERS:
    %fileName   string: path of soundfile
    %name       string: name to assign the the generated itaAudio-object
    %units      string: units to assign the the generated itaAudio-object
%
%AUTHOR max scharf Do 22. Jul 12:25:00 CEST 2021 maximilian.scharf@uol.de
    
    %load data from file
    [fullDat,sampleRate]=audioread(fileName);
    
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
        tempSign.time=chanDat(1:end-clip)-mean(chanDat);
        tempSign.channelNames{1}=char(name+" "+channel);
        tempSign=tempSign* itaValue(1,char(units));
        sign=ita_merge(sign,tempSign);
    end
end
