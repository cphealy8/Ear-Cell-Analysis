clc; clear; close all;

%% Split the image and labels into tiles
[imfile,rootdir] = uigetfile({'*.png;*.jpg;*.bmp*;*.mat'},'Select Training Image');
imraw = imread([rootdir imfile]);
[~,imname,imtype]=fileparts(imfile);


[labelfile,labeldir] = uigetfile({'*.png;*.jpg;*.bmp*;*.mat'},'Select Training Labels File',rootdir);
labels = imread([labeldir labelfile]);
% [~,imname,imtype]=fileparts(imfile);
% labels = imread([rootdir 'V1V2CKO_BasalBodies.bmp']);

%% Preprocess images
% Contrast
if strcmp(imtype,{'.bmp'})||length(size(imraw))==2
    imraw(:,:,2) = imraw;
    imraw(:,:,3) = imraw(:,:,1);
end

% Slight blur to denoise
imblur = imgaussfilt(imraw,1);

% Contrast by saturating bottom 5% of pixels and top 5% of pixels
im = imadjust(imblur,[.05 .95]);


%% Define classes
defClasses = ["A","B","C","D","E","F","G","H","I","J"];

% class names and their associated label IDs
labelIDs   = double(unique(labels));
numClasses = length(labelIDs);
if numClasses>10
    error('Too many classes in label image');
end
classNames = defClasses(1:numClasses);

%% Split Image and Labels
tilewidth = 224;
imageDir = [rootdir 'SplitIms'];
labelDir = [labeldir 'SplitLabels'];
[tiledims,tx,ty] = Split2Tile(im,tilewidth,'SaveDir',imageDir);
tiledlabs = Split2Tile(labels,tilewidth,'SaveDir',labelDir);

%% Create datastores
imds = imageDatastore(imageDir);
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

%% Prepare training, validation, and test sets
[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = partitionImData(imds,pxds,labelIDs);

%% Create Network
imageSize = [tilewidth tilewidth 3];

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


%% Preview Test Results
% nim = 20;
% I = readimage(imdsTest,nim);
% C = semanticseg(I,net);
% imshow(labeloverlay(I,C));

%% Test Results
testdir = fullfile(rootdir,'TestLabels');
mkdir(testdir);
pxdsResults = semanticseg(imdsTest,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',testdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTest,'Verbose',false);

%% Save network and test results
timeID = qdt('Full');
[netfile,netdir]=uiputfile(fullfile(rootdir,['SegNet_',timeID,'.mat']));
if ischar(netfile) % Save trained network
    save([netdir netfile],'net','info','options','metrics')
end

%% Segment and rebuild full image;
segdir = fullfile(rootdir,'SegLabels');
mkdir(segdir);
segResults = semanticseg(imds,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',segdir, ...
    'Verbose',false);

%% Rebuild
segims = imageDatastore(segdir);
for k=1:length(segims.Files)
    if islogical(labels)
        impart{k} = readimage(segims,k)>1;
    else
        impart{k} = readimage(segims,k);
    end
%     imtemp = imr;
%     imtemp(xxx(k):xxx(k)+tilewidth-1,yyy(k):yyy(k)+tilewidth-1)=impart;
%     imrpart{k}= imtemp;
end

rtile = reshape(impart,[length(tx),length(ty)])';
% figure;montage(rtile,'Size',[14 19]);
RLabel = RebuildFromTile(rtile',tx,ty);

%% Final Processing
% If the label matrix is a mask do some additional processing
if numClasses==2
    %% Specifically tuned for hair cells
    KMask{1} = RLabel~=max(RLabel);
    KMask{2} = bwpropfilt(KMask{1},'area',[250 20000]);
    KMask{3} = imopen(KMask{2},strel('disk',12));
    KMask{4} = ~imWatershed(KMask{3});
    KMask{5} = bwpropfilt(KMask{4},'area',[250 2000]);
    KMask{6} = ~imWatershed(KMask{5});
    figure
    subplot(1,2,1)
    montage(KMask);
    subplot(1,2,2)
    imshow(labeloverlay(im,KMask{end}))
    RLabel = KMask{end};
    
    % Save full label image
    [rlabfile,rlabdir]=uiputfile(fullfile(rootdir,['LearnedLabels_',timeID,'.bmp']));
    if ischar(rlabfile)
        imwrite(RLabel,[rlabdir rlabfile])
    end
else
    figure
    imshow(labeloverlay(im,RLabel+1));
    
    % Save full label image
    [rlabfile,rlabdir]=uiputfile(fullfile(rootdir,['LearnedLabels_',timeID,'.png']));
    if ischar(rlabfile)
        imwrite(RLabel,[rlabdir rlabfile '.png'])
    end
end



