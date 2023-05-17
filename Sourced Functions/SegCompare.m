function [Stats] = SegCompare(controlMask,testMask,varargin)
%SegCompare compare segmentation masks to assess similarity and evaluate
%segmentation sensitivity and specificity. 
%   Detailed explanation goes here
controlMask = double(controlMask);
testMask = double(testMask);

if nargin==3
    controlMask(~varargin{1}) = NaN;
    testMask(~varargin{1}) = NaN;
end

TPMask = controlMask.*testMask; % True Positive entries
FPMask = testMask-controlMask; % False Positive entries
FPMask(FPMask<0)= 0; 

FNMask = controlMask-testMask; % False Negative entries
FNMask(FNMask<0) = 0;

TNMask = true(size(controlMask))-TPMask-FPMask-FNMask;
TNMask(TNMask<0)=0;

%% Count Pixels
TP = sum(TPMask(:),'omitnan');
FP = sum(FPMask(:),'omitnan');
FN = sum(FNMask(:),'omitnan');
TN = sum(TNMask(:),'omitnan');

Stats.Sensitivity = TP/(TP+FN);
Stats.Specificity = TN/(TN+FP);
Stats.Precision = TP/(TP+FP);
Stats.F1Score = 2*TP/(2*TP+FP+FN);

Stats.TruePos = TP;
Stats.FalsePos = FP;
Stats.FalseNeg = FN;
Stats.TrueNeg =TN;
end