function [bestbins,binEdges] = GetBinsFromProps(Props,field,varargin)
%GETBINSFROMPROPS Get best number of bins for table variable using the
%freedman-diaconis rule. 
%   bestbins = GetBinsFromProps(PropsTable,'variablename') estimates the
%   best number of bins for a histogram of the values stored in the
%   'variablename' field. 
%
%   bestbins =
%   GetBinsFromProps(PropsTable,'variablename','split','splitvariable')
%   First split the variable name based upon another categorical variable
%   in the PropsTable with name 'splitvariable'. Find best number of bins
%   for the split groups and average the output for best bins. 
%% parse
p = inputParser;
addRequired(p,'Props',@istable);
checkfield = @(x) ischar(x)|isstring(x);
addRequired(p,'field',checkfield);
addParameter(p,'split',[],checkfield);

parse(p,Props,field,varargin{:})

split = p.Results.split;

%%
if ~isempty(split)
    [TypeID,ntypes] = GetTypeIDs(Props,(split));
    for k =1:ntypes
        nBins(k) = ceil(FDBins(Props.(field)(TypeID{k})));
        minVal(k) = min(Props.(field)(TypeID{k}));
        maxVal(k) = max(Props.(field)(TypeID{k}));
    end
    bestbins = round(mean(nBins));
else
    bestbins = ceil(FDBins(Props.(field)));
end

binEdges = linspace(min(Props.(field)),max(Props.(field)),bestbins+1);    

end

