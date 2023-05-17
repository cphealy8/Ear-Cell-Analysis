function [] = OrientationVectorOverlay(CellProps,BoundPts,ImDat,varargin)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
p=inputParser;

addRequired(p,'CellProps');
addRequired(p,'BoundPts');
addRequired(p,'ImDat');
addParameter(p,'Scaling','Unit',@ischar);
addParameter(p,'ScaleValue',0.4,@isnumeric);

parse(p,CellProps,BoundPts,ImDat,varargin{:})

Scaling = p.Results.Scaling;
ScaleValue = p.Results.ScaleValue;
%%
figure
imshow(ImDat.RAW);
% imshow(labeloverlay(ImDat.RAW,bwlabel(ImDat.PolarBodies)))

hold on
plot(BoundPts(:,1),BoundPts(:,2),'.w')

% Define a vector field for orientation
cellX = cosd(CellProps.CombinedOrientation);
cellY = sind(CellProps.CombinedOrientation);

if strcmp(Scaling,'Polarity')
    cellX = CellProps.CombinedPolarity.*cellX;
    cellY = CellProps.CombinedPolarity.*cellY;
elseif strcmp(Scaling,'BB')
    cellX = CellProps.BBX;
    cellY = CellProps.BBY;
end

HairCellCentroids = CellProps.Centroid(CellProps.Type=='H',:);
SupportCellCentroids = CellProps.Centroid(CellProps.Type=='S',:);

quiver(HairCellCentroids(:,1),HairCellCentroids(:,2),cellX(CellProps.Type=='H'),cellY(CellProps.Type=='H'),ScaleValue,'Color','r','LineWidth',1.5)
quiver(SupportCellCentroids(:,1),SupportCellCentroids(:,2),cellX(CellProps.Type=='S'),cellY(CellProps.Type=='S'),ScaleValue,'Color','c','LineWidth',1.5)
end

