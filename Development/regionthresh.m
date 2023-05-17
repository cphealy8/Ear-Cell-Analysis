function [bwOut] = regionthresh(bwIn,property,thresholds)
%REGIONTHRESH Threshold components of morphological image by their
%morophological properties.
%   REGIONTHRESH omits components from a binary image (bwIn) based on their
%   morphological property (property) that falls outside of the range
%   specified by thresholds (a 2 element vector specifying the mininum and
%   maximum of the range). 
%
%   Valid Inputs for property: 'Area', 'ConvexArea', 'Eccentricity',
%   'EquivDiameter', 'Extent', 'FilledArea', 'MajorAxisLength',
%   'MinorAxisLength', 'Orientation', 'Perimeter', and 'Solidity'. See
%   documentation on REGIONPROPS for descriptions of each of these. 

% Obtain requested morphological property
statStruct = regionprops(bwIn,property);
stats = vertcat(statStruct.(property));

% Label the image
[LabIm,nComps] = bwlabel(bwIn);
LabVec = (1:nComps)';

% Omit components that fall outside the specified thresholds. 
include = LabVec((stats>=thresholds(1) & stats<=thresholds(2)));
bwOut = ismember(LabIm,include);
end

