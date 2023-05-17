function [test] = IsOnBoundary(FeaturePix,BoundPix)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
numFeats = length(FeaturePix);

for i=1:numFeats
    check(i) = sum(ismember(FeaturePix{i},BoundPix));

end
test = check>0;
end

