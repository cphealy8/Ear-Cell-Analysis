function [datmap,axHandle,labels] = DataMap(bwIm,stat,varargin)
%Color labels according to an input statistic
%   Detailed explanation goes here
%% parse
p = inputParser;
addRequired(p,'bwIm',@islogical)
addRequired(p,'stat',@isnumeric)
addParameter(p,'Display',true,@islogical);
addParameter(p,'BlurType','none',@ischar);
addParameter(p,'BlurValue',10,@isnumeric);

parse(p,bwIm,stat,varargin{:});

DoDisplay = p.Results.Display;
BlurType = p.Results.BlurType;
BlurValue = p.Results.BlurValue;
%%
[labels, n] = bwlabel(bwIm);

if n~=length(stat)
    error('Length of input data vector must be equal to the number of connected objects found in bwIm')
end

datmap = labels;
datmap(datmap==0) = NaN;
for k=1:n
    datmap(labels==k) = stat(k);
end

% Optional blurring
if ~strcmp(BlurType,'none')
    if strcmp(BlurType,'Gaussian')
        imFilter = fspecial('gaussian',BlurValue,BlurValue);
    elseif strcmp(BlurType,'Disk')
        imFilter = fspecial('disk',BlurValue);
    else
        error('Invalid filter type')
    end
    datmap = nanconv(datmap,imFilter,'edge');
end

% figHandle = figure;
if DoDisplay
    axHandle = pcolor(flipud(datmap));
    set(axHandle, 'EdgeColor', 'none')
    daspect([1 1 1])
else
    axHandle = [];
end

end