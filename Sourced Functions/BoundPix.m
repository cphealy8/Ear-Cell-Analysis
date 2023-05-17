function [IDs,map] = BoundPix(im)
%BOUNDPIX Find boundary pixels in an image
%   Detailed explanation goes here

[l,w,h] = size(im);
map = zeros(l,w);

map(1,:) = 1;
map(:,end) = 1;
map(:,1) = 1;
map(end,:) = 1;

IDs = find(map==1);
end

