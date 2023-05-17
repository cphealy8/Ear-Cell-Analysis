clc; clear; close all;

%% Split the image and labels into tiles
rootdir = '../Data/P5 - Pax2Cre/V1V2CKO1/';
im = imread([rootdir 'V1V2CKO_masked.png']);

labels = imread([rootdir 'V1V2CKO_HairCells.bmp']);

%% Preprocess images
% [bestScale,bestSNRatio,bestIm] = PreProcessLearn(im,labels);
% im = bestIm;
im(:,:,2) = im;
im(:,:,3) = im(:,:,1);

%%
tilewidth = 224;
imageDir = [rootdir 'imsResNet'];
labelDir = [rootdir 'labelsResNet'];
[tiledims,tx,ty] = Split2Tile(im,tilewidth,'SaveDir',imageDir);
tiledlabs = Split2Tile(labels,tilewidth,'SaveDir',labelDir);

%% Create datastores
imds = imageDatastore(imageDir);

% class names and their associated label IDs
classNames = ["background","cell"];
labelIDs   = [0 1];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

%% Prepare training, validation, and test sets
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionImData(imds,pxds,labelIDs);
%% Create Network
imageSize = [tilewidth tilewidth 3];

% Specify the number of classes.
numClasses = numel(classNames);

% Create DeepLab v3+.
lgraph = deeplabv3plusLayers(imageSize, numClasses, "resnet18");

%% Balance class weights
tbl = countEachLabel(pxds);
frequency = tbl.PixelCount/sum(tbl.PixelCount);
imageFreq = tbl.PixelCount ./ tbl.ImagePixelCount;
classWeights = median(imageFreq) ./ imageFreq;

pxLayer = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
lgraph = replaceLayer(lgraph,"classification",pxLayer);

%% Training Options
% Define validation data.
dsVal = combine(imdsVal,pxdsVal);

% Define training options. 
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'ValidationData',dsVal,...
    'MaxEpochs',30, ...  
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',2,...
    'Plots','training-progress',...
    'ValidationPatience', 4,...
    'ExecutionEnvironment','multi-gpu');

%% Data Augmentation
dsTrain = combine(imdsTrain, pxdsTrain);

%% Training
[net, info] = trainNetwork(dsTrain,lgraph,options);
save(fullfile(rootdir,['ResNet_HairCell_',qdt('Full'),'.mat']),'net','info','options')

%% Preview Test Results
nim = 20;
I = readimage(imdsTest,nim);
C = semanticseg(I,net);
imshow(labeloverlay(I,C));
%% Test Results
testdir = fullfile(rootdir,'testlabelsResNet');
mkdir(testdir);
pxdsResults = semanticseg(imdsTest,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',testdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

%% Segment and rebuild full image;
segdir = fullfile(rootdir,'SegLabelsResNet');
mkdir(segdir);
segResults = semanticseg(imds,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',segdir, ...
    'Verbose',false);

%% Rebuild
segims = imageDatastore(segdir);
for k=1:length(segims.Files)
    impart{k} = readimage(segims,k)>1;
%     imtemp = imr;
%     imtemp(xxx(k):xxx(k)+tilewidth-1,yyy(k):yyy(k)+tilewidth-1)=impart;
%     imrpart{k}= imtemp;
end

rtile = reshape(impart,[14,19])';
figure;montage(rtile,'Size',[14 19]);
fullim = RebuildFromTile(rtile',tx,ty);
fullim = logical(fullim);
%% Final Processing
AreaFilt = bwpropfilt(fullim,'area',[250 20000]);
OpenIm = imopen(AreaFilt,strel('disk',12));
ShedIm = imWatershed(OpenIm);
AreaFilt2 = bwpropfilt(fullim,'area',[250 2000]);
ShedIm2 = imWatershed(AreaFilt2);

figure
imshow(labeloverlay(im,ShedIm2,'Colormap','autumn'));