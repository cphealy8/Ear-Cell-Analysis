function [] = VectorOverlayMap(ImDat,props,splitvar,varargin)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

%% parse inputs
p =inputParser;
addRequired(p,'ImDat')
addRequired(p,'props',@istable);
checkvar = @(x) ischar(x)|isstring(x);
addRequired(p,'splitvar',checkvar);
addParameter(p,'legendOn',true,@islogical);
addParameter(p,'linewidth',2,@isnumeric);
addParameter(p,'MarkerSize',6,@isnumeric);

addParameter(p,'splitcolors',[],@isnumeric);

parse(p,ImDat,props,splitvar,varargin{:});

splitcolors = p.Results.splitcolors;
legendOn = p.Results.legendOn;
lwd = p.Results.linewidth;
MkSz = p.Results.MarkerSize;

%% split types
[TypeID,ntypes,types] = GetTypeIDs(props,splitvar);

%% handle colors
if isempty(splitcolors)
    splitcolors = MyBrewerMap('div','Spectral',ntypes);
else
    [colorrows,colorcols] = size(splitcolors);
    if colorrows~=ntypes
        error('Number of colors in custom color map must equal the number of unique values in the splitting variable')
    end
end
%%
imshow(ImDat.RAW);
hold on;

for k=1:ntypes
    curID = TypeID{k};
plot(props.PBCentroid(curID,1),props.PBCentroid(curID,2),'o',...
       'color',splitcolors(k,:),'LineWidth',lwd,...
       'MarkerSize',MkSz)
quiver(props.Center(curID,1),props.Center(curID,2),...
       props.PBX(curID),props.PBY(curID),0,...
       'LineWidth',lwd,'Color',splitcolors(k,:),'ShowArrowHead','off',...
       'Marker','o','MarkerSize',MkSz,...
       'MarkerFaceColor',splitcolors(k,:))
end
if legendOn
legendentries = strcat(repelem(types,ntypes),...
                    repmat({' Polar Body',' Center'}',[ntypes 1]));
legend(legendentries,'Location','SouthOutside','Orientation','horizontal')
end

end

