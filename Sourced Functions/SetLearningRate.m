function [LearningRate] = SetLearningRate(initRate,type,varargin)
%LEARNINGRATE Update Learning Rate for Machine Learning. 
%   LearningRate = SETLEARNINGRATE(nthRate,'Time-Based','decay',d,'iteration',n)
%   Update the Learning Rate using a time-based schedule with decay
%   parameter d, at iteration n. The learning rate (nthRate) from the
%   previous time step (or the initial learning rate) should be passed to
%   this function. 
%
%   LearningRate = SETLEARNINGRATE(InitRate,'Step-Based','decay',d,'droprate',r,'iteration',n)
%   Update the Learning Rate using a step-based schedule with initial
%   learning rate InitRate, drop rate (r), decay (change at each drop, d),
%   at iteration (n). 
%
%   Defaults: Iteration, decay, drop rate, and iteration do not have to be
%   specified. The default values for each of these are:
%   Iteration = 1
%   DropRate = 1
%   Decay = 1.
%
%   See also UPDATEPARAMS.
p = inputParser;

addRequired(p,'initRate',@isnumeric);
checkType = @(x) any(validatestring(x,{'Time-Based','Step-Based'}));
addRequired(p,'type',checkType);
addOptional(p,'decay',1,@isnumeric);

% input params if type is time-based
addOptional(p,'iteration',1,@isnumeric);

% input params if type is step-based
addOptional(p,'droprate',1,@isnumeric);

parse(p,initRate,type,varargin{:});

decay = p.Results.decay;
iteration = p.Results.iteration;
droprate = p.Results.droprate;

if iteration==1
    warning('Current iteration unspecified. Assuming iteration=1.') 
end

%% Compute Learning Rate
switch type
    case 'Time-Based'
        LearningRate = initRate/(1+decay*iteration);
    case 'Step-Based'
        if decay>=1||decay<=0
            error('For step based schedules decay should be set to a value between 0 and 1')
        end
        LearningRate = initRate*(decay^(floor((1+iteration)/droprate)));
end

end

