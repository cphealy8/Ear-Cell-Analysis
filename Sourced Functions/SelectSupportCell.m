function [CellProps,ImDat] = SelectSupportCell(RAW,ImDat,EllipticalApproximation,varargin)

%% Parse inputs
p = inputParser;
addRequired(p,'RAW',@isnumeric);
addRequired(p,'ImDat',@isstruct);
addRequired(p,'EllipticalApproximation',@islogical)
checkCtrType = @(x) any(validatestring(x,{'Centroid','Visual'}));
addParameter(p,'CenterType','Centroid',checkCtrType);

parse(p,RAW,ImDat,EllipticalApproximation,varargin{:});

CenterType = p.Results.CenterType;
%%
imB = localcontrast(RAW(:,:,3)); % Blue Channel contrasted;
imG = localcontrast(RAW(:,:,2)); % Green Channel contrasted;
imR = localcontrast(RAW(:,:,1)); % Red Channel contrasted;

imK{1} = imG;
[width,height,depth] = size(RAW);
HairCellMask = ImDat.HairCellMask;
% Subtract Hair Cells
subHCells = uint8(double(imG).*double(~HairCellMask));
imK{2} = subHCells;
% Remove Stereociliary bundles. These bundles are brighter than anything 
% else in the image. 
imThresh = subHCells;
imThresh(imThresh>50) = 0;
imThresh = imadjust(imThresh);
imK{3} = imThresh;

% Correct Background
imMedian = medfilt2(imThresh,5.*[1 1]);
imK{4} = imMedian;

imFlat = localcontrast(imflatfield(imMedian,20),1.0,0.5);
imK{5} = imFlat;

% Refine edges
imBW = imbinarize(imFlat,0.3);
imK{6} = imBW;

imOpen = imerode(imBW,strel('disk',1));
imK{7}= imOpen;

% Invert
imInvert = ~imOpen;
imK{8} = imInvert;

%% Watershedding
D = -bwdist(~imInvert);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);

imShed = imInvert;
imShed(Ld2==0) = 0;
imShed = ~imShed;
imK{9} = imShed;

% Erode and make uniform boundaries;
imSkel = bwmorph(imShed,'thin',inf);
imK{10} = imSkel;

imBounds = bwareaopen(imdilate(imSkel,strel('disk',1)),200);
imK{11} = imBounds;

%% Refine with morphological thresholding
imReg = ~imBounds;
sizeRef = bwpropfilt(imReg,'Area',[100 1000]);
imK{12} = sizeRef;

% Reapply hair cell removal
imRegHRem = imdilate(bwmorph(HairCellMask,'thin',inf),strel('disk',1));
addHoles2Hair = logical(sizeRef.*~imRegHRem);
typeRef = bwpropfilt(addHoles2Hair,'EulerNumber',[1 1]);
imK{13} = typeRef;

% Omit boundary features from further analysis
typeRef = imclearborder(typeRef);
imK{14} = typeRef;

%% Compute properties of Cells
CellProps = bwcompprops(typeRef);

% Change cell center if requested
if strcmp(CenterType,'Visual')
    CellProps.Centroid = BWVisualCenter(typeRef);
end

% Expand Ellipses slightly.
expansionFactor = 1.0;
CellProps.MajorAxisLength = CellProps.MajorAxisLength.*expansionFactor;
CellProps.MinorAxisLength = CellProps.MinorAxisLength.*expansionFactor;


%% Alternate

if EllipticalApproximation==true
    [CellIms,MaskIms,pxrows,pxcols] = EllipseCrop(RAW,CellProps);
else
    [LabMask,~] = bwlabel(typeRef);
    [CellIms,~,pxrows,pxcols] = labelSeparate(RAW,LabMask,'mask');
    MaskIms = labelSeparate(typeRef,LabMask,'mask');
end

ImDat.imK = imK;

%% Save

nCells = length(CellProps.Area);
CellProps.ID = (1:nCells)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(typeRef,imR,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(typeRef,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(typeRef,imB,'MeanIntensity')))';

CellProps.PixIDs =  struct2cell(regionprops(typeRef,'PixelIdxList'))';

CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('S',[nCells 1]);
CellProps.CellIm = CellIms';
CellProps.pxrows = pxrows';
CellProps.pxcols = pxcols';

for n = 1:nCells
    CellImRed{n} = CellProps.CellIm{n}(:,:,1);
    CellImGreen{n} = CellProps.CellIm{n}(:,:,2);
    CellImBlue{n} = CellProps.CellIm{n}(:,:,3);
end

CellProps.CellImRed = CellImRed';
CellProps.CellImGreen = CellImGreen';
CellProps.CellImBlue = CellImBlue';

CellProps.CellMaskEllipse = MaskIms';

CellProps.CellMaskRough = labelSeparate(true(width,height),bwlabel(typeRef),'mask')';
ImDat.SupportCellMask = typeRef;

if EllipticalApproximation==true
    CellProps.CellMask = CellProps.CellMaskEllipse;
else
    CellProps.CellMask = CellProps.CellMaskRough;
    ImDat.SupportEdge2Center= BW_Edge2CtrDist(typeRef);
    CellProps.PolMap = labelSeparate(ImDat.SupportEdge2Center,LabMask,'mask')';
end



end
