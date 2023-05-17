clc;clear;close all;

load('ManualOrientationData_01.mat')
sdat1 = sdat;

load('ManualOrientationData_02.mat')
sdat2 = sdat;

load('ManualOrientationData_04.mat')
sdat4 = sdat;

load('ManualOrientationData_05.mat')
sdat5 = sdat;

% Forgot to save the data from sdat3
sdat3.CompTime = 423.64;
sdat3.nHair = 233;
fntsz = 20;
load('CellPropsData.mat')
%%
% Manual Averages
MnHair = [length(sdat1.bX) length(sdat2.bX) length(sdat4.bX) length(sdat5.bX)];
MCompTime =[sdat1.Time sdat2.Time sdat4.Time sdat5.Time];

MaveN = mean(MnHair);
MsdN = std(MnHair);

MaveTime = mean(MCompTime);
MsdTime = std(MCompTime);

% Computational Averages
CnHair = [233 233 233 233 233];
CCompTime = [10.22 10.65 10.35 10.69]+[4.84 4.13 4.14 4.00];

CaveN = mean(CnHair);
CsdN = std(CnHair);

CaveTime = mean(CCompTime);
CsdTime = std(CCompTime);
%% Display Orientation

ORedges = linspace(-180,180,20);

% Manual
OrMan(1,:) = histcounts(sdat1.orientation,ORedges);
OrMan(2,:) = histcounts(sdat2.Orientation,ORedges);
OrMan(3,:) = histcounts(sdat4.Orientation,ORedges);
OrMan(4,:) = histcounts(sdat5.Orientation,ORedges);

ORctrs = ORedges(2:end)-(ORedges(2)-ORedges(1))/2;

OrManAve = mean(OrMan);
OrManSD = std(OrMan);

% Computed
OrCompAve = histcounts(CellProps.Orientation,ORedges);
OrCompSD = zeros(size(OrCompAve));

%
figure
e1=errorbar(ORctrs,OrCompAve,OrCompSD,'-r');
e1.Marker = '.';
e1.MarkerSize = 15;
e1.LineWidth = 1.5;
hold on
e2=errorbar(ORctrs,OrManAve,OrManSD,'-b');
e2.Marker = '.';
e2.MarkerSize = 15;
e2.LineWidth = 1.5;
hold off
axis tight
xlabel('Hair Cell Orientation (Degrees)','FontSize',fntsz)
ylabel('Cell Count','FontSize',fntsz)
legend('Computed','Manual');
set(gca,'FontSize',fntsz-2);

% percent Agreement
nCells = length(CellProps.Orientation);
PercAgreement = sum(abs(OrCompAve-OrManAve))/nCells;

%% Display Polarity

ORedges = linspace(5,30,20);

% Manual
OrMan(1,:) = histcounts(sdat1.Polarity,ORedges);
OrMan(2,:) = histcounts(sdat2.Polarity,ORedges);
OrMan(3,:) = histcounts(sdat4.Polarity,ORedges);
OrMan(4,:) = histcounts(sdat5.Polarity,ORedges);

ORctrs = ORedges(2:end)-(ORedges(2)-ORedges(1))/2;

OrManAve = mean(OrMan);
OrManSD = std(OrMan);

% Computed

OrCompAve = histcounts(CellProps.Magnitude,ORedges);
OrCompSD = zeros(size(OrCompAve));

%
figure
e1=errorbar(ORctrs,OrCompAve,OrCompSD,'-r');
e1.Marker = '.';
e1.MarkerSize = 15;
e1.LineWidth = 1.5;
hold on
e2=errorbar(ORctrs,OrManAve,OrManSD,'-b');
e2.Marker = '.';
e2.MarkerSize = 15;
e2.LineWidth = 1.5;
hold off

xlabel('Magnitude of Polarity (Unnormalized)','FontSize',fntsz);
ylabel('Cell Count','FontSize',fntsz);
legend('Computed','Manual');
set(gca,'FontSize',fntsz-2);
axis tight

% Computation statistics
figure 
x = categorical({'Manual','Computed'});
y = [MaveTime CaveTime]./60;
sd = [MsdTime CsdTime]./60;
bar(x,y)
hold on
er = errorbar(x,y,sd);
er.Color = 'k';
er.LineStyle = 'none';
er.LineWidth = 1.5;

ylabel('Calculation Time (min)','FontSize',fntsz)
set(gca,'FontSize',fntsz-2);