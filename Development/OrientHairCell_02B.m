clc;clear;close all;
SelectHairCell_02;
close all;
%%

for k = 1:nHair
curIm = SepCells{k};
curMask = SepMask{k};
curEllipse = imerode(SepEllipse{k},strel('disk',0));
MaskArea = sum(sum(curMask));

conIm{k} = imadjust(curIm,[0.1 1]).*curEllipse;
blurIm{k} = imadjust(medfilt2(conIm{k},round(0.005*MaskArea)*[1 1])).*curEllipse;
invertIm{k} = imadjust(imcomplement(blurIm{k}).*curEllipse);
openIm{k} = imadjust(imclose(invertIm{k},strel('disk',3)),[0.5 1]);
bwIm{k} = imbinarize(invertIm{k},0.9);

end
figure
montage(conIm,'BackgroundColor','r')
figure
montage(blurIm,'BackgroundColor','r')
figure
montage(invertIm,'BackgroundColor','r');
figure
montage(openIm,'BackgroundColor','r')
figure
montage(bwIm,'BackgroundColor','r')

% figure
% montage(denoiseIm,'BackgroundColor','r')
