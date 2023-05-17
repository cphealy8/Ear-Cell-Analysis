function [BW2] = bwcircfilt(BW,varargin)
%BWCIRCFILT extract objects from binary image based upon circularity.
%   SYNTAX
%   BW2 = bwcircfilt(BW,range);
%   BW2 = bwcircfilt(BW,n);
%   BW2 = bwcircfilt(BW,n,keep);

%%
labs = bwlabel(BW);

circs = bwcirc(BW);
[scircs,sID] = sort(circs);

ncircs = length(circs);
labv = 1:ncircs;
%% parse remaining inputs
if length(varargin)==1
    if length(varargin{1}) == 1 % keep top n
        topn = varargin{1};
        keep = sID((ncircs-topn):ncircs);
    elseif length(varargin{1})==2 % keep values in range
        valrange =varargin{1};
        keepI = (scircs>=valrange(1))&(scircs<=valrange(2));
        keep = sID(keepI);
    else
        error('Invalid filter spec')
    end
elseif length(varargin)==2 % keep bottom n
    if strcmpi(varargin{2},'smallest')
        botn = varargin{1};
        keep = sID(1:botn);
    else
        error('Invalid filter spec')
    end
else
    error('Filter specs not provided')
end

% Using keep remove 
BW2 = ismember(labs,keep);
end

