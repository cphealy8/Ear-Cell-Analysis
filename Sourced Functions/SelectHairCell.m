function [CellProps,ImDat] = SelectHairCell(RAW,varargin)
%SELECTHAIRCELL Summary of this function goes here
%   Detailed explanation goes here
%% Parse Inputs
p = inputParser;

addRequired(p,'RAW',@isnumeric)
addParameter(p,'Channel','R',@ischar)
addParameter(p,'MedFilt',15,@isnumeric)
addParameter(p,'FlatField',100,@isnumeric)
addParameter(p,'LocalCon',[0.7 0.7],@isnumeric)
addParameter(p,'BWThresh',0.2,@isnumeric)
addParameter(p,'CloseRad',3,@isnumeric)
addParameter(p,'OpenRad',6,@isnumeric)
addParameter(p,'DilateRad',2,@isnumeric)
addParameter(p,'ClearBorder',true,@islogical)
addParameter(p,'MinAvgInt',20,@isnumeric)
addParameter(p,'EllipApprox',true,@islogical);
addParameter(p,'Suppress',false,@islogical);

checkCtrType = @(x) any(validatestring(x,{'Centroid','Visual'}));
addParameter(p,'CenterType','Centroid',checkCtrType);

parse(p,RAW,varargin{:});

Channel = p.Results.Channel;
MedFilt = p.Results.MedFilt;
FlatField = p.Results.FlatField;
LocalCon = p.Results.LocalCon;
BWThresh = p.Results.BWThresh;
CloseRad = p.Results.CloseRad;
OpenRad = p.Results.OpenRad;
DilateRad = p.Results.DilateRad;
ClearBorder= p.Results.ClearBorder;
MinAvgInt = p.Results.MinAvgInt;
EllipApprox = p.Results.EllipApprox;
Suppress = p.Results.Suppress;
CenterType = p.Results.CenterType;

%%
Contrasted = localcontrast(RAW);

% Next separate the channels
imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);

switch Channel
    case 'R'
        imCells = imR;
    case 'G'
        imCells = imG;
    case 'B'
        imCells = imB;
end

imK{1} = imCells;
%% 
% To segment the hair cells we will use the red channel. The next step is 
% to apply a filter to reduce noise. We will compare a gaussian filter and a median 
% filter.
imMedian = medfilt2(imCells,MedFilt.*[1 1]);
imK{2} = imMedian;
%% 
% Notice how the illumination of each hair cell is different. To correct 
% this the median filtered image was flat fielded. This requires blurring the 
% image then subtracting the blurred image from the original. 
imFlat = imflatfield(imMedian,FlatField);
imK{3} = imFlat;
%% 
% Of these flat-fielded images, the one that used sigma=100 gave the best 
% balance between leveling the illumination and preserving shape. If we apply 
% local contrasting again, the 
imFlatCon = localcontrast(imFlat,LocalCon(1),LocalCon(2));
imK{4} = imFlatCon;

%% 
% Finally the image can be adaptively thresholded to obtain a binary mask 
% indicating the position of hair cells. 
imBW = imbinarize(imFlatCon,BWThresh);
imK{5} = imBW;

%% 
% Next we will apply a small binary close to solidify the cells followed 
% by a larger binary open to remove small pixel noise. Finally, a small dilation 
% will be applied to make sure that the selection includes the entire hair cells. 

imClose = imclose(imBW,strel('disk',CloseRad));
imOpen = imopen(imClose,strel('disk',OpenRad));
imDil = imdilate(imOpen,strel('disk',DilateRad));

imK{6} = imClose;
imK{7} = imOpen;
imK{8} = imDil;

% Omit Boundary Features from further analysis
if ClearBorder
    imDil = imclearborder(imDil);
end
imK{9} =imDil;
%% 
% Next, the hair cells must be approximated as ellipses. To do this, the 
% centroids of the binary regions in the mask that correspond to each cell are 
% computed as well as their major axis length, minor axis length, and orientation. 

CellProps = bwcompprops(imDil);

% Replace Center Type if requested
if strcmp(CenterType,'Visual')
    CellProps.Centroid = BWVisualCenter(imDil);
end


%% Add a few additional descriptors to the CellProps table
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(imDil,imCells,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(imDil,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(imDil,imB,'MeanIntensity')))';

pixIDs = struct2cell(regionprops(imDil,'PixelIdxList'));

%% Refine the set
% Remove cells that have an average intensity less than some predefined
% threshold.
CellProps.PixIDs = pixIDs';
switch Channel
    case 'R'
        omittedCells = CellProps.ID(CellProps.AvgIntensityR<MinAvgInt);
    case 'G'
        omittedCells = CellProps.ID(CellProps.AvgIntensityG<MinAvgInt);
    case 'B'
        omittedCells = CellProps.ID(CellProps.AvgIntensityB<MinAvgInt);
end

try
    omittedPixels = cell2mat(pixIDs(omittedCells));
catch
    omittedPixels = cell2mat(pixIDs(omittedCells)');
end

imDil(omittedPixels(:)) = 0;
CellProps(omittedCells,:) = [];
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';

imK{10} = imDil;

if EllipApprox==true
    imEllipse = bwEllipse(size(imDil),CellProps.Centroid,CellProps.MajorAxisLength,CellProps.MinorAxisLength,CellProps.Orientation);
else
    imEllipse = imDil;
end

% Isolate the cells
[LabMask,~] = bwlabel(imDil);
[LabEllipse,~] = bwlabel(imEllipse);




% Store Data
ImDat.RAW = RAW;
ImDat.Red = imCells;
ImDat.Blue = imB;
ImDat.Green = imG;
ImDat.HairCellMask = imDil;
ImDat.HairCellEllipseMask = imEllipse;
ImDat.HairCellLabels = LabMask;
ImDat.HairCellEllipseLabels = LabEllipse;
ImDat.imK = imK;

if ~Suppress
CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('H',[nHair 1]);

[CellIms,~,pxrows,pxcols] = labelSeparate(RAW,LabEllipse,'mask');
CellProps.CellIm = CellIms';
CellProps.pxrows = pxrows';
CellProps.pxcols = pxcols';

CellProps.CellImRed = labelSeparate(imCells,LabEllipse,'mask')';
CellProps.CellImGreen = labelSeparate(imG,LabEllipse,'mask')';
CellProps.CellImBlue = labelSeparate(imB,LabEllipse,'mask')';
CellProps.CellMaskEllipse = labelSeparate(imEllipse,LabEllipse,'mask')';
CellProps.CellMaskRough = labelSeparate(imDil,LabMask,'mask')';

if EllipApprox==true
    CellProps.CellMask = CellProps.CellMaskEllipse;
%     ImDat.HairEdge2Center= BW_Edge2CtrDist(imEllipse);
%     CellProps.PolMap = labelSeparate(ImDat.HairEdge2Center,LabEllipse,'mask')';
else
    CellProps.CellMask = CellProps.CellMaskRough;
    ImDat.HairEdge2Center= BW_Edge2CtrDist(imDil);
    CellProps.PolMap = labelSeparate(ImDat.HairEdge2Center,LabMask,'mask')';
end
end

% Compute edge2center maps for polarity calculations.

end

