function [imRebuilt] = RebuildFromTile(tile,x,y)
%REBUILDFROMTILE Rebulds a full image from a tiled image. Opposite of
%SPLIT2TILE. 
%   Author: Connor P. Healy (connor.healy@utah.edu)
%   July 12,2021

%% rebuild image;
imRebuilt = [];
[wx,wy,nchann] =size(tile{1,1});
for i=1:length(x)
    for j =1:length(y)
        imRebuilt(x(i):x(i)+wx-1,y(j):y(j)+wy-1,:)=tile{i,j};
    end
end

imRebuilt = uint8(imRebuilt);
end