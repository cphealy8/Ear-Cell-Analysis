function [Kurtosis] = CircKurtosis(angles)
%CIRCKURTOSIS Compute the circular kurtosis of the input angles
%   Detailed explanation goes here
[R1,T1] = ResLength(angles,1);
[R2,T2] = ResLength(angles,2);

Kurtosis = (R2*cosd(T2-2*T1)-R1^4)./((1-R1)^2);
end

