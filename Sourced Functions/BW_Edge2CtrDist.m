function [Edge2CtrMap,EdgeMap,CtrMap] = BW_Edge2CtrDist(BW,varargin)
%BW_EDGE2CTRDIST computes the Edge2Center distance map of a binary image.
%   Detailed explanation goes here
%% parse input
p=inputParser;
addRequired(p,'BW')
addParameter(p,'Normalize',true,@islogical);

parse(p,BW,varargin{:})
Normalize = p.Results.Normalize;

if ~islogical(BW)
    BW = logical(BW);
end

%%
EdgeMap = bwdist(~BW);
[~,~,ctrIm] = BWVisualCenter(BW);
CtrMap = bwdist(ctrIm).*BW;
Edge2CtrMap = CtrMap./(CtrMap+EdgeMap);

if Normalize
[Edge2CtrMap] = NormByBWComp(BW,Edge2CtrMap);
end

end

