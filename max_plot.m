function []=max_plot(x,xl,xePos,xeNeg,y,yl,yePos,yeNeg,titl,color,names,showErr,range,labelDist,nu,tabledesc)
    %[]=max_plot(x,xl,xePos,xeNeg,y,yl,yePos,yeNeg,titl,color,names,showErr)
    %plot according to common style
    %max scharf Nov 23 maximilian.scharf@uol.de
    
    %PARAMETERS
    %   x           data as cell array e.g.: x{1}=[1,2,3]
    %   xl          x label
    %   xePos       errorbars as cell array e.g.: xePos{1}=[1,2,3] positive
    %                   direction
    %   xeNeg       errorbars as cell array e.g.: xeNeg{1}=[1,2,3] negative
    %                   direction
    %   y           data as cell array e.g.: y{1}=[1,2,3]
    %   yl          y label
    %   yePos       errorbars as cell array e.g.: yePos{1}=[1,2,3] positive
    %                   direction
    %   yeNeg       errorbars as cell array e.g.: yeNeg{1}=[1,2,3] negative
    %                   direction
    %   titl        title of figure
    %   color       colorcoding eg. color=["red","black"];
    %   names       labels eg. names={'Plain','Lombard'}'; names="pass" for
    %                   missing legend
    %   showErr     bool    flag for errorbars
    %   range       range to plot (x and y have the same range)
    %   labelDist   Distance for the numbering Label
    %optional:
    %   nu          number of degrees of freeedom if calculatoin of
    %               chi-stats needed
    %   tableDesc   additional entry in the generated results-Table
    decpl=2; %number of decimal places to plot write
    decplTable=2; %number of decimal places to write to table
    fmt="%3.2f";%formatter to make all numbers the same length of characters
    numbering=true;%write numbers next to the symbols
    numberingOffset=labelDist;%0.2 for abs;displacement of numbering in both x and y direction
    symbols=['o','o','^','^'];%filled, unfilled
    %symbols=['o','^'];%filled, unfilled

    %plot
    clf('reset')
    hold on;
    for i=1:length(x)
        if showErr==true
            if mod(i,2)
                if ~sum(sum(yeNeg{i}(:)+yePos{i}(:)))
                    errorbar(x{i}(:),y{i}(:),xeNeg{i}(:),xePos{i}(:),'horizontal','o','color',color(i),'MarkerFaceColor', color(i),'Marker',symbols(i));
                else
                    errorbar(x{i}(:),y{i}(:),yeNeg{i}(:),yePos{i}(:),xeNeg{i}(:),xePos{i}(:),'o','color',color(i),'MarkerFaceColor', color(i),'Marker',symbols(i));
                end
            else
                %make white face color
                if ~sum(sum(yeNeg{i}(:)+yePos{i}(:)))
                    errorbar(x{i}(:),y{i}(:),xeNeg{i}(:),xePos{i}(:),'horizontal','o','color',color(i),'MarkerFaceColor', color(i),'Marker',symbols(i),'MarkerFaceColor', 'w');
                else
                    errorbar(x{i}(:),y{i}(:),yeNeg{i}(:),yePos{i}(:),xeNeg{i}(:),xePos{i}(:),'o','color',color(i),'MarkerFaceColor', color(i),'Marker',symbols(i),'MarkerFaceColor', 'w');
                end
            end
        else  
            if mod(i,2)  
                scatter(x{i}(:),y{i}(:),'MarkerFaceColor',color(i),'MarkerEdgeColor',color(i),'Marker',symbols(i));
            else
                scatter(x{i}(:),y{i}(:),'MarkerFaceColor',color(i),'MarkerEdgeColor',color(i),'Marker',symbols(i),'MarkerFaceColor', 'w');
            end
        end
    end

    %statistics data
    xx=cat(2,x{:});
    yy=cat(2,y{:});
    varx=(0.5*(cat(2,xePos{:})+cat(2,xeNeg{:}))).^2;
    vary=(0.5*(cat(2,yePos{:})+cat(2,yeNeg{:}))).^2;
    %errPos=cat(2,xePos{:});
    %errNeg=cat(2,xeNeg{:});
    %ymax=y+cat(2,yePos{:});
    %ymin=y-cat(2,yeNeg{:});
    ofset=mean(yy-xx);
    plotRange=range;
    %plotRange=floor(min(cat(2,x,y,ymax,ymin))):1:1+floor(max(cat(2,x,y,ymax,ymin)));
    plot(plotRange,plotRange,'color',[0 0 0]+0.7);
    %plotRange=floor(min(cat(2,x,y,ymax,ymin)))-ofset:1:1+floor(max(cat(2,x,y,ymax,ymin)))-ofset;
    plot(plotRange,plotRange+ofset,'--','color',[0 0 0]+0.7);
    
    
    r=corrcoef(xx(:),yy(:));
    rmsVal=rms(xx(:)-yy(:));
    
    chi2=0;
    if (nu~=0)
        %chi2=sum(((x(:)-y(:))./((0.5*(errPos(:)+errNeg(:)))).^2); %use the std of the measurement->x
        chi2=sum((xx(:)-yy(:)).^2./(varx+vary)'); %use the std of the measurement and simulation (if available)->x
        str=sprintf(['R=',num2str(round(r(1,2),decpl),fmt),'\nRMS= ',num2str(round(rmsVal,decpl),fmt),' dB \nbias= ',num2str(round(ofset,decpl),fmt),' dB\n \\chi^2/\\nu,\\nu= ',num2str(chi2/(nu),'%.1f'),' , ',num2str(nu)]);
    else
        str=sprintf(['R=',num2str(round(r(1,2),decpl),fmt),'\nRMS= ',num2str(round(rmsVal,decpl),fmt),' dB \nbias= ',num2str(round(ofset,decpl),fmt),' dB']);
    end
    
    
    grid('on')
    axis equal
    xlim([min(range) max(range)]);
    ylim([min(range) max(range)]);
    set(gca,'xtick',range);
    set(gca,'ytick',range);
    
    t=annotation('textbox');
    t.Parent = gca;  % associate annotation with current axes
    t.String=str;
    t.Position=[min(range) max(range)-1 1 1];
    t.LineStyle='none';
    hold off;

    xlabel(xl)
    ylabel(yl)
    title(titl)
    if names~="pass"
        legend(names,'Location','southeast')
    end
    
    
    %write stats to textfile
    
    if nargin>14
        additionalColumnName="\t"+tabledesc;
    else
        additionalColumnName="";
    end
    fid = fopen('stats_new.txt','a+');
        if abs(ofset)>0.01
            decplTableOffset=decplTable;
            fmtOffset=fmt;
        else
            decplTableOffset=5;
            fmtOffset="%0.4f";
        end
        
    if nargin>13
        fprintf(fid, '\n$\\mathrm{R}$ & \tRMS/dB & \tbias/dB & \t$\\chi^2/\\nu$ & \t$\\nu$ & \tcaption'+additionalColumnName);
        str=sprintf(['\n',num2str(round(r(1,2),decplTable),fmt),' & \t',num2str(round(rmsVal,decplTable),fmt),' & \t',num2str(round(ofset,decplTableOffset),fmtOffset),' & \t',num2str(chi2/nu,decplTable),' & \t',num2str(nu),' & \t']);
        
    else
        fprintf(fid, '\n$\\mathrm{R}$ & \tRMS/dB & \tbias/dB & \tcaption'+additionalColumnName);
        str=sprintf([num2str(round(r(1,2),decplTable),fmt),'& \t',num2str(round(rmsVal,decplTable),fmt),'& \t',num2str(round(ofset,decplTableOffset),fmtOffset),'\t']);
    end
    if nargin>14
        fprintf(fid," & "+str+titl+additionalColumnName+"\\\\");
    else
        fprintf(fid,str+titl);
    end    
    
    for i=1:length(x)
        %add a number next to the symbol to indicate the same speaker, make
        %it such that there are different numbers for the seconf half of
        %data. this is the last thing to write, so that the numbers are on
        %top
        if numbering
            for n=1:length(x{i})
                text(x{i}(n)+numberingOffset,y{i}(n)-numberingOffset,string(n+(length(x{i})-1)*(i>length(x)/2)))
            end
        end
    end
    

    fprintf(fid,"\n");
    fclose(fid);

end