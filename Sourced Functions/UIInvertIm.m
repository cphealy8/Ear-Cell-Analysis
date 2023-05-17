function [img] = UIInvertIm(doSave)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
[file,path] = uigetfile('*.bmp');
filepath= fullfile(path,file);
% Read in the image to be analyzed
img = imread(filepath);
img = ~img;

if strcmp(doSave,'save')
    imwrite(img,filepath)
end
end

