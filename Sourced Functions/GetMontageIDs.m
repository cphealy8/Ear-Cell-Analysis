function [selectedIms] = GetMontageIDs(ImgCellArray)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

for k=1:length(ImgCellArray)
    [imx,imy,imz] = size(ImgCellArray{k});
    IDim{k} = k.*ones(imx,imy);
end

fH2 = figure;
montage(ImgCellArray)
[xi,yi] = getpts;

fH1 = figure('Visible','off');
montH = montage(IDim);
montIm = montH.CData;
imRes = size(montIm);

close(fH1)
close(fH2)

if ~isempty(yi)
    [pixID] = pts2pix([yi xi],imRes);
    selectedIms = round(montIm(pixID));
else
    selectedIms = [];
end


end