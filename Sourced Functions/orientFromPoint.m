function [poleX,poleY,poleCentroid,objOrientation,pole2ctrDistance,poleEdgeDist,objPolarity] = orientFromPoint(CellProps,poleLocalCentroid,objLocalCentroid)


poleX = poleLocalCentroid(:,1)-objLocalCentroid(:,1);
poleY =  poleLocalCentroid(:,2)-objLocalCentroid(:,2);

poleCentroid = CellProps.Centroid+[poleX poleY];

objOrientation = atan2d(poleY,poleX);
pole2ctrDistance = sqrt((poleX).^2+(poleY).^2);

% Normalize
a = CellProps.MajorAxisLength/2;
b = CellProps.MinorAxisLength/2;
alpha = objOrientation;
theta = -CellProps.EllipseOrientation;
poleEdgeDist = (a.*b)./sqrt((b.^2-a.^2).*cosd(alpha-theta).^2+a.^2);
objPolarity = pole2ctrDistance./poleEdgeDist;
end