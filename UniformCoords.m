function [coords] = UniformCoords(xRange,yRange,nX,nY)
%UNIFORMCOORDS Generate uniformly distributed coordinates. 
%   [x,y] = UNIFORMCOORDS(xRange,yRange,nX,nY) generates uniformly
%   distributed points that span the range xRange = [xmin xmax] in x
%   and yRange = [ymin ymax] in y with nX points in x and nY
%   points in Y. Outputs the x and y points of the uniformly
%   spaced points. 

xvec = linspace(xRange(1),xRange(2),nX);
yvec = linspace(yRange(1),yRange(2),nY);

[gx,gy] = meshgrid(xvec,yvec);

coords = [gx(:) gy(:)];
end

