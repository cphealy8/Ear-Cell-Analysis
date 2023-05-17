function [refMagnitude,refAngle,aveX,aveY] = pt2ptInfluenceDev(respPts,refPts)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

pt2ptDist = pairdist(respPts,refPts);
pt2ptAng = pairangle2D(respPts,refPts); 

distSquare = pt2ptDist.^2;
xcomps = cosd(pt2ptAng)./distSquare;
ycomps = sind(pt2ptAng)./distSquare;

% distSquare = exp(-0.2.*pt2ptDist);
% xcomps = cosd(pt2ptAng).*distSquare;
% ycomps = sind(pt2ptAng).*distSquare;

xcomps(xcomps==Inf)=0;
ycomps(ycomps==Inf)=0;

aveX = mean(xcomps,2,'omitnan');
aveY = mean(ycomps,2,'omitnan');

refAngle = atan2d(aveY,aveX);
refMagnitude = sqrt(aveX.^2+aveY.^2);
end

