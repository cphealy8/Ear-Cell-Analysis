function [polarities,EdgePts,EdgeLine] = PolarityByFeature(CellMask,FeatureMask,varargin)
%POLARITYBYFEATURE Get polarity map based upon a feature that cells orient
%with respect to. 
%   Detailed explanation goes here
%% parse inputs
p = inputParser;
addRequired(p,'CellMask',@islogical);
addRequired(p,'FeatureMask',@islogical);
addParameter(p,'Adjust2Center',false,@islogical);
%%
[EdgePts,EdgeLine]=Mask2EdgePts(FeatureMask);
IMap = InfluenceMap(EdgeLine);
FilledMask = imfill(CellMask,'holes');
[NormImage]= NormByBWComp(FilledMask,IMap);

% % Adjust to center
% [~,~,ctrIm] = BWVisualCenter(FilledMask);
% 
% ctrPols = NormImage(ctrIm);
% maskL = bwlabel(FilledMask);
% ctrInd = maskL(ctrIm);
% PolsROrd = [NaN;ctrPols(ctrInd)];
% ctrPolMap = PolsROrd(maskL+1);
% 
% %less than
% ltmap = NormImage.*(NormImage<ctrPolMap);
% shiftltmap = (ltmap./ctrPolMap)*0.5;
% 
% %greater than
% gtmap = NormImage.*(NormImage>=ctrPolMap);
% shiftgtmap = ((gtmap-ctrPolMap)./(1-ctrPolMap))*0.5 +0.5;
% 
% %Merge
% NormImage(NormImage<ctrPolMap) = shiftltmap(NormImage<ctrPolMap);
% NormImage(NormImage>=ctrPolMap) = shiftgtmap(NormImage>=ctrPolMap);

polarities = 2*abs(NormImage-0.5).*FilledMask;
polarities(~CellMask)=NaN;
end

