function [DI] = bwdistInv(BW)
%BWDISTINV Inverse distance transform of binary image.
%   Detailed explanation goes here
distmap = bwdist(BW);
DI = max(distmap(:))-distmap;
end

