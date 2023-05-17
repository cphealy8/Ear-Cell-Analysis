function [circleIm] = drawBWcircs(imRez,centers,radii)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[columnsInImage, rowsInImage] = meshgrid(1:imRez(2), 1:imRez(1));

fW= waitbar(0,'Circularizing...');
nr = length(radii);
sumCirc = zeros(imRez(1),imRez(2));

for k =1:length(radii)
    centerX = centers(k,1);
    centerY = centers(k,2);
    radius = radii(k);
    
    circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
    
sumCirc = sumCirc+circlePixels;
    waitbar(k/nr,fW,'Circularizing...')
    
end
close(fW)

% sumcircs = sum(circlePixels,3);
circleIm = sumCirc>0;
end

