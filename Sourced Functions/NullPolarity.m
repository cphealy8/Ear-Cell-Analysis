function [NullMean,NullSD,nullx,NullCounts] = NullPolarity(data,nbins,reps)
% Estimate the null polarity of a distribution of polarity values in data,
% with nbins. For alpha =.05 reps=40, alpha = .01 reps = 40
    for k =1:reps
        ndatapts = length(data);
        RandData(k,:) = sqrt(rand(1,ndatapts)); % Null polarity
        
        [NullCounts(k,:),edges]=histcounts(RandData(k,:),nbins,'Normalization','Probability');
    end
    nullx = edges(1:end-1)+(diff(edges)/2);
    NullMean = mean(NullCounts);
    NullSD = std(NullCounts);  
end