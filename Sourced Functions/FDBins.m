function [nbins,binwidth] = FDBins(data)
%FDBins calculate the number of bins following the Freedman-Diaconis rule
%   Detailed explanation goes here
%% Set no. of bins
% Get parameters to calculate Freedman-Diaconis
data(isnan(data))=[]; % remove nans
nObservations = length(data);
IQR = iqr(data);
maxObs = max(data);
minObs = min(data);

% Calculate
binwidth = 2*IQR*(nObservations^(-1/3));
nbins = (maxObs-minObs)/binwidth;
end

