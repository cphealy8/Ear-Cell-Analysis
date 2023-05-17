function [meanAngK,maxAngK,minAngK,AngKSims] = AngleK_Env(scales,vecA,alpha,varargin)
%ANGLEK_Env Compute significance envelopes for AngleK statistic
%   Detailed explanation goes here
%% Parse inputs
p = inputParser;
addRequired(p,'scales',@isnumeric)
addRequired(p,'vecA',@isstruct)
addRequired(p,'alpha',@isnumeric)
addParameter(p,'vecB',[])
validSims = {'none','random','shuffle'};
checkSims = @(x) any(validatestring(x,validSims));
addParameter(p,'AngleSim','random',checkSims);
addParameter(p,'OriginSim','none',checkSims);

parse(p,scales,vecA,alpha,varargin{:});

vecB = p.Results.vecB;
AngleSim = p.Results.AngleSim;
OriginSim = p.Results.OriginSim;

%%
nsims = round((2/alpha))-1;

if isempty(vecB)
    for k=1:nsims
        % randomize angle/origin as specified
        vecA = simulateVec(vecA,AngleSim,OriginSim);
        
        % compute angle K with randomized angle
        AngK(k,:) = AngleK(scales,vecA);
    end
elseif ~isempty(vecB)
    for k = 1:nsims
        % randomize angles
        vecA = simulateVec(vecA,AngleSim,OriginSim);
        vecB = simulateVec(vecB,AngleSim,OriginSim);
        
        AngK(k,:) = AngleK(scales,vecA,vecB);
    end
end

meanAngK = mean(AngK);
maxAngK = max(AngK);
minAngK = min(AngK);
end

function vec = simulateVec(vec,AngleSim,OriginSim)
        if strcmp(AngleSim,'random')
            vec.angle = randAngle(vec.angle);
        elseif strcmp(AngleSim,'shuffle')
            vec.angle = shuffleVec(vec.angle);
        end
        
        if strcmp(OriginSim,'random')
            vec.origin = randOrig(vec.origin);
        end
end


function [shuffled] = shuffleVec(vec)
    shuffled = vec(randperm(length(vec)));
end

function [randang] = randAngle(vec)
    randang = rand(length(vec),1)*2*pi-pi;
end

function [randorig] = randOrig(origins)
    [mins] = min(origins);
    [maxs] = max(origins);
    
    n = length(origins);
    
    randorig = rand(n,2).*[(maxs(1)-mins(1)) (maxs(2)-mins(2))]+mins;
end



