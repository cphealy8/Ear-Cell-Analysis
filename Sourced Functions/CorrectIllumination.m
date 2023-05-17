function [correctedIm] = CorrectIllumination(im,sigma)
%CORRECTILLUMINATION correct uneven image illumination using a gaussian
%filter with standard deviation sigma. 
%   Detailed explanation goes here

unevenIllum = imgaussfilt(im,sigma);
correctedIm = PhotoFilter(im,iminvert(unevenIllum),'hardlight');
end

