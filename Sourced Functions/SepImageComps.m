function [ImDat,props] = SepImageComps(ImDat,varargin)
%SEPIMAGECOMPS separate image into components based upon a binary mask.
%   Detailed explanation goes here

%% Parse inputs
p=inputParser;
addRequired(p,'ImDat',@isstruct);
addParameter(p,'GroupName','',@ischar);
addParameter(p,'ExtraIms',{},@iscell);
addParameter(p,'ExtraNames',{},@iscell);

parse(p,ImDat,varargin{:});

GroupName = p.Results.GroupName;
ExtraIms = p.Results.ExtraIms;
ExtraNames = p.Results.ExtraNames;

%% Separate binary components into individual images.
labelF = ([GroupName 'Labels']);
polF =([GroupName 'PolMap']);

tgtMask = ImDat.([GroupName 'CellMask']);
[imx, imy] = size(tgtMask);

ImDat.(labelF) = bwlabel(tgtMask);
ImDat.(polF) = BW_Edge2CtrDist(tgtMask);


%% Get some parameters of components
% Get Morphological parameters of image mask
props = regionprops('table',ImDat.(labelF),{'Centroid','Area',...
                    'Eccentricity','Perimeter','Solidity','PixelIdxList'});
props.Circularity = (4*pi*props.Area)./(props.Perimeter.^2);
props.Properties.VariableNames(strcmp(props.Properties.VariableNames,'PixelIdxList'))={'PixIDs'};

% Add descriptive parameters
props.ID = (1:height(props))';
props.Type = repmat(string(GroupName),[height(props) 1]);

%% Get separate images.
% Stack Images (this approach lets us only call labelSeparate once!)
ImStack = double(ImDat.RAW); % Add raw image to stack
ImStack(:,:,4) = double(ones(imx,imy)); % Add ones to stack to obtain mask.
ImStack(:,:,5) = double(ImDat.(polF)); % Add polarity map to stack.

% Append extra images if necessary;
if ~isempty(ExtraIms)
    for n=1:length(ExtraIms)
        imtype{n} = class(ExtraIms{n});
        ImStack(:,:,5+n)=double(ExtraIms{n});
    end
end

[Stacks, ~, pixrows, pixcols] =  labelSeparate(ImStack,ImDat.(labelF),'mask');

props.RAW = getLevel(Stacks,1:3,'uint8')';
props.pixrows = pixrows';
props.pixcols = pixcols';
props.ImR =  getLevel(Stacks,1,'uint8')';
props.ImG =  getLevel(Stacks,2,'uint8')';
props.ImB =  getLevel(Stacks,3,'uint8')';
props.Mask = getLevel(Stacks,4,'logical')';
props.PolMap = getLevel(Stacks,5,'double')';

% handle extra images if necessary
if ~isempty(ExtraIms)
    for n=1:length(ExtraIms)
        props.(ExtraNames{n})=getLevel(Stacks,5+n,imtype{n})';
    end
end

%% Compute local centroid
getFirstEntry = @(x) x(1);
props.rowshift = cell2mat(cellfun(getFirstEntry,pixrows,'UniformOutput',false))'-1;
props.colshift = cell2mat(cellfun(getFirstEntry,pixcols,'UniformOutput',false))'-1;
props.LocalCentroid = props.Centroid-[props.colshift props.rowshift];
end

function LevelCell = getLevel(arr,lvl,type)
    % Isolate a specific level of the images stored in the cell array arr
    % and impose a type on the level.
    getlevelcell = @(x) cast(x(:,:,lvl),type);
    LevelCell = cellfun(getlevelcell,arr,'UniformOutput',false);
end
