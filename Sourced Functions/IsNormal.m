function [h,p,ksstat,cv] = IsNormal(x,varargin)
%ISNORMAL returns a test decision for the null hypothesis that the data in
%vector x comes from a normal distribution using a kolmogorov smirnov test.
%
%   Detailed explanation goes here

% Center and scale data so that mean is zero and standard deviation is 1
meanx = mean(x);
sdx = std(x);

x = (x-meanx)./sdx;

% Compute kolmogorov smirnov
[h,p,ksstat,cv] = kstest(x,varargin{:});

end

