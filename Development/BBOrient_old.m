function [CellProps] = BBOrient_old(CellProps,BBIms)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

%% Compute basal body stats
Nomit = 0;
nCells = length(BBIms);
for k = 1:nCells
    % Compute some useful stats
if ~isempty(regionprops(BBIms{k},'Area'))
    bprops = regionprops(BBIms{k},'Area','Centroid');
    bType(k,1) = 1;
    bArea(k,1) = bprops.Area;
    bLocalCenter(k,1:2) = bprops.Centroid;
    
else
    bType(k,1) = 0;
    bArea(k,1) = 0;
    bLocalCenter(k,1:2) = [nan nan];
    Nomit = Nomit+1;
end

end

% Append to cell property table
CellProps.BBDetected = bType;
CellProps.BBArea = bArea;
CellProps.BBLocalCentroid = bLocalCenter;
CellProps.BBSize = [CellProps.xdim CellProps.ydim];

% Convert BB Local Center to global coordinates.
CellProps.BBCentroid = CellProps.Centroid...
    -CellProps.BBSize./2+CellProps.BBLocalCentroid;

% Compute the magnitude and orientation of the polarity
CellProps.dX = CellProps.BBCentroid(:,2)-CellProps.Centroid(:,2);
CellProps.dY = CellProps.BBCentroid(:,1)-CellProps.Centroid(:,1);
CellProps.EOrientation = CellProps.Orientation;
CellProps.GlobalOrientation = atan2d(CellProps.dY,CellProps.dX);
CellProps.BBDistance = sqrt((CellProps.dX).^2+(CellProps.dY).^2);

% Normalize
CellProps.Orientation = CellProps.GlobalOrientation;
a = CellProps.MajorAxisLength/2;
b = CellProps.MinorAxisLength/2;
alpha = CellProps.GlobalOrientation;
theta = CellProps.EOrientation;
CellProps.Ctr2EdgeDist = (a.*b)./sqrt((b.^2-a.^2).*cosd(alpha-theta).^2+a.^2);

CellProps.Polarity = CellProps.BBDistance./CellProps.Ctr2EdgeDist;

CellProps.EX = CellProps.Ctr2EdgeDist.*cosd(CellProps.GlobalOrientation);
CellProps.EY = CellProps.Ctr2EdgeDist.*sind(CellProps.GlobalOrientation);
CellProps.EPt = [CellProps.Centroid(:,1)+CellProps.EY CellProps.Centroid(:,2)+CellProps.EX];
end

