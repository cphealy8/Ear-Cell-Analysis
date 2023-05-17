function [imLevel] = CorrectIllumination(im,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
p = inputParser;

szVec = size(im); 


addOptional(p,'radius',round(.15*min(szVec(1:2))),@isnumeric);
parse(p,im,varargin{:})

% Contrast the divided image.
% Saturating the bottom 1% and the top 1% of all pixels values.
radius = p.Results.radius;
if nargin==1
    radius = round(.15*min(szVec(1:2)));
end

if length(szVec)==3
    for k = 1:szVec(3)
        imBlur(:,:,k) = imgaussfilt(im(:,:,k),radius);
        imEven(:,:,k) = double(im(:,:,k))./double(imBlur(:,:,k));
        imtemp = imEven(:,:,k);
        lowThresh(1,1,k) = prctile(imtemp(:),1);
        highThresh(1,1,k) = prctile(imtemp(:),99);
        
        imLevel(:,:,k) = uint8(255*(imEven(:,:,k)-lowThresh(1,1,k))/(highThresh(1,1,k)-lowThresh(1,1,k)));
    end
else
    imBlur = imgaussfilt(im,radius);
    imEven = double(im)./double(imBlur);
    lowThresh = prctile(imEven(:),1);
    highThresh = prctile(imEven(:),99);
    imLevel = uint8(255*(imEven-lowThresh)/(highThresh-lowThresh));
end

end

