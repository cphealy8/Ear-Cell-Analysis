function [] = PolarityWeightedOrientationHist(CellProps)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

nbins = 36;
binEdges = linspace(-pi,pi,nbins);

figure
%%
subplot(1,3,1)
orientation = CellProps.NormOrientation*2*pi/360;
polarity = CellProps.CombinedPolarity; 

weightedArray = PolarityWeightedOrientationArray(orientation,polarity,binEdges);

ph=polarhistogram(weightedArray,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'm';
title('Combined');

%%
subplot(1,3,2)
tgt = CellProps.Type=='H';
orientation = CellProps.NormOrientation(tgt)*2*pi/360;
polarity = CellProps.CombinedPolarity(tgt); 

weightedArray = PolarityWeightedOrientationArray(orientation,polarity,binEdges);

ph=polarhistogram(weightedArray,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'r';
title('Hair Cells');

%%
subplot(1,3,3)
tgt = CellProps.Type=='S';
orientation = CellProps.NormOrientation(tgt)*2*pi/360;
polarity = CellProps.CombinedPolarity(tgt); 

weightedArray = PolarityWeightedOrientationArray(orientation,polarity,binEdges);

ph=polarhistogram(weightedArray,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'c';
title('Support Cells');

sgtitle('Polarity-Weighted Orientation Distribution')
end

