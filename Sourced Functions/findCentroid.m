function [centroid,ncomps] = findCentroid(BW)
%FINDCENTROID find the centroid(s) and number of components in a binary image.
%   Detailed explanation goes here

if sum(BW(:))~=0
props = regionprops(BW,'centroid');
centroid = cat(1,props.Centroid);
[ncomps,~]= size(centroid);
else
    centroid = [NaN NaN];
    ncomps = 0;
end

end