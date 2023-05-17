function [fH,p1,p2] = DblAngPlot(angs,units,nbins)
%DBLANGPLOT displays a histogram of orientations before and after double
%angle transformation. 
%   Author: Connor Healy.
%   
%   Affiliation: Tara Deans' Lab, Dept. of Biomedical Engineering,
%   University of Utah
%
%   SEE ALSO POLARHISTOGRAM, DBLANGTRANSFORM.

dblangs = DblAngTransform(angs,units); 

if strcmp(units,'deg')
    angs = deg2rad(angs);
    dblangs = deg2rad(dblangs);
elseif strcmp(units,'rad')
else
    error('Invalid units. Must be in radians ''rad'' or degrees ''deg''.')
end

subplot(1,2,1)
p1=polarhistogram(angs,nbins);
title('Original')
subplot(1,2,2)
p2=polarhistogram(dblangs,nbins);
title('Double Angle Transformation')
end

