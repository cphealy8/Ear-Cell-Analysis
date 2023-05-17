function [im] = ResizeOpen(filename,outputSize,type)
%RESIZEOPEN reads an image and resizes it to the size specified below. 
%   RESIZEOPEN is a custom reading function for the IMAGEDATASTORE and
%   PIXELLABELDATASTORE functions.

im = imread(filename);

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

switch type
    case 'image'
        im = uint8(im);
    case 'pixellabel'
        im = categorical(im);
end
end

