function [num] = numBWComps(BW)
%NUMBWCOMPS get number of connected components in binary imnage
%   Detailed explanation goes here
cc = bwconncomp(BW);
num = cc.NumObjects;
end

