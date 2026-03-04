function refSii=getRefSIIAverage(offSet,dataPath,bif )

if nargin <3
    %SII average over all measurements with average BIF
    bifDat=ita_SII_BIF();
    bif=bifDat.chen_2016_chinese_average;
end
    refNoiseLevel=65;   %dB SPL
    filter=dir(dataPath+"f*Plain*");
    filterL=dir(dataPath+"f*Lombard*");
    for n=1:length(filterL)
        filter(end+1)=filterL(n);
    end
    load(dataPath+"measuredData.mat","datLombard","datPlain")
    siiList=getSii(filter,dataPath+"icra1.wav",refNoiseLevel,[datPlain{1,:},datLombard{1,:}]+offSet,bif);
    mu=mean(siiList.sii);
    err=std(siiList.sii)/length(siiList.sii);%uncertainty of the mean
    refSii= [mu,mu+err,mu-err];
end