function [CellProps] = BBOrient(CellProps,BBIms,varargin)
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
CellWidth = CellWidth';
CellHeight = CellHeight';

LocalCentroid = [CellWidth CellHeight]./2;

[BBX,BBY,BBCentroid,BBOrientation,BBDistance,BBEdgeDist,BBPolarity] = orientFromPoint(CellProps,bLocalCentroid,LocalCentroid);

% Store vars
if nargin==3
root = varargin{1};
else
    root = '';
end

CellProps.(strcat(root,'Detected')) = bType;
CellProps.(strcat(root,'Area')) = bArea;
CellProps.(strcat(root,'LocalCentroid')) = bLocalCentroid;
CellProps.CellWidth = CellWidth;
CellProps.CellHeight = CellHeight;
CellProps.LocalCentroid = LocalCentroid;
CellProps.(strcat(root,'X')) = BBX;
CellProps.(strcat(root,'Y')) = BBY;
CellProps.(strcat(root,'Centroid')) = BBCentroid;
CellProps.(strcat(root,'Orientation')) = BBOrientation;
CellProps.(strcat(root,'Distance')) = BBDistance;
CellProps.(strcat(root,'EdgeDist')) = BBEdgeDist;
CellProps.(strcat(root,'Polarity')) = BBPolarity;
end

