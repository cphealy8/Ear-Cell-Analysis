function [CellProps,ImDat] = SelectHairCellG(RAW)
%SELECTHAIRCELL Summary of this function goes here
%   Detailed explanation goes here
EllipticalApproximation = false;
Contrasted = localcontrast(RAW);

% Next separate the channels
imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);


%% 
% To segment the hair cells we will use the red channel. The next step is 
% to apply a filter to reduce noise. We will compare a gaussian filter and a median 
% filter.
imMedian = medfilt2(gpuArray(imR),15.*[1 1]);

%% 
% Notice how the illumination of each hair cell is different. To correct 
% this the median filtered image was flat fielded. This requires blurring the 
% image then subtracting the blurred image from the original. 
imFlat = imflatfield(gather(imMedian),100);

%% 
% Of these flat-fielded images, the one that used sigma=100 gave the best 
% balance between leveling the illumination and preserving shape. If we apply 
% local contrasting again, the 
imFlatCon = localcontrast(imFlat,0.7,0.7);

%% 
% Finally the image can be adaptively thresholded to obtain a binary mask 
% indicating the position of hair cells. 
imBW = imbinarize(imFlatCon,0.2);

%% 
% Next we will apply a small binary close to solidify the cells followed 
% by a larger binary open to remove small pixel noise. Finally, a small dilation 
% will be applied to make sure that the selection includes the entire hair cells. 

imClose = imclose(gpuArray(imBW),strel('disk',2));
imOpen = imopen(imClose,strel('disk',8));
imDil = imdilate(imOpen,strel('disk',2));


% Omit Boundary Features from further analysis
imDil = imclearborder(gather(imDil));
%% 
% Next, the hair cells must be approximated as ellipses. To do this, the 
% centroids of the binary regions in the mask that correspond to each cell are 
% computed as well as their major axis length, minor axis length, and orientation. 

CellProps = bwcompprops(gpuArray(imDil));

%% Add a few additional descriptors to the CellProps table
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(imDil,imR,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(imDil,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(imDil,imB,'MeanIntensity')))';

pixIDs = struct2cell(regionprops(imDil,'PixelIdxList'));

%% Refine the set
% Remove cells that have an average intensity less than some predefined
% threshold.
CellProps.PixIDs = pixIDs';

omittedCells = CellProps.ID(CellProps.AvgIntensityR<20);
omittedPixels = cell2mat(pixIDs(omittedCells));
imDil(omittedPixels(:)) = 0;
CellProps(omittedCells,:) = [];
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';

if EllipticalApproximation==true
    imEllipse = bwEllipse(size(imDil),CellProps.Centroid,CellProps.MajorAxisLength,CellProps.MinorAxisLength,CellProps.Orientation);
else
    imEllipse = imDil;
end

% Isolate the cells
[LabMaskG,~] = bwlabel(gpuArray(imDil));
[LabEllipseG,~] = bwlabel(gpuArray(imEllipse));

LabEllipse = gather(LabEllipseG);
LabMask = gather(LabMaskG);


% Store Data
ImDat.RAW = RAW;
ImDat.Red = imR;
ImDat.Blue = imB;
ImDat.Green = imG;
ImDat.HairCellMask = imDil;
ImDat.HairCellEllipseMask = imEllipse;
ImDat.HairCellLabels = LabMask;
ImDat.HairCellEllipseLabels = LabEllipse;

CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('H',[nHair 1]);

CellProps.CellIm = labelSeparate(RAW,LabEllipse,'mask')';
CellProps.CellImRed = labelSeparate(imR,LabEllipse,'mask')';
CellProps.CellImGreen = labelSeparate(imG,LabEllipse,'mask')';
CellProps.CellImBlue = labelSeparate(imB,LabEllipse,'mask')';
CellProps.CellMaskEllipse = labelSeparate(imEllipse,LabEllipse,'mask')';
CellProps.CellMask = labelSeparate(imDil,LabMask,'mask')';
end

