clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

roots = inputdlg('Set Root Name:','Input',4,{erase(file,'.mat')});
if isempty(roots)
    dosave = false;
else
    dosave = true;
end

if dosave
    rootfile = [roots{1} '_Results'];
    mkdir(rootfile);
    root = fullfile(rootfile,roots{1});
end


[TypeID,ntypes,types] = GetTypeIDs(CellProps,'Type');

%% Define various colormaps and other display parameters
OrientColMap = flipud(cbrewer('div','RdYlBu',64));
PolarMap = cbrewer('seq','YlOrRd',64);
haircolor = hex2rgb('#e66101');
supportcolor = hex2rgb('#5e3c99');

TypeMap = MyBrewerMap('qual','Set2',ntypes);

%% Histograms
figure
[ha] = HistArray(CellProps,'NormOrientationR','Type',...
    'histtype','polar','splitcolors',TypeMap);
sgtitle('Normalized Orientation')
if dosave
print(gcf,'-dpdf',[root '_OrientationHistogram.pdf'])
end

figure
[hc] = HistArray(CellProps,'NormOrientationR','Type',...
    'histtype','polar','fixmax',true,'splitcolors',TypeMap);
sgtitle('Normalized Orientation')
if dosave
print(gcf,'-dpdf',[root '_OrientationHistogram_FixMax.pdf'])
end

% Polarity Histograms
figure
[hb] = HistArray(CellProps,'Polarity','Type','splitcolors',TypeMap,...
    'fixmax',true,'xlabel','Polarity','nullpolarity',true);
sgtitle('Polarity')
if dosave
print(gcf,'-dpdf',[root '_PolarityHistogram.pdf'])
end

% Violin plot and CDF Plot
for k = 1:ntypes
    polCell{k} = CellProps.Polarity(TypeID{k});
    polname{k} = types(k);
    
    [SigLvl(k),D(k)] = NullPolKSTest(CellProps.Polarity(TypeID{k}));
end

figure
violin(polCell,'xlabel',polname,'facecolor',[TypeMap],'facealpha',1,'medc','w');
ylabel('Probability')
xlabel('Polarity');
if dosave
    print(gcf,'-dpdf',[root '_PolarityViolin.pdf'])
end

% Polarity Box and Whisker
% nsims = 2000;
% nullPol = sqrt(rand(1,nsims))';
figure
[hbox] = boxplot(CellProps.Polarity,CellProps.Type);
title('Subcellular Polarity')
% add significance labels
for k=1:ntypes
    text(k,0,SigLvl(k));
end
ylabel('Polarity');

if dosave
print(gcf,'-dpdf',[root '_PolarityBoxPlot.pdf'])
end



% ECDF Plot
figure
p=linspace(0,1,100);
lwd = 2;
plot(p,p.^2,':k','LineWidth',lwd);
hold on
for k = 1:ntypes
    [polECDF,polECDFx] = ecdf(CellProps.Polarity(TypeID{k}));
    plot(polECDFx,polECDF,'Color',TypeMap(k,:),'LineWidth',2);
end
legend(['Null';types],'Location','NorthWest');

if dosave
    print(gcf,'-dpdf',[root '_PolarityCDF.pdf'])
end

close all
%% Model Cell Array
figure
[hc] = ModelCellArray(CellProps,'Type','fixmax',true);
if dosave
export_fig(gcf,[root '_ModelCell_FixedMax'],'-pdf')
end

figure
[hc] = ModelCellArray(CellProps,'Type');
if dosave
export_fig(gcf,[root '_ModelCell'],'-pdf')
end

close all
%% Individual Files
for k = 1:length(poolIms)
    
    ImDat = poolIms{k};
    TempProps = poolProps{k};
    curType = TempProps.Type{1};
    curRep = num2str(TempProps.Replicate(1));
    
    figure
    imshow(ImDat.RAW)
    hold on
    visboundaries(bwboundaries(ImDat.CellMaskR),'Color','w','Linewidth',0.5);
    title(curType)
    daspect([1 1 1])
    if dosave
    export_fig(gcf,[root '_' curType '_' curRep '_CellOverlay'],'-pdf')
    end
    
    figure
    VectorOverlayMap(ImDat,TempProps,'Type','splitcolors',[1 1 1]);
    title(curType)
    daspect([1 1 1])
    if dosave
    export_fig(gcf,[root '_' curType '_' curRep '_VectorOverlay'],'-pdf')
    end
    
    %% Orientation Maps
    ImDat.(['R' curType 'CellMask']) = ImDat.CellMaskR;
    DataMapArray(ImDat,TempProps,'NormOrientation','Type','cmap',OrientColMap,'varlims',[0 360])
    title(curType)
    if dosave
    export_fig(gcf,[root '_' curType '_' curRep '_OrientationMap'],'-pdf')
    end
    
    ImDat.(['R' curType 'CellMask']) = ImDat.CellMaskR;
    DataMapArray(ImDat,TempProps,'NormOrientation180','Type','cmap',OrientColMap,'varlims',[0 180])
    title(curType)
    if dosave
    export_fig(gcf,[root '_' curType '_' curRep '_OrientationMap180'],'-pdf')
    end
    
    %% Polarity Map
    ImDat.(['R' curType 'CellMask']) = ImDat.CellMaskR;
    DataMapArray(ImDat,TempProps,'Polarity','Type','cmap',PolarMap,'varlims',[0 1])
    title(curType)
    if dosave
    export_fig(gcf,[root '_' curType '_' curRep '_PolarityMap'],'-pdf')
    end
    
    close all
end

%% Angle K
% If it isn't already done, perform angle K now. 
if ~exist('AngK','var')  
    scales = (50:50:1000)';
    alpha = 0.01;

    for k = 1:length(types)
        curType = types(k);
        kID = CellProps.Type==curType;
        replicates = unique(CellProps.Replicate(kID));

        for n = 1:length(replicates)
            nkID = kID&CellProps.Replicate==replicates(n);

            hvec.origin = CellProps.Center(nkID,:);
            hvec.angle = CellProps.OrientationR(nkID);
            hvec.magnitude = ones(sum(nkID),1);

            [K(n,:),Ori{n,k}] = AngleK(scales,hvec,hvec); 
            [~,KsimMax(n,:),KsimMin(n,:),] = AngleK_Env(scales,hvec,alpha);
            a=1;
        end
        KPool{k} = mean(K,1);
        KsimMaxPool{k} = max(KsimMax,[],1);
        KsimMinPool{k} = min(KsimMin,[],1);

        % Because AngleK is the mean of a set of alignments. We can find pooled
        % AngleK values by averaging them again. (if it wasn't a simple mean
        % you'd have to pool the alignments first, then compute AngleK based 
        % on the pooled set). Similarly, we can find the max of KsimMax and
        % KsimMin.
        a=1;
    end
    AngK.KPool = KPool;
    AngK.KsimMaxPool = KsimMaxPool;
    AngK.KsimMinPool = KsimMinPool;
    AngK.Ori = Ori;
    AngK.scales = scales;
    AngK.types = types;
    AngK.alpha = alpha;

    save(fullfile(path,file),'AngK','-append');
end
close all
%% Angle K Plot
[sprows,spcols] = squaresubplotdims(length(AngK.types)); % Approximately square array.
ha = tight_subplot(sprows,spcols,0.1,0.1,0.1);
lwd = 2;

maxy = ceil(11*max(abs([cell2mat(AngK.KPool)...
    cell2mat(AngK.KsimMaxPool)...
    cell2mat(AngK.KsimMinPool)])))/10;

for n=1:length(AngK.types)
    axes(ha(n))
    lincolor = TypeMap(n,:);
    plot(AngK.scales,AngK.KPool{n},'Color',lincolor,'LineWidth',lwd)
    hold on
    plot(AngK.scales,AngK.KsimMaxPool{n},'Color',lincolor,...
        'LineStyle','--','LineWidth',lwd/2)
    plot(AngK.scales,AngK.KsimMinPool{n},'Color',lincolor,...
        'LineStyle','--','LineWidth',lwd/2)
    title(AngK.types(n))
    ylim([-1 1].*maxy)
    xlim(AngK.scales([1 end])');
end

if dosave
export_fig(gcf,[root '_AngleK'],'-pdf')
end

close all

%% AngleK conf int plot.

for k=1:length(types)
cOri = cell2mat(AngK.Ori(:,k));
obsK = mean(cOri,'omitnan');
lincolor = TypeMap(k,:);
nObs = length(cOri)-sum(isnan(cOri)); % n observations

% Conf Ints
alpha2 = 0.01/2;
SEM = std(cOri,'omitnan')./sqrt(nObs); % standard Error
tmin = tinv(alpha2,nObs-1); % t-score
tmax = tinv(1-alpha2,nObs-1); % t-score
CMin = obsK+tmin.*SEM;
CMax = obsK+tmax.*SEM;

hold on
patch([scales' fliplr(scales')],[CMin fliplr(CMax)],lincolor,'EdgeColor','none','FaceAlpha',0.7)
end
legend(types)
for k=1:length(types)
    cOri = cell2mat(AngK.Ori(:,k));
    obsK = mean(cOri,'omitnan');
    plot(scales,obsK,'-k','LineWidth',1);
end
hold off
xlim([scales(1) scales(end)])
xlabel('Scale, r (pixels)')
ylabel('Population Alignment')

axis square
if dosave
% export_fig(gcf,[root '_AngleK_Overlay'],'-pdf')
print(gcf,'-dpdf',[root '_AngleK_Overlay.pdf'])
end

close all

%% Orientation Maps

scaleID = [1];

for m = 1:length(scaleID)
    cnt = 0;
    for k = 1:length(types)
            curType = types(k);
            kID = CellProps.Type==curType;
            replicates = unique(CellProps.Replicate(kID));
            for n = 1:length(replicates)
                cnt= cnt+1;
                ImDat = poolIms{cnt};

                Ori = AngK.Ori{n,k};
                DataMap(ImDat.CellMaskR,Ori(:,scaleID(m)));
                cax=colorbar;
                colormap(OrientColMap)
                caxis([-1 1])
                ylabel(cax,sprintf('Alignment at r=%d',AngK.scales(scaleID(m))))
                title(strcat(curType,'-',num2str(n)))
                
                % Turn off axes
                ax = gca;
                ax.XTick = [];
                ax.YTick = [];
                
                savename = strjoin({root,char(curType),num2str(n),'Alignment',num2str(AngK.scales(scaleID(m)))},'_');
                if dosave
                export_fig(gcf,savename,'-pdf')
                end
            end
    end
end
close all  