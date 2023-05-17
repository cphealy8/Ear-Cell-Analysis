function [Variance] = CircVariance(angles)
%CIRCVARIANCE Compute circular variance of input angles.
%   Detailed explanation goes here

R = ResLength(angles,1);
Variance = 1- R;
end

