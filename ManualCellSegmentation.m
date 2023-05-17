addpath('Sourced Functions')
clc; clear; close all;
%%

% Gamma Tubulin
% RAW = imread('GammaTub_02_merge_cropped.png');
% HairCells = ~imread('GammaTub_02_merge_cropped_HairCells.bmp');
% CellBounds = imread('GammaTub_02_merge_cropped_Bounds_Skel.bmp');
% NotCells = ~imread('GammaTub_02_merge_cropped_NotCells.bmp');
% BasalBodies = ~imread('GammaTub_02_merge_cropped_BB.bmp');

% Pericentrin Labeled
% RAW = imread('GammaTub_02_merge_cropped.png');
% HCells = ~imread('GammaTub_02_merge_cropped_HairCells.bmp');
% Bounds = imread('GammaTub_02_merge_cropped_Bounds_Skel.bmp');
% NotCells = ~imread('GammaTub_02_merge_cropped_NotCells.bmp');
% BasalBodies = ~imread('GammaTub_02_merge_cropped_BB.bmp');

% SupportCells = true(imx,imy)-HairCells-NotCells;

%% New section
root = 'Data/P12/P12_Utricle';
RAW = imread(strcat(root,'_RAW.png'));

Invert = false;
if Invert
    HairCells = ~imread(strcat(root,'_HairCells.bmp'));
    SupportCells = ~imread(strcat(root,'_SupportCells.bmp'));
    CellBounds = ~imread(strcat(root,'_CellBoundaries.bmp'));
    PolarBodies = ~imread(strcat(root,'_PolarBodies.bmp'));
    
else
    HairCells = imread(strcat(root,'_HairCells.bmp'));
    SupportCells = imread(strcat(root,'_SupportCells.bmp'));
    CellBounds = imread(strcat(root,'_CellBoundaries.bmp'));
    PolarBodies = imread(strcat(root,'_PolarBodies.bmp'));
end
    [imx,imy] = size(HairCells);
%% Refine Cell Selections
sdisk = strel('disk',1);
CellBounds = imdilate(CellBounds,sdisk);
HairCells = HairCells-CellBounds;
SupportCells = SupportCells-CellBounds;

CellBounds(CellBounds<0) = 0;
HairCells(HairCells<0) = 0;
SupportCells(SupportCells<0) = 0;

CellBounds = logical(CellBounds);
HairCells = imclearborder(logical(HairCells));
SupportCells = imclearborder(logical(SupportCells));

%% Extract Cell params
[HairCellProps,ImDat] = GetPropsAndIms(PolarBodies,HairCells,'CenterType','Visual');
HairCellProps.CellIm = labelSeparate(RAW,bwlabel(ImDat.Mask),'mask')';
[HairCellProps] = BBOrient(HairCellProps,HairCellProps.Im,'BB');
HairCellProps.Type = repmat('H',[height(HairCellProps) 1]);
[SupportCellProps,ImDat] = GetPropsAndIms(PolarBodies,SupportCells,'CenterType','Visual');
SupportCellProps.CellIm = labelSeparate(RAW,bwlabel(ImDat.Mask),'mask')';
[SupportCellProps] = BBOrient(SupportCellProps,SupportCellProps.Im,'BB');
SupportCellProps.Type = repmat('S',[height(SupportCellProps) 1]);

% Filter out Support Cells that are not in contact with hair cells.
[keptSupportCells,~,SupportCells] = IsNeighbor(SupportCells,HairCells,7);
SupportCellProps(~keptSupportCells,:)=[];
SupportCellProps.ID=(1:height(SupportCellProps))';

%% Merge
CellProps = [HairCellProps; SupportCellProps];


%% Set Boundary
[CellProps,BoundPts,ImDat.ImBound] = SelectUtricleBoundary(RAW,'CellProps',CellProps,'CloseRad',2); 
CellProps.CombinedOrientation = CellProps.BBOrientation;
% Normalize orientations with respect to the Utricular Boundary. 
CellProps.NormOrientation = wrapTo360(CellProps.RefAngle-CellProps.CombinedOrientation);
% CellProps.NormOrientation = CellProps.BBOrientation;
%% other stuff

CellProps.CombinedPolarity = CellProps.BBPolarity;

CellProps(isnan(CellProps.BBOrientation),:)=[];
CellProps.DblAngOrientation = DblAngTransform(CellProps.NormOrientation,'deg');
%% add extra stuff

ImDat.HairCellMask = HairCells;
ImDat.SupportCellMask = SupportCells;
ImDat.RAW = RAW;

% Convert old polarities to Mapped Polarities
getPol = @(x,y) mean(y(BWShrink2Pt(x)),'omitnan');
CellProps.CombinedPolarity = cell2mat(cellfun(getPol,CellProps.Im, CellProps.PolMap,'UniformOutput',false));

ImDat.CellBounds = CellBounds;
ImDat.PolarBodies = PolarBodies;
%% Save Results
savename = strcat(root,'_ManualSeg_data_',qdt('Full'),'.mat');
save(savename,'CellProps','ImDat','BoundPts');


