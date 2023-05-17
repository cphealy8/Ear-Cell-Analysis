function [L] = imWatershed(bwIm)
%IMWATERSHED Compute the watershed transform of a bitmap image.
%   [L] = IMWATERSHED(bwIm) computes the watershed transformed image L from
%   the input bitmap image bwIm. 

% Compute the distance transform of the complement of the binary image.
D = bwdist(~bwIm);

% Complement tghe distance transform, and force pixels that don't belong to
% the objects to be at Inf.
D = -D;
D(~bwIm) = Inf;

% Compute the watershed transform. 
L = watershed(D);
L(~bwIm) = 0;

L = logical(L);
end