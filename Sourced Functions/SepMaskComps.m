function [SepComps,labels] = SepMaskComps(Mask)
%SEPMASKCOMPS Seperate connected components in a binary mask. 
%   Detailed explanation goes here
%%
labels = bwlabel(Mask);
ncomps = max(labels(:));

SepComps = cell(ncomps,1);

for k = 1:ncomps
    SepComps{k} = labels==k;
end

end