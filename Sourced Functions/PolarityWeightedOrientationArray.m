function [array] = PolarityWeightedOrientationArray(orientation,polarity,binEdges)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

[~,WeightedFreq] = MyWeightedCount(orientation,polarity,binEdges);

nObservations = length(orientation);

[array] = FrequencyToArray(WeightedFreq,binEdges,nObservations);


end

