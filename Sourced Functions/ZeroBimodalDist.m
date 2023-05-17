function [zeroed] = ZeroBimodalDist(orientation)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

doubleang = orientation*2;
meanang = atan2(sum(sin(doubleang)),sum(cos(doubleang)))/2;

zeroed = orientation-meanang;
end

