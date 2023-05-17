function [Dispersion] = CircDispersion(angles)
%CIRCDISPERSION Compute the circular dispersion of the input angles.
%   Detailed explanation goes here
R1 = ResLength(angles,1);
[~,T2,~,~] = ResLength(angles,2);

Dispersion = (1-T2)/(2*R1^2);
end

