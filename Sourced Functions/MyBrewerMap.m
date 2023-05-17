function [ColMap] = MyBrewerMap(ctype,cname,ncolors)
%MyBrewerMap A wrapper for cbrewer. Allows output of a 2-color map. 
%   Detailed explanation goes here
ColMap = cbrewer(ctype,cname,ncolors);
if ncolors==2
    ColMap(2,:) = [];
end
end

