clc;clear;close all;

% Add the directories that this code needs to access.
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

imagename = 'GammaTub_02_merge_cropped';

%% Analyze Image
EllipticalApproximation = true;
% Read in the image to be analyzed
RAW = imread(strcat(imagename,'.png'));

[BPix,map] = BoundPix(RAW);

% Identify the hair cells in the image.
% [HairCellProps,ImDat] = SelectHairCell(RAW,EllipticalApproximation);
[HairCellProps,ImDat] = SelectHairCellAlt(RAW,EllipticalApproximation);

% Compute the hair cell orientation based on basal body position.
[HairCellProps] = OrientHairCell_BB(HairCellProps,'red');

% Compute the hair cell orientation based on fonticulus position.
[HairCellProps] = addFonticulusVals(HairCellProps,'SetEqual');

% Identify the support cells in the image
[SupportCellProps,ImDat] = SelectSupportCellAlt(RAW,ImDat,EllipticalApproximation);

% Compute support cell orientation based upon basal body position.
[SupportCellProps] = OrientSupportCell_BB(SupportCellProps,'red');

% Add empty values for orientation/polarity values base upon fonticulus
% postion to the Support Cell data structure.
SupportCellProps = addFonticulusVals(SupportCellProps);


% Combine the hair cell and support cell data structures.
CellProps = [HairCellProps; SupportCellProps];
% Consolidate basal body and fonticulus data. Prompt user-input when the
% difference in orientations between these is greater than the threshold
% specified by the second argument below. (Usually 90 degrees)
CellProps = CombineBBAndFont(CellProps,90);

% Prompt additional user input where needed. 
% A magnitude of polarity greater than 1 is impossible. When these occur,
% prompt user input.

CellProps = CorrectPolarity(CellProps); 

% Identify the utricular boundary.
CellProps.RefAngle = zeros(height(CellProps),1);
% tic
% [CellProps,BoundPts,ImDat.ImBound] = SelectUtricleBoundary(RAW,CellProps,'CloseFactor',2); 
% toc
% Define an arbitrary utricular boundar
[imW,imH,imz]=size(RAW);
BoundPts =[1 1;1 imH/2; 1 imH];


% Normalize orientations with respect to the Utricular Boundary. 
CellProps.NormOrientation = wrapTo180(CellProps.RefAngle-CellProps.CombinedOrientation);

%% Save Results
curtime = qdt('Full');
savedir = fullfile('Data',imagename);
mkdir (savedir)

savename = strcat(imagename,'_','data','_',curtime,'.mat');
save(fullfile(savedir,savename),'CellProps','ImDat','BoundPts');

