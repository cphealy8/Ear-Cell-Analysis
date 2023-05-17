function [CellProps,ImDat] = SelectSupportCellAlt(RAW,ImDat,EllipticalApproximation)
imB = localcontrast(RAW(:,:,3)); % Blue Channel contrasted;
imG = localcontrast(RAW(:,:,2)); % Green Channel contrasted;
imR = localcontrast(RAW(:,:,1)); % Red Channel contrasted;


[width,height,depth] = size(RAW);
HairCellMask = ImDat.HairCellMask;
CellMask = ImDat.CellMask;
% Get Cell mask
SupportCellMask = logical(CellMask.*~HairCellMask);

%% Get morphological properties
CellProps = bwcompprops(SupportCellMask);
nSupport = length(CellProps.Area);

% Add additional properties.
CellProps.Circularity = (4*pi*CellProps.Area)./(CellProps.Perimeter.^2);
CellProps.ID = (1:nSupport)';

%% Refine with morphological thresholding
pixIDs = CellProps.PixelIdxList;

WrongArea = CellProps.ID(CellProps.Area<100 | CellProps.Area>1500);
omittedCells = unique(WrongArea);

omittedPixels = cell2mat(pixIDs(omittedCells));
SupportCellMask(omittedPixels(:)) = 0;
CellProps(omittedCells,:) = [];
nSupport= length(CellProps.Area);
CellProps.ID = (1:nSupport)';

%% Expand Ellipses slightly.
expansionFactor = 1.0;
CellProps.MajorAxisLength = CellProps.MajorAxisLength.*expansionFactor;
CellProps.MinorAxisLength = CellProps.MinorAxisLength.*expansionFactor;


%% Alternate

if EllipticalApproximation==true
    [CellIms,MaskIms] = EllipseCrop(RAW,CellProps);
else
    [LabMask,~] = bwlabel(SupportCellMask);
    CellIms = labelSeparate(RAW,LabMask,'mask');
    MaskIms = labelSeparate(SupportCellMask,LabMask,'mask');
end

%% Save

nCells = length(CellProps.Area);
CellProps.ID = (1:nCells)';
CellProps.AvgIntensityR = cell2mat(struct2cell(regionprops(SupportCellMask,imR,'MeanIntensity')))';
CellProps.AvgIntensityG = cell2mat(struct2cell(regionprops(SupportCellMask,imG,'MeanIntensity')))';
CellProps.AvgIntensityB = cell2mat(struct2cell(regionprops(SupportCellMask,imB,'MeanIntensity')))';

% CellProps.PixIDs =  struct2cell(regionprops(SupportCellMask,'PixelIdxList'))';

CellProps.Properties.VariableNames{6} = 'EllipseOrientation';

CellProps.Type = repmat('S',[nCells 1]);
CellProps.CellIm = CellIms';

for n = 1:nCells
    CellImRed{n} = CellProps.CellIm{n}(:,:,1);
    CellImGreen{n} = CellProps.CellIm{n}(:,:,2);
    CellImBlue{n} = CellProps.CellIm{n}(:,:,3);
end

CellProps.CellImRed = CellImRed';
CellProps.CellImGreen = CellImGreen';
CellProps.CellImBlue = CellImBlue';

CellProps.CellMaskEllipse = MaskIms';

CellProps.CellMask = labelSeparate(true(width,height),bwlabel(SupportCellMask),'mask')';
ImDat.SupportCellMask = SupportCellMask;

if EllipticalApproximation==true
    CellProps.CellMask = CellProps.CellMaskEllipse;
else
    CellProps.CellMask = labelSeparate(true(width,height),bwlabel(SupportCellMask),'mask')';
end

end
