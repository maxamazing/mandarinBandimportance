function refSii=getRefSIIAverageGenspec(offSet,dataPath,pickRandom)
%SII average over all measurements with genderspecific BIF
if nargin <3
    pickRandom=false;
end

        

    %-------------------------------female-------------------
    bifDat=ita_SII_BIF();
    bif=bifDat.chen_2016_chinese_female;
    refNoiseLevel=65;   %dB SPL

    %load data
    load(dataPath+"measuredDataFemale.mat","datLombardF","datPlainF")
    snrF=[datPlainF{1,:},datLombardF{1,:}]+offSet;
    
    load(dataPath+"measuredDataMale.mat","datLombardM","datPlainM")
    snrM=[datPlainM{1,:},datLombardM{1,:}]+offSet;
    
    %random ratio of male vs female
    numCond=length(snrM)+length(snrF);
    if pickRandom
        randRatio=randi(numCond);
    end
    
    %select the files
    filter=dir(dataPath+"f*F*Plain*");
    filterL=dir(dataPath+"f*F*Lombard*");
    for n=1:length(filterL)
        filter(end+1)=filterL(n);
    end
    
    %used for boostrapping
    if pickRandom
        pickIdF=randi(length(filter),randRatio);
    else
        pickIdF=1:length(filter);
    end
    
    
    %calculate reference SII
    siiDistFemale=getSii(filter(pickIdF),dataPath+"icra1.wav",refNoiseLevel,snrF(pickIdF),bif);

    %-----------------------male----------------------------
    bif=bifDat.chen_2016_chinese_male;

    %select the files
    filter=dir(dataPath+"f*M*Plain*");
    filterL=dir(dataPath+"f*M*Lombard*");
    for n=1:length(filterL)
        filter(end+1)=filterL(n);
    end
    
    %used for boostrapping
    if pickRandom
        pickIdM=randi(length(filter),numCond-randRatio);
    else
        pickIdM=1:length(filter);
    end
    
    
    %calculate reference SII
    siiDistMale=getSii(filter(pickIdM),dataPath+"icra1.wav",refNoiseLevel,snrM(pickIdM),bif);


    sii=[siiDistFemale.sii',siiDistMale.sii'];
    
    siiMean=mean(sii);
    siiStd=std(sii)/length(sii);%uncertainty of the mean
    refSii=[siiMean,siiMean+siiStd,siiMean-siiStd];
%     refSii=[median(sii),prctile(sii,75),prctile(sii,25)];
end