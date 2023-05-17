function [zeroed] = ZeroCircularDist(angles,varargin)
%UNTITLED4 Sets the mean direction of a circular distribution to zero, but
%only if it has a mean direction according to the Rayleigh Test for
%uniformity. RADIANS ONLY
%   Detailed explanation goes here

p = inputParser;
addRequired(p,'angles',@isnumeric);
addOptional(p,'modality','unimodal',@ischar)

parse(p,angles,varargin{:});

modality = p.Results.modality;

%%
switch modality
    case 'bimodal'
        doubleang = DblAngTransform(angles,'rad');
        pval=RayleighTest(doubleang*180/pi);
        meanang = atan2(sum(sin(doubleang)),sum(cos(doubleang)))/2;
    case 'unimodal'
        pval=RayleighTest(angles*180/pi);
        meanang = atan2(sum(sin(angles)),sum(cos(angles)));
    otherwise
        error('invalid modality type. Must be bimodal or unimodal');
end
if pval<0.05
    zeroed = angles-meanang;
else
    zeroed = angles;
    warning('Mean angle not detected. Distribution is uniform')
end

end

