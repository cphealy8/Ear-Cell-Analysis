clc; clear; close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

clrMap = 'RdYlBu';

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

nanOri = isnan(CellProps.NormOrientation);
try
    nanPol = isnan(CellProps.CombinedPolarity);
catch
    CellProps.CombinedPolarity = CellProps.Polarity;
    nanPol = isnan(CellProps.CombinedPolarity);
end

CellProps(nanOri|nanPol,:)=[];

% Fix orientation thing
% CellProps.NormOrientation = wrapTo360(360-CellProps.NormOrientation);

HID = CellProps.Type=='H';
SID = CellProps.Type=='S';
% Commonly used sets
OrientH = CellProps.NormOrientation(CellProps.Type=='H');
OrientS = CellProps.NormOrientation(CellProps.Type=='S');
PolarH = CellProps.CombinedPolarity(CellProps.Type=='H');
PolarS = CellProps.CombinedPolarity(CellProps.Type=='S');

xcompH = PolarH.*cosd(OrientH);
ycompH = PolarH.*sind(OrientH);
xcompS = PolarS.*cosd(OrientS);
ycompS = PolarS.*sind(OrientS);

cbrewmap = flipud(cbrewer('div','Spectral',64));


ImDat.HairCellMaskB = BuildMask(ImDat.RAW,CellProps(HID,:));
ImDat.SupportCellMaskB = BuildMask(ImDat.RAW,CellProps(SID,:));
%% Display Results
PolAndOriHistograms(CellProps,'Full')
PolarityWeightedOrientationHist(CellProps);
CellSelectionOverlay(ImDat)

if exist('BoundPts','var')
    OrientationVectorOverlay(CellProps,BoundPts,ImDat,'Scaling','BB','ScaleValue',0);
    F = getframe;
    ImDat.AnnotImage = export_fig('-native');
end

[CDFO,xO] = CDFPlot(CellProps,'Orientation','xy','none');

OrientationMaps(CellProps,ImDat,clrMap);
PolarityMaps(CellProps,ImDat,clrMap);
%% Polar plots\Bullseye
figure
subplot(1,2,1)
MyBullseye(OrientH,PolarH,'Units','degrees','Color','r')
title('Hair')
subplot(1,2,2)
MyBullseye(OrientS,PolarS,'Units','degrees','Color','c')
title('Support')

% Model cell plot
figure
subplot(1,2,1)
ModelCellMap(CellProps.CombinedPolarity(CellProps.Type=='H'),wrapTo360(360-CellProps.NormOrientation(CellProps.Type=='H')),100,'pbradius',10,'kernType','circle');
title('Hair Cell')
cax = colorbar;
ylabel(cax,'Polar Body Density');


subplot(1,2,2)
ModelCellMap(CellProps.CombinedPolarity(CellProps.Type=='S'),wrapTo360(360-CellProps.NormOrientation(CellProps.Type=='S')),100,'pbradius',10,'kernType','circle');
title('Support Cell')
cax= colorbar;
ylabel(cax,'Polar Body Density');

%% Statistics
[combinedX,intCDFs] = InterpCDFs(xO,CDFO);
interpCDFPlot(combinedX,intCDFs,'polar');

% Kolmogorov Smirnov - Tests the null hypothesis that two populations are
% drawn from the same distribution aka. tests whether two distributions are
% the same/similar. Note KS is not necessarily appropriate for circular
% statistics.
DistType ={'E','E','E','T'}; % Is the distribution empirical or theoretical.
[KSResultsOrientation] = KSStruct(xO,CDFO,DistType);

% Polarity Stats
[CDFP,xP] = CDFPlot(CellProps,'Polarity','xy','none');
[KSResultsPolarity] = KSStruct(xP,CDFP,DistType);

% For circular statistics note that the diametrically bimodal orientation
% measurements must be first transformed using the double angle
% transformation.
CellProps.DblAngOrientation = DblAngTransform(CellProps.NormOrientation,'deg');

figure
DblAngPlot(CellProps.NormOrientation(CellProps.Type=='H'),'deg',36)

AngsCombo = CellProps.DblAngOrientation;
AngsHair = CellProps.DblAngOrientation(CellProps.Type=='H');
AngsSupport = CellProps.DblAngOrientation(CellProps.Type=='S');
% Rayleigh Test for Uniformity. Tests the null hypothesis that the input
% distribution is uniform.
RayPValue_Combo = RayleighTest(AngsCombo);
RayPValue_Support = RayleighTest(AngsSupport);
RayPValue_Hair = RayleighTest(AngsHair);


% Mardia-Watson-Wheel Uniform-Scores Test
% This procedure tests whether two distributions (including circular
% distributions) are equal. 
[W,MWWSigLvl_SupportVHair] = MWWUniformScores(AngsHair,AngsSupport);

%% Overlay reference angles
figure
imshow(ImDat.RAW)
hold on
quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),cosd(CellProps.RefAngle),sind(CellProps.RefAngle),0.5,'Color','w')
hold on 
plot(BoundPts(:,1),BoundPts(:,2),'.r');



%% Angle K
HID = CellProps.Type=='H';
SID = CellProps.Type=='S';

% Vector fields with normalized Orientation
figure
imshow(ImDat.RAW)
hold on
quiver(CellProps.Centroid(HID,1),CellProps.Centroid(HID,2),cosd(CellProps.NormOrientation(HID)),sind(CellProps.NormOrientation(HID)),0.5,'Color','r')
quiver(CellProps.Centroid(SID,1),CellProps.Centroid(SID,2),cosd(CellProps.NormOrientation(SID)),sind(CellProps.NormOrientation(SID)),0.5,'Color','c')
hold off
axis ij
axis tight

mindim = min(size(ImDat.Red));
scales = linspace(0,mindim/2,21);
scales(1) = [];

hvec.origin = CellProps.Centroid(HID,:);
hvec.angle = CellProps.NormOrientation(HID)*pi/180;
hvec.magnitude = ones(sum(HID),1);

svec.origin = CellProps.Centroid(SID,:);
svec.angle = CellProps.NormOrientation(SID)*pi/180;
svec.magnitude = ones(sum(SID),1);

% Compute AngleK stats 
alpha = 0.01;
[Khh,Orihh] = AngleK(scales,hvec); % hair to hair
[~,KhhMax,KhhMin] = AngleK_Env(scales,hvec,alpha);
[Kss,Oriss] = AngleK(scales,svec); % support to support
[~,KssMax,KssMin] = AngleK_Env(scales,svec,alpha);
[Khs,Orihs] = AngleK(scales,hvec,svec); % Hair to support
[~,KhsMax,KhsMin] = AngleK_Env(scales,hvec,alpha,'vecB',svec);
[Ksh,Orish] = AngleK(scales,svec,hvec); % support to hair.
[~,KshMax,KshMin] = AngleK_Env(scales,svec,alpha,'vecB',hvec);
%%
figure
lwd = 1.5;
ylims = [-1 1];
subplot(2,2,1)
plot(scales,Khh,'-b','LineWidth',lwd)
hold on
plot(scales,KhhMax,'--k',scales,KhhMin,'--k','LineWidth',lwd)
yline(0,'-k')
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Hair Cell to Hair Cell')
ylim(ylims)

subplot(2,2,2)
plot(scales,Kss,'-b','LineWidth',lwd)
hold on
plot(scales,KssMax,'--k',scales,KssMin,'--k','LineWidth',lwd)
yline(0,'-k')
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Support Cell to Support Cell')
ylim(ylims)

subplot(2,2,3)
plot(scales,Khs,'-b','LineWidth',lwd)
hold on
plot(scales,KhsMax,'--k',scales,KhsMin,'--k','LineWidth',lwd)
yline(0,'-k')
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Hair Cell to Support Cell')
ylim(ylims)

subplot(2,2,4)
plot(scales,Ksh,'-b','LineWidth',lwd)
hold on
plot(scales,KshMax,'--k',scales,KshMin,'--k','LineWidth',lwd)
yline(0,'-k')
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title('Support Cell to Hair Cell')
ylim(ylims)

%% Alignment histograms
figure
subplot(2,2,1)
[HistMap] = HistogramMap(Orihh,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title('Hair to Hair')
subplot(2,2,2)
[HistMap] = HistogramMap(Oriss,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title('Support to Support')
subplot(2,2,3)
[HistMap] = HistogramMap(Orihs,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title('Hair to Support')
subplot(2,2,4)
[HistMap] = HistogramMap(Orish,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title('Support to Hair');
%% If I randomize the support cell orientation what do the results like?
svecrand = svec;
svecrand.angle = rand(length(svec.angle),1)*pi*2-pi;

subplot(2,2,1)
[Kssrand,Orissrand] = AngleK(scales,svecrand);
[HistMap] = HistogramMap(Orissrand,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title({'Support to Support Cell','Randomized Support Orientation'})

subplot(2,2,4)
[Kshrand,Orishrand] = AngleK(scales,svecrand,hvec);
[HistMap] = HistogramMap(Orishrand,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title({'Support to Hair Cell','Randomized Support Orientation'})

subplot(2,2,3)
[Kshrand,Orihsrand] = AngleK(scales,hvec,svecrand);
[HistMap] = HistogramMap(Orihsrand,'x',scales);
xlabel('Alignment');
ylabel('Scale(r)');
title({'Hair to Support Cell','Randomized Support Orientation'})

%
[~,KshMax,KshMin] = AngleK_Env(scales,svecrand,alpha,'vecB',hvec);
plot(scales,Kshrand,'-b','LineWidth',lwd)
hold on
plot(scales,KshMax,'--k',scales,KshMin,'--k','LineWidth',lwd)
yline(0,'-k')
xlabel('Scale (pixels)');
ylabel('Population Alignment')
title({'Support Cell to Hair Cell','Randomized Support Orientation'})
ylim(ylims)

%% alignment scatter maps
figure
rind =5 ;
circsz= 25;
subplot(3,2,1)
scatter(hvec.origin(:,2),hvec.origin(:,1),circsz,Orihh(:,rind),'filled');
axis ij; axis image;
cax=colorbar;
ylabel(cax,sprintf('Alignment at \n r=%1.0f',scales(rind)));
title('Hair:Hair')

subplot(3,2,2)
scatter(svec.origin(:,2),svec.origin(:,1),circsz,Oriss(:,rind),'filled');
axis ij; axis image;
cax=colorbar;
ylabel(cax,sprintf('Alignment at \n r=%1.0f',scales(rind)));
title('Support:Support')

subplot(3,2,3)
scatter(hvec.origin(:,2),hvec.origin(:,1),circsz,Orihs(:,rind),'filled');
axis ij; axis image;
cax=colorbar;
ylabel(cax,sprintf('Alignment at \n r=%1.0f',scales(rind)));
title('Hair:Support')

subplot(3,2,4)
scatter(svec.origin(:,2),svec.origin(:,1),circsz,Orish(:,rind),'filled');
axis ij; axis image;
cax=colorbar;
ylabel(cax,sprintf('Alignment at \n r=%1.0f',scales(rind)));
title('Support:Hair')

subplot(3,2,5)
scatter(hvec.origin(:,2),hvec.origin(:,1),circsz,Orihsrand(:,rind),'filled');
axis ij; axis image;
cax=colorbar;
ylabel(cax,sprintf('Alignment at \n r=%1.0f',scales(rind)));
title('Hair:SupportRND')

subplot(3,2,6)
scatter(svec.origin(:,2),svec.origin(:,1),circsz,Orishrand(:,rind),'filled');
axis ij; axis image;
cax=colorbar;
ylabel(cax,sprintf('Alignment at \n r=%1.0f',scales(rind)));
title('SupportRND:Hair')

%% Local Alignment Maps
[maskH] = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='H',:));
[maskS] = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='S',:));
% [datmap,axH,labels] = DataMap(maskH,Orihh(:,rind),'Display',true);
[DataMapHH,fig,ax,cax,sld]=DataMapSlider(scales,Orihh,maskH);
title(ax,'Hair:Hair')
[DataMapHS,fig,ax,cax,sld]=DataMapSlider(scales,Orihs,maskH);
title(ax,'Hair:Support')
[DataMapSS,fig,ax,cax,sld]=DataMapSlider(scales,Oriss,maskS);
title(ax,'Support:Support')
[DataMapSH,fig,ax,cax,sld]=DataMapSlider(scales,Orish,maskS);
title(ax,'Support:Hair')

%% Alignment Map Movie
figure(1)
vidname = strcat(file(1:end-4),'_Alignment','.mp4');
vidfile = VideoWriter(strcat('Results/Videos/',vidname),'MPEG-4');
vidfile.FrameRate = 2;
open(vidfile);
for k=1:length(DataMapHH)
    subplot(2,2,1)
    imagesc(DataMapHH{k})
    subplot(2,2,2)
    imagesc(DataMapHS{k})
    subplot(2,2,3)
    imagesc(DataMapSS{k})
    subplot(2,2,4)
    imagesc(DataMapSS{k})
    drawnow
    F(k) = getframe(gcf);
    writeVideo(vidfile,F(k));
end
close(vidfile)
%% Contamination tests
% ConProps = CellProps;
% 
% nSupport = length(SID);
% falseSupport = 16;
% trueSupport = nSupport-falseSupport;
% SupportUnifAngs = rand(trueSupport,1)*360-180;
% HairAngs = ConProps.NormOrientation(HID);
% FalseAngs = datasample(HairAngs,falseSupport);
% TestAngs = [SupportUnifAngs; FalseAngs];
% 
% ph=polarhistogram(TestAngs*2*pi/360,28);
% ph.Normalization = 'probability';
