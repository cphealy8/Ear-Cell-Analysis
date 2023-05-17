function [y] = Scale2Range(x,yRange,varargin)
%SCALE2RANGE scale and shift values in x to fit yRange. 
%   Detailed explanation goes here

%% parse inputs
p =inputParser;

addRequired(p,'x',@isnumeric)
checkRange = @(x) isnumeric(x)&(length(x)==2);
addRequired(p,'yRange',checkRange);
addParameter(p,'xRange',[0 0],checkRange);

parse(p,x,yRange,varargin{:})
xRange = p.Results.xRange;
if prod([0 0]==xRange)==1
    xRange = [min(x) max(x)];
end

% force ascending order. 
xRange = sort(xRange);
yRange = sort(yRange);
%% Scale and shift
norm = (x-xRange(1))./(xRange(2)-xRange(1));
y = norm.*(yRange(2)-yRange(1))+yRange(1);
end

