function [xcomp,ycomp] = ComputeComponents(magnitude,angle,type)
%COMPUTECOMPONENTS Convert 2D vectors in polar form to their components.
%   [xcomp,ycomp] = COMPUTECOMPONENTS(magnitude,angle,'true') computes the
%   true components of the input vectors defined by their magnitude and
%   angle (aka direction) in radians. To use degrees input deg2rad(angle). 
%
%   [xcomp,ycomp] = COMPUTECOMPONENTS(magnitude,angle,'unit') computes the
%   components of the unit vector witht the same angle/direction as the
%   input vectors. 
%
%   Note: Automatic tolerancing is applied to set component values less
%   than 1e-6 to 0.
%
%   SEE ALSO DEG2RAD.

xunit = cos(angle);
yunit = sin(angle);

tolerance = 1e-6;

if strcmp(type,'true')
    xcomp = magnitude.*xunit;
    ycomp = magnitude.*yunit;
elseif strcmp(type,'unit')
    xcomp = xunit;
    ycomp = yunit;
else
    error('Invalid type. type must be ''true'' or ''unit''.')
end

% Apply tolerance
xcomp(abs(xcomp)<tolerance) = 0;
ycomp(abs(ycomp)<tolerance) = 0;
end

