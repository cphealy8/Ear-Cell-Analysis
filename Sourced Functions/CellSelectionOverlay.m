function [] = CellSelectionOverlay(ImDat,varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% fH=figure;
imshow(ImDat.RAW)
% imshow(labeloverlay(ImDat.RAW,ImDat.PolarBodyMask,'Colormap',[1 1 1]))
hold on
if isempty(varargin)
    visboundaries(bwboundaries(ImDat.HairCellMask),'Color','r','Linewidth',0.5);
    visboundaries(bwboundaries(ImDat.SupportCellMask),'Color','c','Linewidth',0.5);
else % User specified colors
    visboundaries(bwboundaries(ImDat.HairCellMask),'Color',varargin{1}(1,:),'Linewidth',1);
    visboundaries(bwboundaries(ImDat.SupportCellMask),'Color',varargin{1}(2,:),'Linewidth',1);
end
end