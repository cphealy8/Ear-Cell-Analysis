function [ax] = AccuMap(controlMap,testMap,varargin)
%ACCUMAP Compare segmentation results to control results. Report accuracy
%statistics.
%   Detailed explanation goes here
if nargin==3
    Test = SegCompare(controlMap,testMap,varargin{1});
else
    Test = SegCompare(controlMap,testMap);
end

ax = imshowpair(testMap,controlMap);
str = sprintf('Sens:%1.2f\nSpec: %1.2f\nPrec: %1.2f\nF1: %1.2f',Test.Sensitivity,Test.Specificity,Test.Precision,Test.F1Score);
annotation('textbox',[0.1 0.65 0.3 0.3],'String',str,'FitBoxToText','on','BackgroundColor','w','FontSize',16);
end

