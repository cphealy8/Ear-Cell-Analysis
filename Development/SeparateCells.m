clc;clear;close all;
%% Read the image
Root = 'im1';
RAW = imread(fullfile('../Data/Test Images/Raw',strcat(Root,'.png')));
dRAW = imresize(RAW,0.05);

%% Select Channel to analyze
imG = dRAW(:,:,2);

%% Leveling and Contrasting
imGAdj = ImLevel(imG,200);
levRGB = ImLevel(dRAW,200);
%% Binary operations
imTH = imtophat(imGAdj,strel('disk',3));
imBW = ~imbinarize(imTH,'adaptive');
imClose = ~bwareaopen(~imBW,30);
imOpen = imopen(imClose,strel('disk',1));
imOpen = bwareaopen(imOpen,2);

%% Watershed Segmentation
D = -bwdist(~imOpen);
mask = imextendedmin(D,1);

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = imOpen;
bw3(Ld2 == 0) = 0;

%% Morphological Filtering
AreaThresh = [50,2000];
bw4 = regionthresh(bw3,'Area',AreaThresh);
% bw5 = bw4;
bw5 = ~imdilate(bwmorph(bwmorph(~bw4,'shrink',inf),'clean'),strel('disk',1));

% Remove single pixel noise and components that touch the image boundary.
bw6 = imclearborder(bwareaopen(bw5,20));
%% Labeling
[L,nComps] = bwlabel(bw6);
LRGB = label2rgb(L,'jet','k','shuffle');

%% Display
levRGB(:,:,3) = 0; % Clear unuseful channels.
imSeg = uint8(double(levRGB).*double(bw6));
% imshow(imSeg)

%% Separate Cells
CellsIm = labelSeparate(levRGB,L,'mask');

[ImsForLabeling,ImMask] = labelSeparate(levRGB,L,'crop',20);

%% Save Separate images
RawDir = fullfile('..','Data','CellImages');
ForLabelDir = fullfile('..','Data','ForLabeling');
MaskDir = fullfile('..','Data','Masks');
SaveImageSet(CellsIm,Root,RawDir);
SaveImageSet(ImsForLabeling,Root,ForLabelDir);
SaveImageSet(ImMask,Root,MaskDir);
%% Label Cells
startID = 1; 
[LabelData] = labelImages(ForLabelDir,{'Hair';'Support';'Multiple';'NA'},{'1';'2';'3';'4'},startID,MaskDir);

%% Save
endID = startID-1+length(LabelData.LabelID);

labelDir = fullfile(RawDir,'Labels');
labelFname = fullfile(labelDir,strcat('labels_',num2str(startID),'-',num2str(endID),'.mat'));

mkdir(labelDir);
save(labelFname);