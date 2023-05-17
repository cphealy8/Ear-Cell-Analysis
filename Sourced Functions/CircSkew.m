function [Skewness] = CircSkew(angles)
%CIRCSKEW Compute the circular skewness of the input angles
%   Detailed explanation goes here
[R1,T1] = ResLength(angles,1);
[R2,T2] = ResLength(angles,2);

Skewness = (R2*sind(T2-2*T1))/((1-R1)^(3/2));
end

