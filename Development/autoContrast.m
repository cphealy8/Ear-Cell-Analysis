function [imOUT] = autoContrast(imIN)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
imIN = double(imIN);
maxI = max(imIN(:));
minI = min(imIN(:));

rangeI = maxI-minI;

imOUT = imIN-minI;
imOUT = round(imOUT*255./rangeI);
imOUT = uint8(imOUT);
end

