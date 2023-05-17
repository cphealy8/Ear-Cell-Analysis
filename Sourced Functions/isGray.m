function [test] = isGray(im)
%ISGRAY Return true if im is a gray scale image, false otherwise.
%   Detailed explanation goes here

test = (ndims(im)==2)&&(isa(im,'uint8'));

end

