clc;clear;close all;
RAW = imread('RAW.png');
imstream{1} = RAW;

% contrast
Contrasted = localcontrast(RAW);
imstream{2} = Contrasted;

% Convert to grayscale
Gray = rgb2gray(Contrasted);
imstream{3} = Gray;

% Even illumination;
imFlat = imadjust(imflatfield(Gray,1));
imstream{4} = imFlat;

% Blur
imMedian = imadjust(medfilt2(imFlat,100.*[1 1],'symmetric'));
imstream{5} = imMedian;
 
% Blur Again to smooth boundary

imGauss = imadjust(imgaussfilt(imFlat,60));
imstream{6} = imGauss;

% Threshold
imThresh = imGauss>=200;
imstream{7} = imThresh;

% Fill small holes
imClose = imclose(imThresh,strel('disk',100));
imstream{8} = imClose;

% Convert to single pixel boundary;
imBound = bwmorph(imClose,'remove');

% Delete boundary pixels
imBound(:,1) = 0;
imBound(1,:) = 0;
imBound(:,end) = 0;
imBound(end,:) = 0;
imstream{8}= imdilate(imBound,strel('disk',5)); % Dilation is for display only

% convert pixel boundary to points
boundpts = pix2pts(imBound);

% For computational speed omit some points;
RDXboundpts = boundpts(1:5:end,:);

%% Display Results
[rows,cols] = size(Gray);
figure
montage(imstream);

figure
imshow(RAW);
hold on
plot(boundpts(:,1),boundpts(:,2),'.w')

dx = 45;
gridx = 1:dx:cols;
gridy = 1:dx:rows;
[XX,YY] = meshgrid(gridx,gridy);
respts = [XX(:) YY(:)];
hold on

[~,refAngle] = pt2ptInfluence(respts,boundpts);

unitX = cosd(refAngle);
unitY = sind(refAngle);

quiver(respts(:,1),respts(:,2),unitX,unitY,0.5,'Color','w')

%% Alternate display
load('HairCellDat.mat')

figure
imshow(RAW);
hold on
plot(boundpts(:,1),boundpts(:,2),'.w')

[~,refAngle] = pt2ptInfluence(CellProps.Centroid,boundpts);

unitX = cosd(refAngle);
unitY = sind(refAngle);

quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),unitX,unitY,0.3,'Color','w')

% Define a vector field for orientation
cellX = cosd(CellProps.GlobalOrientation);
cellY = sind(CellProps.GlobalOrientation);

quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),cellX,cellY,0.3,'Color','m')