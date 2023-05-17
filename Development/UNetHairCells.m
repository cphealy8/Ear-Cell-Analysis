%% Create U-Net Network
% imageSize = [480 640 3];
% numClasses = 5;
% encoderDepth = 3;
% lgraph = unetLayers(imageSize,numClasses,'EncoderDepth',encoderDepth);
% 
% % display the network
% plot(lgraph)

%% Split the image and labels into tiles
rootdir = '../Data/P5 - Pax2Cre/V1V2CKO/';
im = imread([rootdir 'V1V2CKO_masked.png']);
labels = imread([rootdir 'V1V2CKO_HairCells.bmp']);

tilewidth = 96;
imageDir = [rootdir 'ims'];
labelDir = [rootdir 'labels'];
tiledims = Split2Tile(im,tilewidth,'SaveDir',imageDir);
tiledlabs = Split2Tile(labels,tilewidth,'SaveDir',labelDir);



% Create datastores
imds = imageDatastore(imageDir);

% class names and their associated label IDs
classNames = ["background","cell"];
labelIDs   = [0 1];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

%% Prepare training, validation, and test sets
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionImData(imds,pxds,labelIDs);
%% Train U-Net Network

% Load data
% dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
% imageDir = fullfile(dataSetDir,'trainingImages'); % A folder full of jpg images. 
% labelDir = fullfile(dataSetDir,'trainingLabels'); % A folder full of png images. 255 where the target feature is located. 0 elsewhere
% testDir = fullfile(dataSetDir,'testImages'); % A folder full of jpg images. 
% imds = imageDatastore(imageDir);
% 
% 
% % Create pixelLabelDatastore object to store the ground truth pixel labels
% % for the training images
% pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Create the U-Net Network
imageSize = [tilewidth tilewidth];
numClasses = 2;
lgraph = unetLayers(imageSize, numClasses);

% datastore for training the network
dsTrain = combine(imdsTrain,pxdsTrain);

% Set training options
options = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',20, ...
    'VerboseFrequency',10);

% Train the network
net = trainNetwork(dsTrain,lgraph,options);

%%
testdir = fullfile(rootdir,'testlabels');
mkdir(testdir);
pxdsResults = semanticseg(imdsTest,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',testdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);
