function [test,labels,NeighborsMask] = IsNeighbor(MaskA,MaskB,PixDistance,varargin)
%ISNEIGHBOR determines if the connected components in MaskA are neighbors
%of the connected components in MaskB within a distance (PixDistance). 
%   [test,NeighborsMask] = IsNeighbor(MaskA,MaskB,PixDistance) determines 
%   if the connected components in MaskA  are within a distance
%   (PixDistance) of the connected components in MaskB. Outputs a logical
%   vector indicating which of the connected components in MaskA are
%   determined to be neighbors (1) and which are not (0). The set of labels
%   that correlate the test vector to MaskA, and a new mask that consists
%   of only components in MaskA that were determined to be neighbors with
%   the components in MaskB. 
%
%   See also LABELSEPARATE, BWLABEL, and BUILDMASK. 

%% Parse Inputs
p = inputParser;
addRequired(p,'MaskA',@islogical)
addRequired(p,'MaskB',@islogical)
isposInt = @(x) (rem(x,round(x))==0)&x>0; % Confirm PixDistance is a positive integer. 
addRequired(p,'PixDistance',isposInt);
addOptional(p,'Invert','',@ischar);

parse(p,MaskA,MaskB,PixDistance,varargin{:});
doinvert = p.Results.Invert;

if ismember(varargin,'flip')
    tMaskA = MaskA;
    tMaskB = MaskB;
    
    MaskB = tMaskA;
    MaskA = tMaskB;
end

% check inputs
[ax,ay]=size(MaskA);
[bx,by]=size(MaskB);

if (ax~=bx)||(ay~=by)
    error('Mask A and Mask B must be the same size')
end

%% Dilate Mask B
dMaskB = logical(imdilate(MaskB,strel('disk',PixDistance)));

%% Isolate components of MaskA
[sepMaskA,labels] = SepMaskComps(MaskA);

%% Multiply seperate Masks by B to look for overlap
ncompsA = length(sepMaskA);
overPix = zeros(ncompsA,1);
for k=1:ncompsA
    MultMask = sepMaskA{k}.*dMaskB;
    overPix(k) = sum(MultMask(:));
end

% identify components in MaskA that had no overlaps. 
test = overPix>0;
labelIDs = (1:ncompsA)';

keepComps = labelIDs(test);
keepBW = ismember(labels,keepComps);

if ismember(varargin,'invert')
    NeighborsMask = MaskA;
    NeighborsMask(keepBW)=0;
else
    NeighborsMask = keepBW;
end

end

