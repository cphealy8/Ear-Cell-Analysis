function [ImArray,imfiles,impath] = uigetimages(varargin)
%UIGETIMAGES Select and load multiple images. Store as separate elements in
%cell array.
%   Detailed explanation goes here
% Default
if isempty(varargin)
    [imfile,impath] = uigetfile({'*.png;*.jpg;*.bmp*;*.mat'},'Multiselect','on');
else
    [imfile,impath] = uigetfile(varargin{:});
end
filedir = fullfile(impath,imfile);

[~,~,ext] = fileparts(filedir);
try
switch ext
    case '.mat'
        load(filedir);
        if exist('ims','var')
            ImArray = ims;
            imfiles{1} = imfile;
        else
            error('To import an image array you must load .mat file that stores the image array as a structure named ims');
        end
    otherwise 
        if iscell(imfile)
            nIms = length(imfile);
            imfiles = imfile;
        else
            nIms = 1;
            imfiles{1}=imfile;
        end


        ImArray = cell(nIms,1);
        if nIms==1
            ImArray{1} = imread(fullfile(impath,imfile));
        else
            for k = 1:length(imfile)
                ImArray{k} = imread(fullfile(impath,imfile{k}));
            end
        end
end
catch
    ImArray = {0};
    imfiles = {0};
    impath = {0};
end
end