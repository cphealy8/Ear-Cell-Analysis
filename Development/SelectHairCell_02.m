%% 
% Load the image.

RAW = imread('RAW.png');
%% 
% Unlike the previous analyses, this image has a low enough resolution to 
% permit relatively rapid segmentation. 
% 
% Next, we want to contrast the image. 

Contrasted = localcontrast(RAW);
% figure
% imshowpair(RAW,Contrasted,'montage')
%% 
% Next separate the channels

imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);

rez = size(imR);

imRd = cat(3,imR,zeros(rez(1),rez(2),2));
imGd = cat(3,zeros(rez(1),rez(2)),imG,zeros(rez(1),rez(2)));
imBd = cat(3,zeros(rez(1),rez(2),2),imB);

% figure
% montage({imRd,imGd,imBd},'Size',[1 3])
%% 
% To segment the hair cells we will use the red channel. The next step is 
% to apply a filter to reduce noise. We will compare a gaussian filter and a median 
% filter.

imGauss = imgaussfilt(imR,5);
imMedian = medfilt2(imR,15.*[1 1]);

% montage({imR,imGauss,imMedian},'Size',[1,3])
% title('Red/Gaussian Filtered/Median Filtered')
%% 
% Notice how the illumination of each hair cell is different. To correct 
% this the median filtered image was flat fielded. This requires blurring the 
% image then subtracting the blurred image from the original. 

imFlat = imflatfield(imMedian,100);

% montage({imMedian,imflatfield(imMedian,300),imflatfield(imMedian,100)...
%     imflatfield(imMedian,30),imflatfield(imMedian,10)})
%% 
% Of these flat-fielded images, the one that used sigma=100 gave the best 
% balance between leveling the illumination and preserving shape. If we apply 
% local contrasting again, the 

imFlatCon = localcontrast(imFlat,0.7,0.7);
% montage({imFlat, imFlatCon},'Size',[1,2]);
%% 
% Finally the image can be adaptively thresholded to obtain a binary mask 
% indicating the position of hair cells. 


imBW = imbinarize(imFlatCon,0.2);

% imshowpair(imFlatCon,imBW,'Montage');
%% 
% Next we will apply a small binary close to solidify the cells followed 
% by a larger binary open to remove small pixel noise. Finally, a small dilation 
% will be applied to make sure that the selection includes the entire hair cells. 

imClose = imclose(imBW,strel('disk',2));
imOpen = imopen(imClose,strel('disk',8));
imDil = imdilate(imOpen,strel('disk',2));

% montage({imBW,imClose,imOpen,imDil},'Size',[1,4])
% figure
% imshow(imR)
% hold on 
% visboundaries(bwboundaries(imDil),'Color','r','Linewidth',1)
%% 
%  

% figure
% imshow(RAW)
% hold on 
% visboundaries(bwboundaries(imDil),'Color','w','Linewidth',1)
%% 
% Next, the hair cells must be approximated as ellipses. To do this, the 
% centroids of the binary regions in the mask that correspond to each cell are 
% computed as well as their major axis length, minor axis length, and orientation. 

CellProps = bwcompprops(imDil);
imEllipse = bwEllipse(size(imDil),CellProps.Centroid,CellProps.MajorAxisLength,CellProps.MinorAxisLength,CellProps.Orientation);

figure
imshow(imR)
hold on
visboundaries(bwboundaries(imDil),'Color','r','Linewidth',1)
visboundaries(bwboundaries(imEllipse),'Color','b','Linewidth',1)

%% Add a few additional descriptors to the CellProps table
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';
CellProps.Type = repmat('Hair',[nHair 1]);
CellProps.AvgIntensity = cell2mat(struct2cell(regionprops(imDil,imR,'MeanIntensity')))';
pixIDs = struct2cell(regionprops(imEllipse,'PixelIdxList'));

% add these ID's to the plot
text(CellProps.Centroid(:,1),CellProps.Centroid(:,2),num2str(CellProps.ID),...
    'Color','g','HorizontalAlignment','center')

%% Isolate the cells
[L,nComps] = bwlabel(imEllipse);

SepCells = labelSeparate(imR,L,'mask');
figure
montage(SepCells)

%% Refine the set
% Remove cells that have an average intensity less than some predefined
% threshold. 
omittedCells = CellProps.ID(CellProps.AvgIntensity<20);
omittedPixels = cell2mat(pixIDs(omittedCells));
imEllipse(omittedPixels(:)) = 0;
CellProps(omittedCells,:) = [];
nHair = length(CellProps.Area);
CellProps.ID = (1:nHair)';

% Isolate the cells
[L,nComps] = bwlabel(imEllipse);

SepCells = labelSeparate(imR,L,'mask');
SepBodies = labelSeparate(imB,L,'mask');
SepEllipse = labelSeparate(imEllipse,L,'mask');
SepMask = labelSeparate(imDil,L,'mask');

CellIms = labelSeparate(RAW,L,'mask');
figure
montage(SepCells)


save('HairCellIms.mat','CellIms')
