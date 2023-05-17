function [cellmap] = ModelCellMap(Polarities,Orientations,rez,varargin)
%MODELCELLMAP generate a heatmap showing the average location of a polar
%body in a model cell. 
%   Detailed explanation goes here
%% Parse inputs
p = inputParser;

addRequired(p,'Polarities',@isnumeric);
addRequired(p,'Orientations',@isnumeric);
addRequired(p,'rez',@isnumeric);
addParameter(p,'pbradius',0.5,@isnumeric);
addParameter(p,'crop',true,@islogical);
addParameter(p,'doplot',true,@islogical);
checkKernType = @(x) any(validatestring(x,{'gaussian','circle'}));
addParameter(p,'kernType','circle',checkKernType);

nmaps = length(Polarities);
maps = zeros(rez,rez,nmaps);

parse(p,Polarities,Orientations,rez,varargin{:})

pbradius = p.Results.pbradius;
crop = p.Results.crop;
doplot = p.Results.doplot;
kernType = p.Results.kernType;
%% Fix orientations so they match the histograms
xcomp = cosd(Orientations);
ycomp = sind(Orientations);

Orientations = atan2d(-ycomp,xcomp);

%%

for k=1:nmaps
    if pbradius>0.5
        maps(:,:,k) = PolOriPixPt(Polarities(k),Orientations(k),rez,'pxradius',pbradius,'kernType',kernType);
    else
        maps(:,:,k) = PolOriPixPt(Polarities(k),Orientations(k),rez,'kernType',kernType);
    end
    cellmap = mean(maps,3);
end

% % Get norm map
nrmmap = bwdist(~CircBW(rez));
nrmmap = nrmmap/max(nrmmap(:));


if crop
    CropCirc = CircBW(rez);
    cellmap(~CropCirc) = NaN;
end

if doplot
    pax = pcolor(cellmap);
    pax.EdgeColor = 'none';
    hold on
    circang = linspace(0,2*pi,100);
    plot((rez/2)*cos(circang)+(rez/2)+0.5,(rez/2)*sin(circang)+(rez/2)+0.5,'-k','LineWidth',3);
    axis equal
    axis tight
%     annotation('ellipse',ax.Position)
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    
end

end
