function [BW2] = CropComp2Mask(BW,mask,varargin)
%CROPCOMP2MASK remove binary components in BW that are not in contact with
%binary components in binary mask. 
%
%   SYNTAX
%   BW2 = CropComp2Mask(BW,mask) removes connected components in BW that
%   are not in contact with connected components in mask. 
%
%   BW2 = CropComp2Mask(BW,mask,'hard') removes connected components in BW
%   that are not entirely contained within connected components in mask.
%
%   BW2 = CropComp2Mask(BW,mask,'invert') removes connected components in BW
%   that are within or touching the connected components in mask.
%
%   BW2 = CropComp2Mask(BW,mask,'invert','hard') removes connected components in BW
%   that are entirely within the connected components in mask

% [remxmax,remymax] = size(remBW);
% [pxx,pyy] = meshgrid(1:remxmax,1:remymax);
% remX = pxx(~remBW);
% remY = pyy(~remBW);
% 
% BW2 = bwselect(BW,1:500,1:500);

% default
labs = bwlabel(BW);

if ismember('invert',varargin)||(length(varargin)==2&&strcmp(varargin{1},'true'))
    mask = ~mask;
end


inmask = unique(labs(mask));
inmask(inmask==0)=[];
BW2 = ismember(labs,inmask);

if ismember('hard',varargin)||(length(varargin)==2&&strcmp(varargin{2},'true'))
    notinmask = unique(labs(~mask));
    notinmask(notinmask==0)=[];
    remMask = ismember(labs,notinmask);
    BW2(remMask) = false;
end

end
