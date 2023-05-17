function [combinedXs,saveCDF] = InterpCDFs(x,cdf)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


X = struct2cell(x);
CDF = struct2cell(cdf);
fields = fieldnames(cdf);
nDists = length(X);
% Combine X's
combinedXs = [];
for n = 1:nDists
    combinedXs = consolidateX(combinedXs,X{n});
end

% Interpolate distributions with combined x's
interpType = 'linear';

for n = 1:nDists
    [curX,unqIDs] = unique(X{n});
    curCDF = CDF{n}(unqIDs);
    curField = fields{n};
    intCDF = interp1(curX,curCDF,combinedXs,interpType);
    intCDF(combinedXs<min(curX)) = 0;
    intCDF(combinedXs>max(curX)) = 1;
    saveCDF.(curField) = intCDF;
end


end

function [combinedXs] = consolidateX(x1,x2)
xA = x1(:);
xB = x2(:);

combinedXs = unique([xA;xB]);
end
