function [] = DataMapArray(ImDat,props,var,splitvar,varargin)
%DATAMAPARRAY Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;
addRequired(p,'ImDat');
addRequired(p,'props');
addRequired(p,'var');
addRequired(p,'splitvar');
addParameter(p,'cmap','parula');
addParameter(p,'varlims',[]);

parse(p,ImDat,props,var,splitvar,varargin{:});

cmap = p.Results.cmap;
varlims = p.Results.varlims;
%%
[TypeID,ntypes,types] = GetTypeIDs(props,splitvar);

%%
for k = 1:ntypes
    figure
    maskname = strcat('R',types{k},'CellMask');
    [datmap,fH,axH] = DataMap(ImDat.(maskname),...
                      props.(var)(TypeID{k}));
    daspect([1 1 1])
    cax=colorbar;
    colormap(cmap)
    ylabel(cax,var)
    if ~isempty(varlims)
        caxis(varlims)
    end
    title(types{k})
end

end

