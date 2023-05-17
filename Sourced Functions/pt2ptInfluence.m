function [refMagnitude,refAngle,aveX,aveY] = pt2ptInfluence(respPts,refPts,TransformType,varargin)
%PT2PTINFLUENCE Compute cumulative influence vector. 
%   PT2PTINFLUENCE computes a vector to represent the cumulative influence
%   of a set of reference points (refPts) upon a set of response points
%   (resPts). A vector is computed for each response point based on it's
%   distance with respect to the reference points (or a transformation of
%   that distance e.g. inverse square, exponential, etc..). PT2PTINFLUENCE
%   outputs the magnitude, angle/direction, and components of the influence
%   vectors for each response point. 
%
%   The type of transformation applied to the distance can be specified
%   with the 'TransformType' input variable. The options are 'None' in
%   which a response points influence vector is defined by the reference
%   point nearest to each response point, 'InverseSquare' in the inverse
%   square of the euclidean distance between the response point and each
%   reference point is taken then averaged to obtain a single average
%   influence vector. 'ExponentialDecay' is similar to 'InverseSquare' except
%   the a negative exponential function is used to define the influences.
%
%   [Magnitude,Angle] = pt2ptInfluence(respPts,refPts,'none') computes the
%   Magnitude and Angle of the reference vectors for each of the response
%   points with respect to the reference points using the minimal 

%% parse inputs
p = inputParser;
defaultTransform = 'none';
validTransforms = {'none','inverse','decay'};
checkTransform = @(x) any(validatestring(x,validTransforms));

defaultStrength = 1;

addRequired(p,'respPts',@isnumeric)
addRequired(p,'refPts',@isnumeric)
addRequired(p,'TransformType',checkTransform)
addOptional(p,'Strength',defaultStrength,@isnumeric)

parse(p,respPts,refPts,TransformType,varargin{:})

%%
pt2ptDist = pairdist(respPts,refPts);
pt2ptAng = pairangle2D(respPts,refPts); 

transformStrength = p.Results.Strength;

switch TransformType
    case 'inverse'
        distSquare = pt2ptDist.^transformStrength;
        xcomps = cosd(pt2ptAng)./distSquare;
        ycomps = sind(pt2ptAng)./distSquare;

        xcomps(xcomps==Inf)=0;
        ycomps(ycomps==Inf)=0;

        aveX = mean(xcomps,2,'omitnan');
        aveY = mean(ycomps,2,'omitnan');
        
        refAngle = atan2d(-aveY,aveX);
        refMagnitude = sqrt(aveX.^2+aveY.^2);
    case 'decay'
        distSquare = exp(-(1/transformStrength).*pt2ptDist);
        xcomps = cosd(pt2ptAng).*distSquare;
        ycomps = sind(pt2ptAng).*distSquare;

        xcomps(xcomps==Inf)=0;
        ycomps(ycomps==Inf)=0;

        aveX = mean(xcomps,2,'omitnan');
        aveY = mean(ycomps,2,'omitnan');
        
        refAngle = atan2d(-aveY,aveX);
        refMagnitude = sqrt(aveX.^2+aveY.^2);
    case 'none'
        [mindists,minI] = min(pt2ptDist');
        refAngle = pt2ptAng(minI)';
        minpts = refPts(minI',:);
        xcomps = minpts(:,1)-respPts(:,1);
        ycomps = minpts(:,2)-respPts(:,2);
        refAngle = atan2d(ycomps,xcomps);
        refMagnitude = ones(length(refAngle),1);
        aveX = xcomps;
        aveY = ycomps;
        
end


end

