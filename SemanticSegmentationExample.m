%% Following guidelines at
% https://www.mathworks.com/help/vision/ug/semantic-segmentation-with-deep-learning.html#mw_44be2a2e-ec6b-4a03-9470-ea945f74515e
% https://towardsdatascience.com/simple-introduction-to-convolutional-neural-networks-cdf8d3077bac
%% Analyze Training Data for Semantic Segmentation
clc;clear;close all;
addpath('Sourced Functions')

imDir = fullfile('Data','Control','Split','Train','Images','preprocessed');
pxDir = fullfile('Data','Control','Split','Train','PixelLabelData','preprocessed');

imds = imageDatastore(imDir);

ind = 3;
I = readimage(imds,ind);
% figure
% imshow(I)

classNames = ["Hair" "Support" "Intermediate"];

pixelLabelID = 1:3;
pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);


C = readimage(pxds,ind);

B = labeloverlay(I,C);
figure
imshow(B)
legend

%% Create a semantic segmentation network

% create an image input layer. This defines the smallest image size that
% the network can process.
maxDim = 100;
inputSize = size(I); 
imgLayer = imageInputLayer(inputSize);

%% Create a Downsampling Network %%%%
%%% Start with the convolution layer %%%
% Define hyperparameters of convolution layer.
% FilterSize should be on the scale of anything that you think will
% help distinguish the features in your image. Support cells are 22 pixels
% in diameter but it's not uncommon to use a 3x3 filter or a 5x5 filter so
% we will try those first. 
%
% The number of filters sets the number of times that the original image is
% convolved with the filter. 

% Number of filters can be tuned during training. 
filterSize = 3; % Hyperparameter. 
numFilters = 32; % Hyperparameter.

conv = convolution2dLayer(filterSize,numFilters,'Padding',1);
% Padding ensures that the size of the output matches the size of the
% input.
% By default the stride of this convolution is 1, meaning that during
% convolution the filter slides 1 step at a time. Setting a higher stride
% sets the number of steps that occur during convolution e.g. stride = 2
% makes the filter slide 2 steps at a time during convolution.

%%% Define the ReLU Layer %%%
% The ReLU layer decides whether a certain feature is present in the input
% image or not. It outputs the input directly if positive(feature present)
% or 0 otherwise. 
% https://machinelearningmastery.com/rectified-linear-activation-function-for-deep-learning-neural-networks/
relu = reluLayer();

%%% Create a max pooling layer to downsample the input %%%
% This layer takes the maximum value in a certain filter region and is used
% to reduce the dimensionality of the network making computation quicker!

poolSize = 2; % This is functionally equivalent to the filter size.
% It defines the size of the area from which data is pooled. 

maxPoolDownsample2x = maxPooling2dLayer(poolSize,'Stride',2); 
% Setting the stride to 2 downsamples the input by a factor of 2. 

%%% Stack the previous layers to create downsampling Layers %%%
downsamplingLayers = [
    conv
    relu
    maxPoolDownsample2x
    conv
    relu
    maxPoolDownsample2x];

% overall this will perform 32 convolutions, relu, then max pool
% downsample by a factor of 2, then 32 more convolutions, relu, and a final
% downsample by a factor of 2 for a total downsampling factor of 4X. 

downsamplingLayers
% Show the 6 layers and what they are doing.


%% Create upsampling network
filterSize = 4;
% Create a transposed convolution layer to upsample by 2. 
transposedConvUpsample2x = transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
% The cropping parameter is set to 1 to make the output size equal twice
% the input size.

% Stack the transposed convolution and relu layers. 
upsamplingLayers = [
    transposedConvUpsample2x
    relu
    transposedConvUpsample2x
    relu
    ]

%% Create A Pixel Classification Layer
% These final layers process an input that has the same spatial dimensions
% (height and width) as the input image. However, the number of channels
% (third dimension) is larger and is equal to number of filters in the last
% transposed convolution layer. This third dimension needs to be squeezed
% down to the number of classes we wish to segment. This can be done using
% a 1by1 conbolution layer whose number of filters equal the number of
% classes, e.g. three. 

% Combine the 3rd dimension of the input feature maps down to the number of
% classes
numClasses = 3;
conv1x1 = convolution2dLayer(1,numClasses);

% Following this 1-by-1 convolution layer are the softmax and pixel
% classification layers. These two layers combine to predict the
% categorical label for each image pixel. 
finalLayers = [
    conv1x1
    softmaxLayer()
    pixelClassificationLayer()
    ]

%% Stack All Layers
% Stack all layers to complete the semantic segmentation network
net = [
    imgLayer
    downsamplingLayers
    upsamplingLayers
    finalLayers
    ];

%% Train a semantic segmentation network (Example
dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
imageDir = fullfile(dataSetDir,'trainingImages');
labelDir = fullfile(dataSetDir,'trainingLabels');

imds = imageDatastore(imageDir);
classNames = ["triangle","background"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

% Visualize
I = read(imds);
C = read(pxds);

I = imresize(I,5);
L = imresize(uint8(C),5);
imshowpair(I,L,'montage')

% Create a semantic segmentation network
numFilters = 64;
filterSize = 3;
numClasses = 2;

layers = [
    imageInputLayer([32 32 1])
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

% Set training options
opts = trainingOptions ('sgdm', ... %stochastic gradient descent with momentum
    'InitialLearnRate',1e-3,... % Learning rate is a tuning parameter that determines the step size at each iteration while moving toward a minimum of a loss function.
    'MaxEpochs',100, ... % # of passes through the entire learning set 
    'MiniBatchSize',64); % Mini batch is a subset of the training data used to evaluate the gradient of the loss function and update the weights. 

% Create a pixel label image datastore that contains the training data.
trainingData = pixelLabelImageDatastore(imds,pxds); 

% Train the network
net = trainNetwork(trainingData,layers,opts); 

% Read and display a test image
testImage = imread('triangleTest.jpg');
imshow(testImage)

% Segment the test image using the trained network and display the results.
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)

% the network failed to segment the triangles and instead classified every
% pixel as background. These poor results are due to class imbalance. To
% fix this class weighting can be used to balance the classes. One method
% to do this is inverse frequency weighting where the class weights are the
% inverse of the class frequencies. This increases the weight given to
% under-represented classes.
tbl = countEachLabel(trainingData);
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency;

% Class weights are incorporated into the network usin the
% pixelCLassificationlayer
layers(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

% train again
net = trainNetwork(trainingData,layers,opts);

% Try to segment again
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)