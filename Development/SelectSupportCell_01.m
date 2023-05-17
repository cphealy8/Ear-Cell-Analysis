clc;clear;close all;
RAW = imread('RAW.png');
HCellSelect = imread('HairCellSelection.bmp');

imG = localcontrast(RAW(:,:,2)); % Green Channel contrasted;

% Subtract Hair Cells
subHCells = uint8(double(imG).*double(~HCellSelect));

% Remove Stereociliary bundles. These bundles are brighter than anything 
% else in the image. 
imThresh = subHCells;
imThresh(imThresh>50) = 0;
imThresh = imadjust(imThresh);

% Correct Background
imMedian = medfilt2(imThresh,5.*[1 1]);
imFlat = localcontrast(imflatfield(imMedian,20),1.0,0.5);

% Binarize
imClose = imclose(imFlat,strel('disk',3));
% Refine edges
imBW = imbinarize(imFlat,0.3);
imOpen = imerode(imBW,strel('disk',1));

% Invert
imInvert = ~imOpen;

%% Watershedding
D = -bwdist(~imInvert);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);

imShed = imInvert;
imShed(Ld2==0) = 0;
imShed = ~imShed;

imAOpen = bwareaopen(imShed,20);

% Erode and make uniform boundaries;
imSkel = bwmorph(imShed,'thin',inf);
imBounds = bwareaopen(imdilate(imSkel,strel('disk',1)),200);


%% Refine with morphological thresholding
imReg = ~imBounds;
sizeRef = bwpropfilt(imReg,'Area',[100 1000]);
figure
imshowpair(imReg,sizeRef,'blend');

% Reapply hair cell removal
imRegHRem = imdilate(bwmorph(HCellSelect,'thin',inf),strel('disk',1));
addHoles2Hair = logical(sizeRef.*~imRegHRem);
typeRef = bwpropfilt(addHoles2Hair,'EulerNumber',[1 1]);

figure
imshowpair(sizeRef,typeRef,'blend');

figure
imshow(RAW);
hold on
visboundaries(bwboundaries(typeRef),'LineWidth',0.5);

%% Compute properties of Cells
CellProps = bwcompprops(typeRef);

% Expand Ellipses slightly.
expansionFactor = 1.0;
CellProps.MajorAxisLength = CellProps.MajorAxisLength.*expansionFactor;
CellProps.MinorAxisLength = CellProps.MinorAxisLength.*expansionFactor;

CellIms = EllipseCrop(RAW,CellProps);

figure
montage(CellIms)

save('SupportCellDat.mat','CellIms','CellProps')