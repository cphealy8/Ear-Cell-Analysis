function [freq,xq] = FreqPlot(data,varargin)
%FREQPLOT generate frequency plot of input data. 
%   Detailed explanation goes here
p = inputParser;

addRequired(p,'data',@isnumeric);
addParameter(p,'nbins',[],@isnumeric);
addParameter(p,'omit',[]);
addParameter(p,'interp',0,@isnumeric);

parse(p,data,varargin{:});

nbins = p.Results.nbins;
omit = p.Results.omit;
interp = p.Results.interp;
%%
data = data(:); % Linearize the data if it isn't already.
if ~isempty(omit)
    data(data==omit) =[];
end

if isempty(nbins)
    [y,edges] = histcounts(data);
else
    [y,edges] = histcounts(data,nbins);
end

x = edges(2:end);

winK = round(0.05*length(x));
if winK>0
    movemeany = movmean(y,winK);
else
    movemeany = y;
end

if interp>0
    xq = linspace(x(1),x(end),length(x)*interp);
    if length(x)>=2
        pchipy = pchip(x,movemeany,xq);
    else
        pchipy = movemeany;
    end
    freq = pchipy/sum(pchipy);
% freq = pchipy;
else
    xq = x;
    freq = movemeany./sum(movemeany);
%     freq = movemeany;
end

end

