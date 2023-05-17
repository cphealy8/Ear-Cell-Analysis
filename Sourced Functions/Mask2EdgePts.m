function [EdgePts,imEdge] = Mask2EdgePts(Mask,varargin)
%MASK2EDGEPTS Convert mask to edge points
%   Detailed explanation goes here
%% parse
p = inputParser;
addRequired(p,'Mask',@islogical);
addParameter(p,'OmitBounds',true,@islogical)

parse(p,Mask,varargin{:});
OmitBounds = p.Results.OmitBounds;

%%
imEdge = bwmorph(Mask,'remove');

if OmitBounds
% Delete boundary pixels
imEdge(:,1) = 0;
imEdge(1,:) = 0;
imEdge(:,end) = 0;
imEdge(end,:) = 0;
end

% convert pixel boundary to points
EdgePts = pix2pts(imEdge);

end

