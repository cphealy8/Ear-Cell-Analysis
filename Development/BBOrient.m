function [CellProps] = BBOrient(CellProps,BBIms)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

%% Compute basal body stats
Nomit = 0;
nCells = length(BBIms);
for k = 1:nCells
    % Compute some useful stats
    [CellHeight(k),CellWidth(k),Depth] = size(BBIms{k});
if ~isempty(regionprops(BBIms{k},'Area'))
    bprops = regionprops(BBIms{k},'Area','Centroid');
    bType(k,1) = 1;
    bArea(k,1) = bprops.Area;
    bLocalCentroid(k,1:2) = bprops.Centroid;
    
else
    bType(k,1) = 0;
    bArea(k,1) = 0;
    bLocalCentroid(k,1:2) = [nan nan];
    LocalCentroid = [nan nan];
    Nomit = Nomit+1;
end

end

% Append to cell property table
CellProps.BBDetected = bType;
CellProps.BBArea = bArea;
CellProps.BBLocalCentroid = bLocalCentroid;
CellProps.CellWidth = CellWidth';
CellProps.CellHeight = CellHeight';

CellProps.LocalCentroid = [CellWidth' CellHeight']./2;
CellProps.dX = CellProps.BBLocalCentroid(:,1)-CellProps.LocalCentroid(:,1);
CellProps.dY = CellProps.BBLocalCentroid(:,2)-CellProps.LocalCentroid(:,2);

CellProps.BBCentroid = CellProps.Centroid+[CellProps.dX CellProps.dY];

CellProps.EllipseOrientation = -CellProps.Orientation;
CellProps.GlobalOrientation = atan2d(CellProps.dY,CellProps.dX);
CellProps.BBDistance = sqrt((CellProps.dX).^2+(CellProps.dY).^2);

% Normalize
CellProps.Orientation = CellProps.GlobalOrientation;
a = CellProps.MajorAxisLength/2;
b = CellProps.MinorAxisLength/2;
alpha = CellProps.GlobalOrientation;
theta = CellProps.EllipseOrientation;
CellProps.Ctr2EdgeDist = (a.*b)./sqrt((b.^2-a.^2).*cosd(alpha-theta).^2+a.^2);

CellProps.Polarity = CellProps.BBDistance./CellProps.Ctr2EdgeDist;

CellProps.EX = CellProps.Ctr2EdgeDist.*cosd(CellProps.GlobalOrientation);
CellProps.EY = CellProps.Ctr2EdgeDist.*sind(CellProps.GlobalOrientation);
CellProps.EPt = CellProps.Centroid+[CellProps.EX CellProps.EY];
end

