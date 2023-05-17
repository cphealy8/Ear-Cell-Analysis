function [ellipseim] = ellipsify(im)
%Ellipsify Convert binary components to elliptical approximations
%   Detailed explanation goes here
imRez = size(im);

props = regionprops('table',im,{'Centroid','MajorAxisLength','MinorAxisLength','Orientation'});

ellipseim = bwEllipse(imRez,props.Centroid,props.MajorAxisLength,props.MinorAxisLength,props.Orientation,'off');
end
