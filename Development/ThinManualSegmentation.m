BWFile = '../Data/Test Images/Illustrator Files/1066_4_BoundaryMask.bmp';
RGBFile = '../Data/Test Images/Illustrator Files/1066_4-leveled.png';
imBW = imread(BWFile);
imBW = imclose(imBW,strel('disk',10));

imRGB = imread(RGBFile);
figure 
imshow(imRGB);
hold on
visboundaries(bwboundaries(imBW),'Color','w','LineWidth',1)

imBWrem = bwmorph(imBW,'shrink',Inf);
figure
imshow(imBWrem);
imwrite(imBWrem,'../Data/Test Images/Illustrator Files/1066_4_ThinBounds.bmp')

imThickBounds = imdilate(imBWrem,strel('disk',2));
figure
imshow(imThickBounds);

figure
imshow(imRGB)
hold on
visboundaries(bwboundaries(imThickBounds),'Color','w','LineWidth',1)

CellMask = ~imBW;
[L,nComps] = bwlabel(CellMask);
CellsIm = labelSeparate(imRGB,L,'mask');
CropIm = labelSeparate(imRGB,L,'crop',20);

Root = '1066_4';
fDir = fullfile('..','Data','Vision Library');
SaveImageSet(CellsIm,Root,fDir);
cDir = fullfile('..','Data','Vision Library','Unmasked');
SaveImageSet(CropIm,Root,cDir);
