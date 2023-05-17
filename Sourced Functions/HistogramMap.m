function [HistMap] = HistogramMap(data,varargin)
%HISTOGRAMMAP Convert a histogram into a heatmap. 
%   Detailed explanation goes here

%% Parse Inputs
p = inputParser;

addRequired(p,'data',@isnumeric);
addParameter(p,'nbins',[],@isnumeric);
addParameter(p,'datalims',[],@isnumeric);
addParameter(p,'x',[],@isnumeric);
parse(p,data,varargin{:});

nbins = p.Results.nbins;
datalims = p.Results.datalims;
x = p.Results.x;

[nrow,ncol]=size(data);

%% determine default number of bins and bin edges
if isempty(nbins)
    for k=1:ncol
        numbins = FDBins(data(:,k));
        if isempty(numbins)
            numbins = NaN;
        end
        [kbins(k)] = numbins;
    end
    nbins = round(mean(kbins,'omitnan'));
end

if isempty(datalims)
    mindata = min(data(:));
    maxdata = max(data(:));
else
    mindata = datalims(1);
    maxdata = datalims(2);
end

% find binedges
binEdges = linspace(mindata,maxdata,nbins+1);
%% Get histcounts
for m=1:ncol
    [HistMap(:,m)] = histcounts(data(:,m),binEdges,'Normalization','Probability');
end

%% Plot
if isempty(x)
    x=1:ncol;
end
y = binEdges(1:end-1)+diff(binEdges)/2;
imagesc(x,y,HistMap)
axis xy
cax = colorbar;
hold on
plot(x,mean(data,'omitnan'),'-r','LineWidth',2)
hold off

ylabel(cax,'Probability')
end

