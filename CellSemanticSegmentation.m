%% Following guidelines at
% https://www.mathworks.com/help/vision/ug/semantic-segmentation-with-deep-learning.html#mw_44be2a2e-ec6b-4a03-9470-ea945f74515e
% https://towardsdatascience.com/simple-introduction-to-convolutional-neural-networks-cdf8d3077bac
%% Analyze Training Data for Semantic Segmentation
clc;clear;close all;

imDir = fullfile('Data','Control','Split','Train','Images','preprocessed');
pxDir = fullfile('Data','Control','Split','Train','PixelLabelData','preprocessed');

imdsTrain = imageDatastore(imDir);

ind = 12;
I = readimage(imdsTrain,ind);
% figure
% imshow(I)

classNames = ["Background" "Hair" "Support"];

pixelLabelID = 1:3;
pxdsTrain = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
SegLabs = readimage(pxdsTrain,ind);

B = labeloverlay(I,SegLabs);
figure
imshow(B)
legend

%% Create a semantic segmentation network

% create an image input layer. This defines the smallest image size that
% the network can process.
inputSize = size(I); 
numClasses = length(pixelLabelID);

% Create a semantic segmentation network
numFilters = 64;
filterSize = 3;

layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ];
analyzeNetwork(layers)



%% Create pixel label image datastore
% Augment and preprocess training data images
trainingData = pixelLabelImageDatastore(imdsTrain,pxdsTrain);

tbl = countEachLabel(trainingData);
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency;

layers(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

% Read and display a test data
testDir = fullfile('Data','Control','Split','Test','Images','preprocessed');
imdsTest= imageDatastore(testDir);
labDir = fullfile('Data','Control','Split','Test','PixelLabelData','preprocessed');
labDS = imageDatastore(labDir);
pxdsTest = pixelLabelDatastore(labDir,classNames,pixelLabelID);

testingData = pixelLabelImageDatastore(imdsTest,pxdsTest);

%% Set training options
opts = trainingOptions('adam', ...
    'InitialLearnRate',1e-2,...
    'MaxEpochs',1000  ,...
    'MiniBatchSize',64,...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropFactor',0.8,...
    'LearnRateDropPeriod',100,...
    'Shuffle','every-epoch',...
    'Plots','training-progress',...
    'ValidationData',testingData);
%% Train the Network
net = trainNetwork(trainingData,layers,opts);

%% Test the Network

testind = 4;
for n=1:4
testImage = readimage(imdsTest,n);
testLabs = readimage(labDS,n);
testLabs = categorical(testLabs,pixelLabelID,classNames);
% Segment the test image using the trained network and display the results.
SegLabs = semanticseg(testImage,net);

subplot(4,2,2*n-1)
imshow(labeloverlay(testImage,testLabs));
xlabel('Manual')

subplot(4,2,2*n)
imshow(labeloverlay(testImage,SegLabs));

accu = sum((testLabs(:)==SegLabs(:)))./numel(testLabs);
xlabel(sprintf('Learned (Accuracy %0.2f%%)',accu*100))
end