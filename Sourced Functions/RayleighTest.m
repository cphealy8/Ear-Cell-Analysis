function [pvalue,RayleighsR,z] = RayleighTest(angs)
%RAYLEIGHTEST Test null hypothesis that circular distribution is uniform.
%   [pvalue,Ray,z] = RAYLEIGHTEST(AngleVector) tests whether the
%   distribution of angles (IN DEGREES) in the input AngleVector is significantly
%   different from a uniform distribution. Outputs Rayleighs R,
%   Rayleigh's z (z) which is the test statistic for the Rayleighs Test,
%   and the approximate p-value for the Rayleigh Test Statistic. This
%   approximation is outlined in (Zar, J.H. (1999). Biostatistical Analysis
%   (4th Edition) p. 617. The null hypothesis is rejected if the p-value
%   calculated is less than the specified significance level ? e.g. ?=0.05.
%
%   Author: Connor P. Healy
%
%   Affiliation: Tara Deans Lab, Dept. of Biomedical Engineering,
%   University of Utah
%
%   SEE ALSO KSSTRUCT.


angs(isnan(angs))= [];

if range(angs)<=2*pi
    warning('Angle appears to be in radians. MWWUniformScores only accepts inputs in degrees')
end

ResultantLength = ResLength(angs,1);
nSamps = length(angs);

RayleighsR = nSamps*ResultantLength;
z = nSamps*(ResultantLength^2);

pvalue = exp(sqrt(1+4*nSamps+4*(nSamps^2-RayleighsR^2))-(1+2*nSamps));
end