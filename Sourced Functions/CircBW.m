function [BW] = CircBW(rez)
%CIRCBW Generate a binary image of a circle with resolution Rez by Rez
%   Detailed explanation goes here
imageSizeX = rez;
imageSizeY = imageSizeX;
[columnsInImage,rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = rez/2;
centerY = centerX;
radius = centerX;
BW = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
end

