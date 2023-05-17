clc;clear;close all;
SelectHairCell_02;
close all;
%%
tic;
for k = 1:nHair
curIm = SepCells{k};
curMask = SepMask{k};
curEllipse = SepEllipse{k};
MaskArea = sum(sum(curMask));
[ydim(k) xdim(k)] = size(curIm);

conIm{k} = imadjust(curIm,[0.1 1]).*curEllipse;
blurIm{k} = imadjust(medfilt2(conIm{k})).*curEllipse;
flatIm{k} = imadjust(medfilt2(imflatfield(blurIm{k},2))).*curEllipse;
erodeIm1{k} = imadjust(imerode(flatIm{k},strel('disk',2)));
invertIm{k} = imadjust(imcomplement(erodeIm1{k}).*curEllipse);
erodeIm2{k} = imadjust(invertIm{k}.*imerode(curEllipse,strel('disk',4)));
bwIm{k} = imbinarize(localcontrast(erodeIm2{k}),0.80);

% Filter by region properties
% Filtering by eccentricity will reduce the options to only the most
% circular regions.
morFilt1{k} = bwpropfilt(bwIm{k},'Area',[5 1000]); % Remove single pixel noise.
% Size-based area filtration.
morFilt2{k} = bwpropfilt(morFilt1{k},'Area',[0.01 0.15].*MaskArea);
morFilt3{k} = bwpropfilt(morFilt2{k},'Solidity',[0.7 1]);
morFilt4{k} = bwpropfilt(morFilt3{k},'Area',1,'Largest');

overlay{k} = imoverlay(curIm,morFilt4{k},'r');

end

CellProps.xdim = xdim';
CellProps.ydim = ydim';

figure
montage(overlay)

CellProps = BBOrient(CellProps,morFilt4);
%% Display
tim = toc;
figure
OrientOverlay(imR,CellProps);

% Histograms
figure
subplot(2,1,1)
histogram(CellProps.Orientation,20)

xlim([-180 180])
xlabel('Hair Cell Orientation (Global, degrees)')
ylabel('Count')

subplot(2,1,2)
histogram(CellProps.Polarity,linspace(0,1,21))
xlabel('Magnitude of Polarity (Normalized)')
ylabel('Count');


%%
figure
n = 86;
cellim = SepCells{n};
maskims = logical(SepEllipse{n});

dx = CellProps.dX(n);
dy = CellProps.dY(n);
ex = CellProps.EX(n);
ey = CellProps.EY(n);

imshow(maskims)
[w,h] = size(cellim);
ctr = [w h]/2;

hold on 

plot([ctr(2) ctr(2)+ey],[ctr(1) ctr(1)+ex],'.-b','LineWidth',3)
plot([ctr(2) ctr(2)+dy],[ctr(1) ctr(1)+dx],'.-r','LineWidth',2)

%% Save
save('HairCellDat.mat','CellProps')