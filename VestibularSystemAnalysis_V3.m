clc;clear;close all;
% Add the directories that this code needs to access.
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

%% Analysis parameters
doAnnot = false;

%% Read in cell masks (segment or read)
% Read in Raw Image
[RawCell,RawFile,RawPath] = uigetimages('*.png','Select Raw File');
ImDat.RAW = RawCell{1}; 

% Read in Binary mask marking Cells
[CellMaskCell,CellMaskFile,CellMaskPath] = uigetimages('*.bmp','Select Cell Mask',RawPath); 
ImDat.CellMask = CellMaskCell{1}; 

[PolarBodyMaskCell,PolarBodyMaskFile,PolarBodyMaskPath] = uigetimages('*.bmp','Select Polar Body Mask',RawPath); % Binary mask marking polar bodies
ImDat.PolarBodyMask = PolarBodyMaskCell{1};

[imx,imy,imz] = size(ImDat.RAW);

%% Select Analysis Region
%%%% PLACEHOLDER %%%%
% This should allow the user to select a region, then mask the RAW image.
% It should then crop the image down to the masked region. This will
% improve computational time. 

%% Isolate Cells, Compute Polarity Map, Assign IDs, and cell type. 
% Isolate and store image channels. 
ImDat.ImR = ImDat.RAW(:,:,1);
ImDat.ImG = ImDat.RAW(:,:,2);
ImDat.ImB = ImDat.RAW(:,:,3);

% Isolate Hair cells and related features
[ImDat,CellProps] = SepImageComps(ImDat,'GroupName','',...
'ExtraIms',{ImDat.PolarBodyMask},...
'ExtraNames',{'PBMask'});

%% Calculate Visual Center, Polarity, Orientation and other morphological features.
[CellProps] = Masks2CtrPolOri(CellProps);

%% Get Reference Line and compute normalized orientation
[BoundPts,UserPts] = GetBoundaryLine(ImDat.RAW,'preview',true,'dispcenters',CellProps.Center);

% Generate reference angles according to an inverse square rule.
[~,CellProps.RefAngle,CellProps.RefX,CellProps.RefY] = pt2ptInfluence(CellProps.Center,BoundPts,'inverse',2);
CellProps.NormOrientation = wrapTo360(CellProps.Orientation-CellProps.RefAngle);

%% Preview annotation, and allow user to remove individual cells
[TypeID,ntypes,types] = GetTypeIDs(CellProps,'Type');

if doAnnot
    if ~any(strcmp('AnnotIm',CellProps.Properties.VariableNames))
    CellProps = AnnotIndIms(CellProps);
    %     save(fullfile(path,file),'CellProps','-append');
    end

    % Preview montage and allow user to remove cells.
    CellID = 1:height(CellProps)';
    RemID = []; % initialize removal ID; 
    mbox = msgbox('Click to select cells to remove. Hit enter when finished.');
    for k=1:ntypes
    %     figure
        curprops = CellProps(TypeID{k},:);
        curID = CellID(TypeID{k});
        [selectedIms] = GetMontageIDs(curprops.AnnotIm);
    %     title(types{k});
        RemID = [RemID curID(selectedIms)];
    %     montage(CellProps.AnnotIm(TypeID{k}))
    end
close(mbox);

    % remove selected cells from analysis. 
    CellProps(RemID',:) = [];
end

% Additional transformations of orientation
CellProps.OrientationR = wrapTo360(CellProps.Orientation)*pi/180; % Orientation in Radians
CellProps.NormOrientationR = wrapTo360(CellProps.NormOrientation)*pi/180; % Norm Orientation in Radians
CellProps.RefAngleR = wrapTo360(CellProps.RefAngle)*pi/180; % Reference Angle in Radians
CellProps.NormOrientation180 = flipTo180(CellProps.NormOrientation); % Normalized Orientation between 0 and 180

%% Rebuild Masks
ImDat.CellMaskR = false(imx,imy);
ImDat.CellMaskR(cell2mat(CellProps.PixIDs))=true;

%% preview histograms
polarhistogram(CellProps.NormOrientationR,40);
%% Save Results
curtime = qdt('Full');
root = erase(RawFile{1},'.png');
cellID =  erase(CellMaskFile{1},{root '.bmp' '_'});
defsavename = strcat(root,'_',cellID,'_analysis','_',curtime,'.mat');

[savefile,savepath] = uiputfile('*.mat','Save Analysis File',[RawPath defsavename]);

if ischar(savefile)
    save([savepath savefile],'CellProps','ImDat','BoundPts','RawFile',...
        'CellMaskFile','PolarBodyMaskFile')
end


% save(fullfile(impath,savename),'CellProps','ImDat','BoundPts');