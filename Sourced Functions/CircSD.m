function [SD] = CircSD(angles)
%CIRCSD Compute circular standard deviation of input angles
%   Detailed explanation goes here
R = ResLength(angles,1); 
SD = sqrt(-2*log(R));
end

