function [imageOut] = ImagePreProcess(imageIn,scale)
%IMAGEPREPROCESS contrast, denoise, and apply illumination correction
%   Detailed explanation goes here

% contrast
imK{1} = imadjust(imageIn);
% denoise
kernsz = ceil(scale/2);
imK{2} = medfilt2(imK{1},kernsz*[1 1],'symmetric');
% correct uneven illumination
imK{3} = imflatfield(imK{2},scale*3);
% contrast
imageOut = imadjust(imK{3});
end

