function [CroppedIms] = EllipseCrop(RawIm,EllipseProps)
%ELLIPSECROP Crops elliptical regions from an image. 
%   [CroppedIms] = EllipseCrop(RawIm,EllipseProps) produces separate
%   cropped images of the elliptical regions with properties defined by
%   EllipseProp within the Raw input image. EllipseProps must be a table
%   with variables corresponding to the Centroid, MajorAxisLength,
%   MinorAxisLength and Orientation of the desired ellipse(s). 
%
%   SEE ALSO REGIONPROPS, BWCOMPPROPS, and DRAW_ELLIPSE.
nEllipses = length(EllipseProps.Orientation);

for n = 1:nEllipses

    CroppedIms{n} = EllipseCropSingle(RawIm,EllipseProps(n,:));
end

end

function [CroppedIm] = EllipseCropSingle(RawIm,EllipseProps)
[nrow, ncol, depth] = size(RawIm); 
    
center = EllipseProps.Centroid;
MajorAxis = EllipseProps.MajorAxisLength;
MinorAxis = EllipseProps.MinorAxisLength;
Angle = EllipseProps.Orientation;

mask = draw_ellipse(center(2),center(1),MajorAxis/2,MinorAxis/2,-1*Angle,zeros(nrow,ncol,3),[1 1 1]);
mask = logical(mask);
mask(:,:,2:3) = [];

% CroppedIm = labelSeparate(RawIm,bwlabel(mask),'mask');
CroppedIm = Crop2Mask(RawIm,mask);
end

