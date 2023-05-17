function [IMap] = InfluenceMap(mask,varargin)
%INFLUENCEMAP generate a map of the influence of connected components in a
%mapped image according to different mechanisms.
%   Detailed explanation goes here

%% Parse
p = inputParser;
addRequired(p,'mask',@islogical);
checkType = @(x) any(validatestring(x,{'Euclidean','Reciprocal','Exponential'}));
addParameter(p,'Type','Euclidean',checkType);
addParameter(p,'Magnitude',2,@isnumeric);

checkDownsample = @(x) x>=0 & x<=1;
addParameter(p,'Downsample',1,checkDownsample);
parse(p,mask,varargin{:})

Type = p.Results.Type;
Magnitude = p.Results.Magnitude;
DownSample = p.Results.Downsample;

%% 
% Resize mask if requested
if DownSample<1
    dilmask = imdilate(mask,strel('disk',round(0.5/DownSample)));
    mask = imresize(dilmask,DownSample);
end

pixID = find(mask==true);
npix = length(pixID);


blankMap = false(size(mask));

% Get Distance Maps
if strcmp('Reciprocal',Type)|strcmp('Exponential',Type);
    if npix>200
        warning('Image resolution is large. To improve computation time specify downsampling mask with imresize.m before passing to InfluenceMap.m');
    end

    for n=1:npix
        pixmap = blankMap;
        pixmap(pixID(n))=true;
        dmap(:,:,n) = bwdist(pixmap);
    end
end

switch Type
    case 'Euclidean'
        IMap = bwdistInv(mask);
    case 'Reciprocal'
        IMap = mean(1./(dmap.^(1/Magnitude)),3);
    case 'Exponential'
        IMap = mean(exp(-(10^-Magnitude).*dmap),3);
end

end

