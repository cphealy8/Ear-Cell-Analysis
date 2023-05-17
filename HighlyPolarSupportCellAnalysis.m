clc; clear; close all;
%% Load data
addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

clrMap = 'RdYlBu';

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

%% Display
thresh = 0.625; % Cutoff threshold for highly polar cells. 
CellPolarities = CellProps.CombinedPolarity(CellProps.Type=='S');
numCells = length(CellPolarities);
FractionAboveThresh = sum(CellPolarities>=thresh)/numCells;
FractionBelowThresh = 1-FractionAboveThresh;




% Map data to images
bwIm = ImDat.SupportCellMask;
fullIm = ImDat.RAW;

[datmap,fH,axH] = DataMap(bwIm,CellPolarities);
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity');
title('Support Cell MIP');

% Histogram
figure;
subplot(1,2,1)
h=histogram(CellPolarities,20);
h.Normalization = 'probability';
h.FaceColor = 'c';
title('Support Cells');
xlabel('Magnitude of Polarity')

line([thresh thresh],ylim,'Linewidth',2,'Color','r')
text(thresh*1.2,diff(ylim)*0.9,num2str(FractionAboveThresh))
text(thresh*0.8,diff(ylim)*0.9,num2str(FractionBelowThresh),'HorizontalAlignment','right')
% Aditional useful stats. 

% Convert datamap to binary mask and overlay on image.
threshmask = datmap>=thresh;
bwbounds = bwboundaries(threshmask);


subplot(1,2,2)
imshow(fullIm)
hold on
for k = 1:length(bwbounds)
    boundary = bwbounds{k};
    plot(boundary(:,2),boundary(:,1),'w','Linewidth',1)
end
