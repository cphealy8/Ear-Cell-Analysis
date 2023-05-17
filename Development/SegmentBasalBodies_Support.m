clc;clear;close all;
load('SupportCellDat.mat')
RAW = imread('RAW.png');
nCells = length(CellIms);

for n = 1:nCells
    CellIm = CellIms{n};
    [ydim(n) xdim(n)] = size(CellIm);
    bChann{n} = imadjust(CellIm(:,:,3));
    
    bIsolate{n} = imadjust(ChannelIsolate(CellIm,'blue'));
    % Median filter to reduce noise
    medFilt{n} = imadjust(medfilt2(bIsolate{n},2.*[1 1]));
    
    % Threshold and Binarize
    imBW{n} = imbinarize(medFilt{n},0.6);
    
    % Solidify
    imSolid{n} = imclose(imBW{n},strel('disk',2));
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid{n},'Area',1);
end


figure
montage(bChann)
bChannMontage = rgb2gray(frame2im(getframe(gca)));

figure
montage(imBB)

LastMontage = frame2im(getframe(gca));
LastMontage = imbinarize(rgb2gray(LastMontage));

figure
imshow(labeloverlay(bChannMontage,LastMontage));

save('SupportCellDat.mat','CellProps','imBB','CellIms');


CellProps = BBOrient(CellProps,imBB);

figure
OrientOverlay (RAW,CellProps)

%% Histograms
% Top Most polar/ plots
topperc = 0.1;
ntop = round(topperc.*nCells);
nbins = 21;

[topPolarities, topCells] = maxk(CellProps.Polarity,ntop);
[botPolarities, botCells] = mink(CellProps.Polarity,ntop);

topOrientations = CellProps.Orientation(topCells);
bottomOrientations = CellProps.Orientation(botCells);

figure
subplot(2,1,1)
histogram(CellProps.Orientation,linspace(-180,180,nbins),'Normalization','Probability')
hold on
histogram(topOrientations,linspace(-180,180,nbins),'Normalization','Probability')
xlim([-180 180])
ylim([0 .1])
xlabel('Support Cell Orientation (Global, degrees)')
ylabel('Probability')


subplot(2,1,2)
histogram(CellProps.Polarity,linspace(0,1,nbins))
hold on
histogram(topPolarities,linspace(0,1,nbins))
xlabel('Magnitude of Polarity (Normalized)')
ylabel('Count');
legend('All support cells','Bottom 10% of least polarized support cells','Location','SouthOutside')


%% Weighted histograms
bintervals = linspace(-180,180,nbins);
[histw,histv] = weightedHist(CellProps.Orientation, CellProps.Polarity, -180, 180, nbins);
figure
bar(bintervals,histv/sum(histv),1,'FaceAlpha',0.5)
hold on
bar(bintervals,histw/sum(histw),1,'FaceAlpha',0.5)
xlim([-180 180])
ylim([0 .1])

xlabel('Support Cell Orientation (degrees)')
ylabel('Probability')
legend('Original','Polarity Weighted');
