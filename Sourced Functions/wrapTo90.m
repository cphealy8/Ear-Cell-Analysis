function [angs] = wrapTo90(angs)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
angs = abs(wrapTo180(angs));
angs = abs(angs-90);
angs = -1*(angs-90);

end

