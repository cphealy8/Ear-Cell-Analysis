function [ImDat] = RefineCellMasks(ImDat,varargin)
%REFINECELLMASKS clean up boundaries and isolate the best cells to analyze
%   Detailed explanation goes here
%% Parse inputs
p = inputParser;
addRequired(p,'ImDat');
addParameter(p,'ClearBoundary',false,@islogical);
addParameter(p,'NeighborThresh',0,@isnumeric);

parse(p,ImDat,varargin{:});
ClearBoundary = p.Results.ClearBoundary;
NeighborThresh = p.Results.NeighborThresh;
%% isolate necessary images.
CellBounds = ImDat.CellBoundMask;
HairCells = ImDat.HairCellMask;
SupportCells = ImDat.SupportCellMask;

%%
% Thicken cell boundary then subtract from mask images. 
sdisk = strel('disk',1); % Define dilation kernel
CellBounds = imdilate(CellBounds,sdisk); % thicken cell boundary
HairCells = HairCells-CellBounds;
SupportCells = SupportCells-CellBounds;

% reimpose logical format;
CellBounds(CellBounds<0) = 0;
HairCells(HairCells<0) = 0;
SupportCells(SupportCells<0) = 0;
CellBounds = logical(CellBounds);
HairCells = logical(HairCells);
SupportCells = logical(SupportCells);

% Clear border cells
if ClearBoundary
HairCells = imclearborder(HairCells);
SupportCells = imclearborder(SupportCells);
end

% Filter out support cells that are not neighboring Hair cells. 
if NeighborThresh>0
[~,~,SupportCells] = IsNeighbor(SupportCells,HairCells,NeighborThresh);
end

%% Update ImDat
ImDat.HairCellMask = HairCells;
ImDat.SupportCellMask = SupportCells;
ImDat.CellBoundMask = CellBounds;
end

