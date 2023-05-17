function [coords] = ClusterCoords(Centers,MaxRadius,nPerCluster,Type)
%ClusterCoords Summary of this function goes here
%   Detailed explanation goes here

nClusts = length(Centers);
cx = [];
cy = [];

for n=1:nClusts
    switch Type
        case 'random'
            randAngle = 2*pi*rand(nPerCluster,1);
            randR = MaxRadius*rand(nPerCluster,1);
        case 'uniform'
            randAngle = linspace(0,2*pi*(1-1/nPerCluster),nPerCluster)';
            randR = MaxRadius;
    end
    cx = [cx; randR.*cos(randAngle)+Centers(n,1)];
    cy = [cy; randR.*sin(randAngle)+Centers(n,2)];
end

coords = [cx cy];
end

