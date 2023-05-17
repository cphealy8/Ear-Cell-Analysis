clc;clear;close all;

% Add the directories that this code needs to access.
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

imagename = 'P0_RAW';

%% Analyze Image
EllipticalApproximation = false;
% Read in the image to be analyzed
RAW = imread(strcat(imagename,'.png'));

[BPix,map] = BoundPix(RAW);

% Identify the hair cells in the image.
[HairCellProps,ImDat] = SelectHairCell(RAW,'CenterType','Visual','EllipApprox',EllipticalApproximation);
% [HairCellProps,ImDat] = SelectHairCellAlt(RAW,EllipticalApproximation);

% Compute the hair cell orientation based on basal body position.
[HairCellProps] = OrientHairCell_BB(HairCellProps,'Channel','B');

% Compute the hair cell orientation based on fonticulus position.
[HairCellProps] = OrientHairCell_Fonticulus(HairCellProps);

% Identify the support cells in the image
[SupportCellProps,ImDat] = SelectSupportCell(RAW,ImDat,EllipticalApproximation,'CenterType','Visual');

% Filter out Support Cells that are not in contact with hair cells.
[keptSupportCells,~,ImDat.SupportCellMask] = IsNeighbor(ImDat.SupportCellMask,ImDat.HairCellMask,7);
SupportCellProps(~keptSupportCells,:)=[];
SupportCellProps.ID=(1:height(SupportCellProps))';

% Compute support cell orientation based upon basal body position.
[SupportCellProps] = OrientSupportCell_BB(SupportCellProps,'Channel','B');

% Add empty values for orientation/polarity values base upon fonticulus
% position to the Support Cell data structure.
SupportCellProps = addFonticulusVals(SupportCellProps);


% Combine the hair cell and support cell data structures.
CellProps = [HairCellProps; SupportCellProps];
% Consolidate basal body and fonticulus data. Prompt user-input when the
% difference in orientations between these is greater than the threshold
% specified by the second argument below. (Usually 90 degrees)
CellProps = CombineBBAndFont(CellProps,90);

% A magnitude of polarity greater than 1 is impossible. When these occur,
% prompt user input.
CellProps = CorrectPolarity(CellProps); 

% Identify the utricular boundary and calculate reference angles. 
[CellProps,BoundPts,ImDat.ImBound,UserPts] = SelectUtricleBoundary(RAW,'CellProps',CellProps,'CloseRad',2); 


% Normalize orientations with respect to the Utricular Boundary. 
CellProps.NormOrientation = wrapTo180(CellProps.RefAngle-CellProps.CombinedOrientation);

% Omit NaN entries
nanOri = isnan(CellProps.NormOrientation);
nanPol = isnan(CellProps.CombinedPolarity);
CellProps(nanOri|nanPol,:)=[];

% Prompt additional user input where needed. 
% Use mapped polarity if Elliptical approximation isn't true
if ~EllipticalApproximation
    CellProps = ConvPolToMapPol(CellProps);
end

%% Save Results
curtime = qdt('Full');
savedir = fullfile('Data',imagename);
mkdir (savedir)

savename = strcat(imagename,'_','data','_',curtime,'.mat');
save(fullfile(savedir,savename),'CellProps','ImDat','BoundPts');

