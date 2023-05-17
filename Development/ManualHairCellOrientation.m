%% 
% Load the image.
clc; clear ;close all
RAW = imread('../Data/Test Images/Modified/IM1_RAW.png');
%% 
% Unlike the previous analyses, this image has a low enough resolution to 
% permit relatively rapid segmentation. 
% 
% Next, we want to contrast the image. 

Contrasted = localcontrast(RAW);
% figure
% imshowpair(RAW,Contrasted,'montage')
%% 
% Next separate the channels

imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);

rez = size(imR);

imRd = cat(3,imR,zeros(rez(1),rez(2),2));

%% Select Center then basal body before moving to next cell
figure
imshow(imR)
set(gca,'Units','normalized','Position',[0,0,1,1]);
axis normal
tic
[cx, cy] = getpts;
CompTime = toc;
%%
cenX = cx(1:2:end);
cenY = cy(1:2:end);
bX = cx(2:2:end);
bY = cy(2:2:end);

figure
imshow(imR)
hold on 
plot(cenX,cenY,'.r')
plot(bX,bY,'.b')
hold off

%%
dX = bX-cenX;
dY = bY-cenY;
orientation = atan2d(dX,dY);
Magnitude = sqrt((dX).^2+(dY).^2);
figure
histogram(orientation,20)
xlabel('Orientation (degrees)')
ylabel('Count')
figure
histogram(Magnitude,20);
xlabel('Magnitude of Polarity')
ylabel('Count')
%%
figure
imshow(imR)
set(gca,'Units','normalized','Position',[0,0,1,1]);
axis normal

for k = 1:length(bX)
arrowX = [cenX bX]./rez(2);
arrowY = 1-[cenY bY]./rez(1);

ann = annotation('arrow',arrowX(k,:),arrowY(k,:));
if orientation(k)>0
    ann.Color = 'r';
else
    ann.Color = 'y';
end

ann.HeadLength = 10;
ann.HeadWidth = ann.HeadLength;
ann.HeadStyle = 'vback1';
end

%% save
sdat.Polarity = Magnitude;
sdat.Orientation = orientation;
sdat.Time = CompTime;
sdat.cenX = cenX;
sdat.cenY = cenY;
sdat.bX = bX;
sdat.bY = bY;

