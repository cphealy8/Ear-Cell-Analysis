function [] = InvertAndSave()
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

[im,imfile,impath] = uigetimages('*.bmp','Select Image to Invert');

nf = figure;
imshow(imtile(im))

answer = questdlg('Invert?', ...
	'Do Invert', ...
	'Yes','No','No');

if strcmp(answer,'Yes')
        for k = 1:length(im)
        imout = ~im{k};
        imwrite(imout,[impath imfile{k}])
        end
end

close(nf)
end

