function [reImg] = RebuildImFromComps(varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Load sepimage file
[fname,fpath] = uigetfile('*.mat','Select Masking file');
load(fullfile(fpath,fname));

% Load imarray file
[sname,spath] = uigetfile('*.mat','Select Image file',fpath);
load(fullfile(spath,sname));

masks = ImArray(:,end);
pixIn = [];


for k = 1:length(idIms)
    curID = idIms{k};
    curMask = masks{k};
    pixIn = [pixIn; curID(curMask)];
end

reImg = false(imRez(1),imRez(2));
reImg(pixIn) = true;

if nargout==0
    [newfile,newpath] = uiputfile('*.bmp','Save Reconstructed image',[fpath fname]);
    
    if ischar(newfile)
        imwrite(reImg,[newpath newfile])
    end
end
        
end

