%% Split the image and labels into tiles
[imfile,rootdir] = uigetfile({'*.png;*.jpg;*.bmp*;*.mat'},'Select Image to Segment');
imraw = imread([rootdir imfile]);
[~,imname,imtype]=fileparts(imfile);

%% Preprocess images
% [bestScale,bestSNRatio,bestIm] = PreProcessLearn(im,labels);
% im = bestIm;
if strcmp(imtype,{'.bmp'})||length(size(imraw))==2
    imraw(:,:,2) = imraw;
    imraw(:,:,3) = imraw(:,:,1);
end

% Slight blur to denoise
imblur = imgaussfilt(imraw,1);

% Contrast by saturating bottom 5% of pixels and top 5% of pixels
im = imadjust(imblur,[.05 .95]);

%% Tile images
tilewidth = 224;
imageDir = [rootdir 'SplitIms'];
cnt=0;
while exist(imageDir, 'dir')==7 % prevent overwriting
    cnt=cnt+1;
    imageDir = [imageDir num2str(cnt)];
end

[tiledims,tx,ty] = Split2Tile(im,tilewidth,'SaveDir',imageDir);

%% Create datastores
imds = imageDatastore(imageDir);

%% Load network
[netfile,netdir] = uigetfile({'*.mat'},'Select Segmentation Network',rootdir);
load([netdir netfile]);

%% Segment and rebuild full image;
segdir = fullfile(rootdir,'SegLabels');
cnt=0;
while exist(segdir, 'dir')==7 % prevent overwriting
    cnt=cnt+1;
    segdir = [segdir num2str(cnt)];
end

mkdir(segdir);
segResults = semanticseg(imds,net, ...
    'MiniBatchSize',4, ...
    'WriteLocation',segdir, ...
    'Verbose',false);
segims = imageDatastore(segdir);
for k=1:length(segims.Files)
%     if islogical(labels)
%         impart{k} = readimage(segims,k)>1;
%     else
        impart{k} = readimage(segims,k);
%     end
%     imtemp = imr;
%     imtemp(xxx(k):xxx(k)+tilewidth-1,yyy(k):yyy(k)+tilewidth-1)=impart;
%     imrpart{k}= imtemp;
end

rtile = reshape(impart,[length(tx),length(ty)])';
% figure;montage(rtile,'Size',[14 19]); 
RLabel = RebuildFromTile(rtile',tx,ty);

%% Final Processing
% If the label matrix is a mask do some additional processing
labelIDs   = double(unique(RLabel));
numClasses = length(labelIDs);
timeID = qdt('Full');

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
    xlabel('Post Processing')
    subplot(1,2,2)
    imshow(labeloverlay(im,KMask{end}))
    ylabel('Final Segmentation')
    RLabel = KMask{end};
    
    % Save full label image
    [rlabfile,rlabdir]=uiputfile(fullfile(rootdir,['LearnedLabels_',timeID,'.bmp']));
    if ischar(rlabfile)
        imwrite(RLabel,[rlabdir rlabfile '.bmp'])
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



