clc;clear;close all;
load('HairCellIms.mat')

nCells = length(CellIms);

for n = 1:nCells
    CellIm = CellIms{n};
    
    % Isolate blue channel and contrast
    bChann{n} = imadjust(CellIm(:,:,3));
    
    bIsolate{n} = imadjust(ChannelIsolate(CellIm,'blue'));

    % Median filter to reduce noise
    medFilt{n} = imadjust(medfilt2(bIsolate{n},2.*[1 1]));
    
    % Threshold and Binarize
    imBW{n} = imbinarize(medFilt{n},0.8);
    
    % Solidify
    imSolid{n} = imdilate(imclose(imBW{n},strel('disk',5)),strel('disk',1));
    
    % Select highest avg intensity 
    imBB{n} = bwpropfilt(imSolid{n},bChann{n},'MeanIntensity',1);
end

figure
montage(bChann)
bChannMontage = rgb2gray(frame2im(getframe(gca)));

figure
montage(bIsolate)

figure
montage(medFilt)

figure
montage(imBW)


figure
montage(imSolid)

figure
montage(imBB)
LastMontage = frame2im(getframe(gca));
LastMontage = imbinarize(rgb2gray(LastMontage));

figure
imshow(labeloverlay(bChannMontage,LastMontage));
