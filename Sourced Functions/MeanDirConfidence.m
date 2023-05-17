function [MeanDir,ConfidenceInt] = MeanDirConfidence(angles,alpha)
%MEANDIRCONFIDENCE Compute the mean direction and confidence interval for
%the input angles at the specified alpha value. 
%   Detailed explanation goes here

% Inputs needed
n = length(angles);
zalpha = abs(norminv(alpha/2));
[R,MeanDir] = ResLength(angles,1);

H = (1/n)*(cosd(2*MeanDir)*sum(cosd(2*angles))+sind(2*MeanDir)*sum(sind(2*angles)));
W = (1-H)/(4*n*(R^2));

ConfidenceInt = asind(zalpha*sqrt(2*W));
end

