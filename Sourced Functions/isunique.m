function [test] = isunique(V)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[U,~,idy] = unique(V,'first');
cnt = histc(V,U);
test = ~ismember(idy,find(cnt>1)); % locations of duplicates
end

