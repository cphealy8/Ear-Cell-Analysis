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

% figure
% montage(conIm,'BackgroundColor','r')
% figure
% montage(blurIm,'BackgroundColor','r')
% figure
% montage(flatIm,'BackgroundColor','r')
% figure
% montage(erodeIm1,'BackgroundColor','r')
% figure
% montage(invertIm,'BackgroundColor','r');
% figure
% montage(erodeIm2,'BackgroundColor','r');
% figure
% montage(bwIm,'BackgroundColor','r')
% figure
% montage(morFilt,'BackgroundColor','r')

% m = 3;
% comboIm = cell(1,m*nHair);
% comboIm(1:m:(m*nHair-m+1)) = SepCells;
% comboIm(2:m:(m*nHair-m+2)) = bwIm;
% comboIm(3:m:(m*nHair-m+3)) = morFilt;
% figure
% montage(comboIm,'BackgroundColor','r')

figure
montage(overlay)

%% Compute useful stats
Nomit = 0;
for k = 1:nHair
    % Compute some useful stats
if ~isempty(regionprops(morFilt4{k},'Area'))
    bprops = regionprops(morFilt4{k},'Area','Centroid');
    bType(k,1) = 1;
    bArea(k,1) = bprops.Area;
    bLocalCenter(k,1:2) = bprops.Centroid;
    
else
    bType(k,1) = 0;
    bArea(k,1) = 0;
    bLocalCenter(k,1:2) = [nan nan];
    Nomit = Nomit+1;
end

end

% Append to cell property table
CellProps.BBDetected = bType;
CellProps.BBArea = bArea;
CellProps.BBLocalCentroid = bLocalCenter;
CellProps.BBSize = [xdim' ydim'];

% Convert BB Local Center to global coordinates.
CellProps.BBCentroid = CellProps.Centroid...
    -CellProps.BBSize./2+CellProps.BBLocalCentroid;

% Compute the magnitude and orientation of the polarity
CellProps.dX = CellProps.BBCentroid(:,2)-CellProps.Centroid(:,2);
CellProps.dY = CellProps.BBCentroid(:,1)-CellProps.Centroid(:,1);
CellProps.EOrientation = CellProps.Orientation;
CellProps.GlobalOrientation = atan2d(CellProps.dY,CellProps.dX);
CellProps.BBDistance = sqrt((CellProps.dX).^2+(CellProps.dY).^2);

% Normalize
CellProps.Orientation = CellProps.GlobalOrientation;
a = CellProps.MajorAxisLength/2;
b = CellProps.MinorAxisLength/2;
alpha = CellProps.GlobalOrientation;
theta = CellProps.EOrientation;
CellProps.Ctr2EdgeDist = (a.*b)./sqrt((b.^2-a.^2).*cosd(alpha-theta).^2+a.^2);

CellProps.Polarity = CellProps.BBDistance./CellProps.Ctr2EdgeDist;

CellProps.EX = CellProps.Ctr2EdgeDist.*cosd(CellProps.GlobalOrientation);
CellProps.EY = CellProps.Ctr2EdgeDist.*sind(CellProps.GlobalOrientation);
CellProps.EPt = [CellProps.Centroid(:,1)+CellProps.EX CellProps.Centroid(:,2)+CellProps.EY];

%% Display
tim = toc;
figure
imshow(imR)
set(gca,'Units','normalized','Position',[0,0,1,1]);
axis normal
for k = 1:nHair
    if CellProps.BBDetected(k)==1
    arrowX = [CellProps.Centroid(k,1) CellProps.BBCentroid(k,1)]./rez(2);
    arrowY = 1-[CellProps.Centroid(k,2) CellProps.BBCentroid(k,2)]./rez(1);
    
    ann = annotation('arrow',arrowX,arrowY);
    
    if CellProps.Orientation(k)>0
    ann.Color = 'r';
    else
    ann.Color = 'y';
    end
    
    ann.HeadLength = 10;
    ann.HeadWidth = ann.HeadLength;
    ann.HeadStyle = 'vback1';
    end
    
end
hold on
plot(CellProps.Centroid(:,1),CellProps.Centroid(:,2),'.r')
plot(CellProps.EPt(:,1),CellProps.EPt(:,2),'.g')

% Histograms
figure
subplot(2,1,1)
histogram(CellProps.Orientation,20)

xlim([-180 180])
xlabel('Hair Cell Orientation (Global, degrees)')
ylabel('Count')

subplot(2,1,2)
histogram(CellProps.Polarity,20)
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