function [ha] = HistArray(props,var,splitvar,varargin)
%HISTARRAY Generate histogram array on props.var split upon the
%categorical variable props.splitvar.
%   Detailed explanation goes here

%% Parse inputs
p = inputParser;
addRequired(p,'props',@istable);
checkvar = @(x) ischar(x)|isstring(x);
addRequired(p,'var',checkvar);
addRequired(p,'splitvar',checkvar);
addParameter(p,'splitcolors',[],@isnumeric);
checkTypes = @(x) any(validatestring(x,{'default','polar'}));
addParameter(p,'histtype','default',checkTypes);
addParameter(p,'fixmax',false,@islogical);
addParameter(p,'xlabel','',checkvar);
addParameter(p,'ylabel','Frequency',checkvar);
addParameter(p,'nullpolarity',false,@islogical);

parse(p,props,var,splitvar,varargin{:})
splitcolors = p.Results.splitcolors;
histtype = p.Results.histtype;
fixmax = p.Results.fixmax;
xlab = p.Results.xlabel;
ylab = p.Results.ylabel;
nullpolarity = p.Results.nullpolarity;

%% Get number of types and split data
[TypeID,ntypes,types] = GetTypeIDs(props,splitvar);

%% Handle split colors
if isempty(splitcolors)
    splitcolors = MyBrewerMap('div','Spectral',ntypes);
else
    [colorrows,colorcols] = size(splitcolors);
    if colorrows~=ntypes
        error('Number of colors in custom color map must equal the number of unique values in the splitting variable')
    end
end

%% 
% Setup subplot array; 
[sprows,spcols] = squaresubplotdims(ntypes); % Approximately square array.
ha = tight_subplot(sprows,spcols,0.1,0.1,0.1);

% Find optimal number of bins. 
[nBins,binEdges] = GetBinsFromProps(props,var,'split',splitvar);

if strcmp(histtype,'polar')
    binEdges = linspace(0,2*pi,round(3*nBins)+1);
end

% Find maximum if requested
if fixmax
    for k=1:ntypes
        hcounts = histcounts(props.(var)(TypeID{k}),binEdges,...
            'Normalization','probability');
        maxprobs(k) = max(hcounts);
    end
maxprob = max(maxprobs);
end


%% Plot histograms
switch histtype
    case 'default'
        for k=1:ntypes
            axes(ha(k))
            hh = histogram(props.(var)(TypeID{k}),binEdges);
            hh.Normalization = 'probability';
            hh.FaceColor = splitcolors(k,:);
            hh.FaceAlpha = 0.8;
            title(types(k));
            axis square
            
            if nullpolarity
                [NullP,~,NullX]=NullPolarity(props.(var),length(binEdges)-1,200);
            end
            hold on
            plot(NullX,NullP,'-k');
            hold off
            
            xlabel(xlab)
            ylabel(ylab)
            if fixmax
                ylim([0 maxprob*1.05])
            end
        end
        
    case 'polar'
        if max(props.(var))>2*pi
            warning('Target variable exceeds 2{\pi} and may be in degrees. Values for polarhistograms should be passed in radians.')
        end
        
        for k=1:ntypes
            axes(ha(k))
            ph=polarhistogram(props.(var)(TypeID{k}),binEdges);
            ph.Normalization = 'probability';
            ph.FaceColor = splitcolors(k,:);
            ph.FaceAlpha = 0.8;
            title(types(k));
            
            % Add a line to indicate where uniformity lies
            hold on;
            unifprob = 1./(length(binEdges)-1);
            polarplot(binEdges,ones(1,length(binEdges)).*unifprob,'-k');
            
            if fixmax
                rlim([0 maxprob*1.1])
            end
        end
end

