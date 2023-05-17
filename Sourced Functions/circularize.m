function [circleim] = circularize(im)
%Ellipsify Convert binary components to elliptical approximations
%   Detailed explanation goes here
imRez = size(im);

props = regionprops('table',im,{'Centroid','EquivDiameter'});
props.Orientation = zeros(height(props),1);

% circleim = bwEllipse(imRez,props.Centroid,props.EquivDiameter,props.EquivDiameter,props.Orientation);
circleim = drawBWcircs(imRez,props.Centroid,props.EquivDiameter/2);
end

