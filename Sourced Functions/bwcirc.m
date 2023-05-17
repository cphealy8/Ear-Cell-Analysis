function [circs] = bwcirc(bw)
%BWCIRC Circularity of connected components in binary image.
%   Detailed explanation goes here

props = regionprops('table',bw,'Area','Perimeter');

circs = (4*pi*props.Area)./(props.Perimeter.^2);
end

