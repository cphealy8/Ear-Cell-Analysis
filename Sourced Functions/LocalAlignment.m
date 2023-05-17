function [alignment] = LocalAlignment(radius,distMat,vectorcomps,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Find distances in the distMat less than or equal to radius and not 0 (aka
% the same feature). 
isNeighbor = (distMat<=radius)&(distMat~=0);

% Determine univariate or bivariate input
if nargin == 3
    type = 'univariate';
elseif nargin == 4
    type = 'bivariate';
else
    error('Improper number of inputs')
end

%% Compute Alignment
switch type
    case 'univariate'
        numFeatures = length(vectorcomps);
            for i=1:numFeatures
                a = vectorcomps(i,:); % Set target vector
                Neighbors = isNeighbor(:,i); % find index of u's neighbors.
                numNeighbors = sum(Neighbors);
                
                v = vectorcomps.*Neighbors; % Set Neighbor vectors
                eachAlignment = sum(a.*v,2); % Alignment with each neighbor.
                alignment(i) = sum(eachAlignment,'omitnan')/numNeighbors; % Average alignment overall.
                
            end
    case 'bivariate'
        vectorcompsA = vectorcomps;
        vectorcompsB = varargin{1};
        numFeaturesA = length(vectorcompsA);
        
        for i= 1:numFeaturesA
        a = vectorcompsA(i,:); % Set target vector
        Neighbors = isNeighbor(i,:)'; % find index of a's neighbors.
        numNeighbors = sum(Neighbors);

        b = vectorcompsB.*Neighbors; % Set Neighbor vectors
        eachAlignment = sum(a.*b,2); % Alignment with each neighbor.
        alignment(i) = sum(eachAlignment,'omitnan')/numNeighbors; % Average alignment overall.
        end
end

% Note: An alignment = NaN implies that there were no neighbors within a
% specified radius of the given feature. In other words no alignment can be
% computed because there is nothing to align to. 

alignment = alignment';

end

