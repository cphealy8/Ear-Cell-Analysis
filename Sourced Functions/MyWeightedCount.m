function [WeightedCount,Weightedfrequency,Count,Frequency] = MyWeightedCount(values,weights,bins)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

binID = zeros(length(values),1);

weights(isnan(weights)) = 0;

for n=1:(length(bins)-1)
    binmin(n) = bins(n);
    binmax(n) = bins(n+1);
    
    valsGreater = values>=binmin(n);
    valsLess = values<binmax(n);
    
    valsIn = valsGreater&valsLess;
    
    WeightedCount(n) = sum(valsIn.*weights);
    Count(n) = sum(valsIn); 
end
Weightedfrequency = WeightedCount./sum(WeightedCount);
Frequency = Count./sum(Count); 
end

