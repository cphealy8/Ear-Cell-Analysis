function [imShed] = imWatershed(imIn)
%IMWATERSHED Apply a watershedding algorithm to the input image.
%   Detailed explanation goes here
D = -bwdist(~imIn);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);

imShed = imIn;
imShed(Ld2==0) = 0;
imShed = ~imShed;
end

