function [dblAngs] = DblAngTransform(angles,units)
%DBLANGTRANFORM perform double angle transformation. 
%   The double angle transformation is used to combine the modes of
%   diametrically bi-modal circular distributions prior to additional
%   analyses such as computation of the mean/mode direction, and
%   statistical analyses such as the Rayleigh Test for uniformity. 
%
%   [dblAngs] = DBLANGTRANSFORM(angles,'deg') performs the double angle
%   transformation on the set of input angles (angles) specified in degrees 
%   and outputs the transformed angles (dblAngs).
%
%   [dblAngs] = DBLANGTRANSFORM(angles,'rad') performs the double angle
%   transformation on the set of input angles (angles) specified in radians 
%   and outputs the transformed angles (dblAngs). 
%
%   NOTE: Summary statistics of doubled angles must be halved, this
%   includes the mean angle and angular deviation.
%
%   Author: Connor P. Healy
%
%   Affiliation: Tara Deans' Lab, Dept. of Biomedical Engineering,
%   University ot Utah. 
%
%   SEE ALSO KSSTRUCT, RAYLEIGHTEST, RESLENGTH. 

if strcmp(units,'deg')
elseif strcmp(units,'rad')
    angles = angles*360/(2*pi);
else
    error('Invalid unit type. Must be in degrees ''deg'' or radians ''rad''.')
end

angles = wrapTo360(angles);

dblAngs = angles*2;

gtAngs = dblAngs>=360;

dblAngs(gtAngs) = dblAngs(gtAngs)-360;

% If converted previously, convert back.
if strcmp(units,'rad')
    dblAngs = dblAngs*2*pi/360;
end


end

