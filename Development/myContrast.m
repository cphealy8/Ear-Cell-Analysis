function [outputArg1,outputArg2] = myContrast(im,range)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


if isa(im,'uint8')
    maxI = 255;
    minI = 0;
else
    error('Input must be an image of the type uint8')
end

minPix = range(1);
maxPix = range(2);

lowPix = im<minPix;
highPix = im>maxPix;

pixRange


end

