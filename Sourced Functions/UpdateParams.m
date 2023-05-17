function [POut,randdir] = UpdateParams(PIn,LearningRate,varargin)
%UPDATEPARAMS Summary of this function goes here
%   Detailed explanation goes here
%% parse inputs
p = inputParser;

addRequired(p,'PIn',@isstruct)
addRequired(p,'LearningRate',@isnumeric)
addParameter(p,'RandomizeDir',true,@islogical)
addParameter(p,'RoundType',cell(1),@iscell)
addParameter(p,'ForcePos',false,@islogical)
addParameter(p,'UpdateType',{'add'},@iscell)

parse(p,PIn,LearningRate,varargin{:})
RandomizeDir = p.Results.RandomizeDir;
ForcePos = p.Results.ForcePos;
RoundType = p.Results.RoundType;
UpdateType = p.Results.UpdateType;
%%
valuesIn = cell2mat(struct2cell(PIn));
nvals = length(valuesIn);
fnames = fieldnames(PIn);

% Randomize direction if specified
if length(RandomizeDir)==1
    if RandomizeDir == true
        randdir = datasample([-1 1],nvals)';
    else
        randdir=1;
    end
elseif length(RandomizeDir)==nvals
    randdir = datasample([-1 1],nvals)';
    randdir(~RandomizeDir) = 1;
else
    error('Invalid number of entries in randdir')
end

if length(LearningRate)==1
    LearningRate = ones(nvals,1).*LearningRate;
elseif length(LearningRate)==nvals
else
    error('Invalid number of entries in LearningRate')
end


% Compute updated params
if length(UpdateType)==1
    valuesOut = fUpdateVals(valuesIn,LearningRate,randdir,UpdateType{1});
elseif length(UpdateType)==nvals
    for n =1:nvals
        valuesOut(n) = fUpdateVals(valuesIn(n),LearningRate(n),randdir(n),UpdateType{n});
    end
else
    error('Invalid number of entries in UpdateType')
end

% Round if specified
if length(RoundType)==1
    valuesOut = diffRoundVals(valuesOut,RoundType{1});
    
elseif length(RoundType)==nvals
    for n=1:nvals
        valuesOut(n) = diffRoundVals(valuesOut(n),RoundType{n});
    end
else
    error('Specify the round types for the full set or a single round type')
end

% Force nonnegative values if specified
if length(ForcePos)==1
    if ForcePos
        valuesOut(valuesOut<0) = 0;
    end
elseif length(ForcePos)==nvals
    ForcePos(ForcePos==true&&valuesOut<0) = 0;
end
    

%% Update structure
POut = PIn;
for n=1:nvals
    POut.(fnames{n})= valuesOut(n);
end

end


function updatedVal = fUpdateVals(vals,learningrate,randdir,UpdateType)
switch UpdateType
    case 'add'
        updatedVal = vals.*(1+learningrate.*randdir);
    case 'mult'
        updatedVal = vals.*(learningrate).^(randdir);
end
end

function roundVals = diffRoundVals(vals,RoundType)
    if isempty(RoundType)
        RoundType = 'none';
    end
    
    switch RoundType
        case 'none'
            roundVals = vals;
        case 'round'
            roundVals = round(vals);
        case 'ceil'
            roundVals = ceil(vals);
        case 'floor'
            roundVals = floor(vals);
    end
end

