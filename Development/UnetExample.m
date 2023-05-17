%% Create U-Net Network
% imageSize = [480 640 3];
% numClasses = 5;
% encoderDepth = 3;
% lgraph = unetLayers(imageSize,numClasses,'EncoderDepth',encoderDepth);
% 
% % display the network
% plot(lgraph)

%% Train U-Net Network

% Load data
dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
imageDir = fullfile(dataSetDir,'trainingImages'); % A folder full of jpg images. 
labelDir = fullfile(dataSetDir,'trainingLabels'); % A folder full of png images. 255 where the target feature is located. 0 elsewhere
testDir = fullfile(dataSetDir,'testImages'); % A folder full of jpg images. 
testimds = imageDatastore(testDir);
imds = imageDatastore(imageDir);

% class names and their associated label IDs
classNames = ["triangle","background"];
labelIDs   = [255 0];

% Create pixelLabelDatastore object to store the ground truth pixel labels
% for the training images
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Create the U-Net Network
imageSize = [32 32];
numClasses = 2;
lgraph = unetLayers(imageSize, numClasses);

% datastore for training the network
ds = combine(imds,pxds);


% Set training options
options = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',20, ...
    'VerboseFrequency',10);

% Train the network
net = trainNetwork(ds,lgraph,options);

%%
C = readimage(pxds,100);
I = readimage(imds,100);
% cmap = camvidColorMap;
B = labeloverlay(I,C);
imshow(B)
pixelLabelColorbar(cmap,classes);