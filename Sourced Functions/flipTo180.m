function [angs] = flipTo180(angs)
%FLIPTO180 flip angles greater than 180 over the 0 to 180 axis. 
%   Detailed explanation goes here

angs(angs>180)=360-angs(angs>180);
end

