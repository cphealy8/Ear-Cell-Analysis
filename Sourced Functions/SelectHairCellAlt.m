function [CellProps,ImDat] = SelectHairCellAlt(RAW,EllipticalApproximation)
%SELECTHAIRCELL Summary of this function goes here
%   Detailed explanation goes here
Contrasted = localcontrast(RAW);

% Next separate the channels
imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);

%% Get Cell Mask
CellMask = SelectCells(RAW,'Blue','RemBoundCells',true);

%% Get Morphologys
CellProps = bwcompprops(CellMask);

% CellProps.ConvexArea = cell2mat(struct2cell(regionprops(imBndOut,'ConvexArea')))';
CellProps.Circularity = (4*pi*CellProps.Area)./(CellProps.Perimeter.^2);
%% Add a few additional descriptors to the CellProps table
HairCellMask = CellMask;

nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(HairCellMask,imR,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(HairCellMask,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(HairCellMask,imB,'MeanIntensity')))';

%% Refine the set based on circularity
% Remove cells that have an average intensity less than some predefined
% threshold.

pixIDs = CellProps.PixelIdxList;
% omittedCells = CellProps.ID(CellProps.AvgIntensityR<20);
NotCircular = CellProps.ID(CellProps.Circularity<0.85 | CellProps.Circularity>1.05);
NotSolid = CellProps.ID(CellProps.Solidity<0.95);
TooSmall = CellProps.ID(CellProps.Area<400);
omittedCells = unique([NotCircular; NotSolid;TooSmall]);
% omittedCells = NotCircular
omittedPixels = cell2mat(pixIDs(omittedCells));
HairCellMask(omittedPixels(:)) = 0;
CellProps(omittedCells,:) = [];
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';

if EllipticalApproximation==true
    [imEllipse,EllipseMasks] = bwEllipse(size(HairCellMask),CellProps.Centroid,CellProps.MajorAxisLength,CellProps.MinorAxisLength,CellProps.Orientation);
else
    imEllipse = HairCellMask;
end

% Isolate the cells
[LabMask,~] = bwlabel(HairCellMask);
[LabEllipse,~] = bwlabel(imEllipse);

% Store Data
ImDat.RAW = RAW;
ImDat.Red = imR;
ImDat.Blue = imB;
ImDat.Green = imG;
ImDat.CellMask = CellMask;
ImDat.HairCellMask = HairCellMask;
ImDat.HairCellEllipseMask = imEllipse;
ImDat.HairCellLabels = LabMask;
ImDat.HairCellEllipseLabels = LabEllipse;

CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('H',[nHair 1]);

[CroppedIms,CellMasks] = Crop2Mask(RAW,EllipseMasks);
CellProps.CellIm = CroppedIms';
CellProps.CellMaskEllipse = CellMasks';
CellProps.CellImRed = Crop2Mask(imR,EllipseMasks)';
CellProps.CellImGreen = Crop2Mask(imG,EllipseMasks)';
CellProps.CellImBlue = Crop2Mask(imB,EllipseMasks)';



% CellProps.CellIm = labelSeparate(RAW,LabEllipse,'mask')';
% CellProps.CellImRed = labelSeparate(imR,LabEllipse,'mask')';
% CellProps.CellImGreen = labelSeparate(imG,LabEllipse,'mask')';
% CellProps.CellImBlue = labelSeparate(imB,LabEllipse,'mask')';
% CellProps.CellMaskEllipse = labelSeparate(imEllipse,LabEllipse,'mask')';


if EllipticalApproximation==true
    CellProps.CellMask = CellProps.CellMaskEllipse;
else
    CellProps.CellMask = labelSeparate(HairCellMask,LabMask,'mask')';
end

end

