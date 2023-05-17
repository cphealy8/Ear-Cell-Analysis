function [ha] = ModelCellArray(props,splitvar,varargin)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

%% parse inputs
p = inputParser;
addRequired(p,'props',@istable);
checkvar = @(x) ischar(x)|isstring(x);
addRequired(p,'splitvar',checkvar);

addParameter(p,'cmap',[],@isnumeric);
addParameter(p,'fixmax',false,@islogical);

parse(p,props,splitvar,varargin{:});

cmap = p.Results.cmap;
fixmax = p.Results.fixmax;

%% Get Types and whatnot
[TypeID,ntypes,types] = GetTypeIDs(props,splitvar);

%% Find max if requested.
if fixmax
    for k=1:ntypes
        mcmap(:,:,k) = ModelCellMap(props.Polarity(TypeID{k}),...
            props.NormOrientation(TypeID{k}),...
            100,'pbradius',10,'kernType','circle','doplot',false);

    end
    maxd = round(max(mcmap(:)),1);
end

%% Plot
[sprows,spcols] = squaresubplotdims(ntypes);

ha = tight_subplot(sprows,spcols,0.1,0.05,0.05);
for k = 1:ntypes
    axes(ha(k))
    ModelCellMap(props.Polarity(TypeID{k}),...
        props.NormOrientation(TypeID{k}),...
        100,'pbradius',10,'kernType','circle');
    title(types(k))
    cax = colorbar;
    
    if ~isempty(cmap)
        colormap(cmap)
    end
    
    ylabel(cax,'Polar Body Probability');
    
    if fixmax
        caxis([0 maxd])
    end
end

end

