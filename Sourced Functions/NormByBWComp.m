function [NormImage] = NormByBWComp(Mask,Image)
%NORMBYBWCOMP Normalize pixels within binary components of mask to between 0 and 1.  
%   Detailed explanation goes here

props = regionprops(Mask,Image,'MaxIntensity','MinIntensity');
mLabel = bwlabel(Mask)+1;
maxI = [0;cat(1,props.MaxIntensity)];
minI = [1; cat(1,props.MinIntensity)];

maxImage = maxI(mLabel);
minImage = minI(mLabel);

NormImage = Mask.*(Image-minImage)./(maxImage-minImage);
end

