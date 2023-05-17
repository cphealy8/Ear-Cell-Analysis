function [AngleK,alignment] = AngleK(scales,vecA,varargin)
%ANGLEK Compute the angleK statistic given a vector field and set of
%angles. 
%   Detailed explanation goes here.

if max(vecA.angle)>2*pi
    warning('Angle exceeding 2{\pi} detected. Angle K expects angles in radians.')
end

%% Compute unit vector components
    [xcompA,ycompA] = ComputeComponents(vecA.magnitude,vecA.angle,'unit');

%% Compute the pairwise distance matrix between the vector origins
if nargin==2
    Distances = pairdist(vecA.origin,vecA.origin);
elseif nargin==3
    vecB = varargin{1};
    Distances = pairdist(vecA.origin,vecB.origin);
    [xcompB,ycompB] = ComputeComponents(vecB.magnitude,vecB.angle,'unit');
else
    error('Incorrect number of arguments')
end

%% Local Alignment
for r=1:length(scales)
scale = scales(r); 

% This function can be used to compute the alignment of each feature with
% respect to neighbors at a given scale. 
if nargin == 2
    alignment(:,r) = LocalAlignment(scale,Distances,[xcompA ycompA]);
elseif nargin ==3
    alignment(:,r) = LocalAlignment(scale,Distances,[xcompA ycompA],[xcompB ycompB]);
end

end
%% Average Alignment

AngleK = mean(alignment,'omitnan');
end

