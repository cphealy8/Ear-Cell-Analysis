function [mask,sepmasks] = BuildMask(tgtIm,CellProps,varargin)
%BUILDMASK build a full mask knowing the pixel ids of features that make up
%the mask.
%   Detailed explanation goes here
%% parse inputs
p = inputParser;

addRequired(p,'tgtIm');
addRequired(p,'CellProps');
addParameter(p,'ImField','none',@ischar);

parse(p,tgtIm,CellProps,varargin{:}); 

ImField = p.Results.ImField;
%%
[imx,imy,imz] = size(tgtIm);
mask = false(imx,imy);
if strcmp(ImField,'none')
    pix = cell2mat(CellProps.PixIDs);
    mask(pix) = true;
else
    ims = CellProps.(ImField);
    pxrows = CellProps.pxrows;
    pxcols = CellProps.pxcols;
    
    for k = 1:length(pxrows)
        mask(pxrows{k},pxcols{k}) = ims{k};
    end
end
end

