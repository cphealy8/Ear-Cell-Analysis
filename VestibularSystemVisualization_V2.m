clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

HID = CellProps.Type=='Hair';
SID = CellProps.Type=='Support';

[TypeID,ntypes,types] = GetTypeIDs(CellProps,'Type');


% Add Orientations in Radians
CellProps.OrientationR = wrapTo360(CellProps.Orientation)*pi/180;
CellProps.NormOrientationR = wrapTo360(CellProps.NormOrientation)*pi/180;
CellProps.RefAngleR = wrapTo360(CellProps.RefAngle)*pi/180;

%% Define various colormaps and other display parameters
OrientColMap = flipud(cbrewer('div','RdYlBu',64));
PolarMap = cbrewer('seq','YlOrRd',64);
haircolor = hex2rgb('#e66101');
supportcolor = hex2rgb('#5e3c99');

TypeMap = MyBrewerMap('div','Spectral',ntypes);
%% Preview Segmentation and orientation analysis. 
figure
CellSelectionOverlay(ImDat,TypeMap);

figure
VectorOverlayMap(ImDat,CellProps,'Type','splitcolors',TypeMap)

%% Preview Reference Angles
figure
imshow(ImDat.RAW)
hold on
quiver(CellProps.Center(:,1),CellProps.Center(:,2),cosd(CellProps.RefAngle),-sind(CellProps.RefAngle),'Color','w','Linewidth',1.5)
hold off
%% Montage Preview
% This takes awhile so save it the first time and never do it again.
% Usually this is taken care of in the Vestibular System Analysis.

% figure
% if ~any(strcmp('AnnotIm',CellProps.Properties.VariableNames))
%     CellProps = AnnotIndIms(CellProps);
%     save(fullfile(path,file),'CellProps','-append');
% end
% 
% for k=1:ntypes
%     figure
%     montage(CellProps.AnnotIm(TypeID{k}))
%     title(types{k})
% end

%% Histograms
% Normalized Orientation Histograms
figure
[hc] = HistArray(CellProps,'OrientationR','Type',...
    'histtype','polar','splitcolors',TypeMap);
title('Raw Orientation');

figure
[ha] = HistArray(CellProps,'NormOrientationR','Type',...
    'histtype','polar','splitcolors',TypeMap);
title('Normalized Orientation')

% Polarity Histograms
figure
[hb] = HistArray(CellProps,'Polarity','Type','splitcolors',TypeMap,...
    'fixmax',true,'xlabel','Polarity');
title('Polarity')
%% Model Cell Visualization
figure
[hc] = ModelCellArray(CellProps,'Type');
% [ha] = ModelCellArray(CellProps,'Type','fixmax',true);

%% Orientation Map and Polarity Map
% Raw Orientation Map
% DataMapArray(ImDat,CellProps,'Orientation','Type','cmap',OrientColMap,'varlims',[-180 180]);
% Orientation Map
CellProps.NormOrientation180 = flipTo180(CellProps.NormOrientation);
DataMapArray(ImDat,CellProps,'NormOrientation180','Type','cmap',OrientColMap,'varlims',[0 180])

% Polarity Map
DataMapArray(ImDat,CellProps,'Polarity','Type','cmap',PolarMap,'varlims',[0 1])

%% Angle K
if true
    mindim = min(size(ImDat.HairCellMask));
%     scales = linspace(0,mindim/2,21)';
%     scales(1) = [];
    
    scales = (50:50:500)';
    
    if ~exist('AngK','var')
        [AngK.Obs,AngK.Ori,AngK.simMax,AngK.simMin,AngK.name] = AngleKTypeComp(scales,CellProps,'Type');
        AngK.scales = scales;
        save(fullfile(path,file),'AngK','-append');
    end

    figure
    angkmap = MyBrewerMap('qual','Set1',ntypes.^2);
    hd = tight_subplot(ntypes,ntypes,0.1,0.1,0.1);
    for k=1:(ntypes^2)
        axes(hd(k));
        plot(AngK.scales,AngK.Obs{k},'Color',angkmap(k,:));
        hold on 
        plot(AngK.scales,AngK.simMax{k},'Color',angkmap(k,:),'LineStyle','--');
        plot(AngK.scales,AngK.simMin{k},'Color',angkmap(k,:),'LineStyle','--');
        xlabel('Scale')
        ylabel('Population Alignment')
        title(AngK.name{k})
        ylim([-1 1])
        xlim([scales(1) scales(end)])
    end
end

%% Alignment maps
scaleid = 2;
HairCellAlignment = AngK.Ori{1}(:,scaleid);
SupportCellAlignment = AngK.Ori{4}(:,scaleid);
CellProps.Alignment = [HairCellAlignment; SupportCellAlignment];
DataMapArray(ImDat,CellProps,'Alignment','Type','cmap',OrientColMap,'varlims',[-1 1])
xlabel(sprintf('Alignment at r=%d',scales(scaleid)));

scaleid = length(scales);
HairCellAlignment = AngK.Ori{1}(:,scaleid);
SupportCellAlignment = AngK.Ori{4}(:,scaleid);
CellProps.Alignment = [HairCellAlignment; SupportCellAlignment];
DataMapArray(ImDat,CellProps,'Alignment','Type','cmap',OrientColMap,'varlims',[-1 1])
xlabel(sprintf('Alignment at r=%d',scales(scaleid)));