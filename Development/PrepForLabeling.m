function [imOut] = PrepForLabeling(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


% Load the image.
H = imageLoad;
RAW = H.Image;
szVec = size(RAW);

p = inputParser;
addOptional(p,'Level',0,@isnumeric);
addOptional(p,'Resize',1,@isnumeric);

parse(p,varargin{:})

if p.Results.Level==0
    imLevel=RAW;
else
    imLevel = CorrectIllumination(RAW,'radius',p.Results.Level);
end

if p.Results.Resize==1
    imOut = imLevel;
else
    imOut = imresize(imLevel,p.Results.Resize);
end

end