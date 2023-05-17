function [array] = FrequencyToArray(frequency,binEdges,nObservations)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

array = [];
counts = round(frequency*nObservations);
for n=1:length(counts)
    binmin = binEdges(n);
    binmax = binEdges(n+1);
    
    newvals = (binmax-binmin).*rand(counts(n),1)+binmin;
    array = [array; newvals];
end

end

