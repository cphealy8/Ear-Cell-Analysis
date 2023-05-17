function [BW2] = bwremcontact(BW,remBW)
%BWREMCONTACT remove components in bw touching components in remBW. 
%   Detailed explanation goes here

% [remxmax,remymax] = size(remBW);
% [pxx,pyy] = meshgrid(1:remxmax,1:remymax);
% remX = pxx(~remBW);
% remY = pyy(~remBW);
% 
% BW2 = bwselect(BW,1:500,1:500);

labs = bwlabel(BW);

inremBW = unique(labs(remBW));

BW2 = ~ismember(labs,inremBW);
end

