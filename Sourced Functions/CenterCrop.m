function [imout] = CenterCrop(im,outputSize)
%CENTERCROP Crops an image uniformly about its center. 
%   [im] = CENTERCROP(im,outputSize) crops the input image to the size
%   specified by outputSize=[height width depth] about the images center.
imSize = size(im);

imctr = round(imSize(1:2)./2);

pxdx = ceil(outputSize(2)/2);
pxdy = ceil(outputSize(1)/2);

minx = imctr(2)-pxdx;
maxx = imctr(2)+pxdx;

miny = imctr(1)-pxdy;
maxy = imctr(1)+pxdy;

% Crop out extra pixels;
im(:,maxx:end,:) = [];
im(maxy:end,:,:) = [];
im(:,1:minx-1,:) = [];
im(1:miny-1,:,:) = [];

if length(imSize)==3
    imout = im(1:outputSize(1),1:outputSize(2),1:outputSize(3));
elseif length(imSize)==2
    imout = im(1:outputSize(1),1:outputSize(2));
end


end

