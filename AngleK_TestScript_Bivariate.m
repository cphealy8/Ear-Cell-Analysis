% Generate a set of vectors with random angles, magnitudes, and
% origins.
clc; clear; close all;
addpath('Sourced Functions')
%% Test Set
totfeats = 100;
fracA = 0.09;
numvecsA = round(totfeats*fracA);
numvecsB = totfeats-numvecsA;

% set A
vecA = table();
% vecA.origin = rand(numvecsA,2); % Random
vecA.origin = UniformCoords([0.1 0.9],[0.1 0.9],sqrt(numvecsA),sqrt(numvecsA));
vecA.origin = vecA.origin+rangeRand(size(vecA.origin),-0.05,0.05); % noise

vecA.angle = zeros(numvecsA,1);
% vecA.angle = vecA.angle+rangeRand([numvecsA 1],-0.1745,0.1745); % noise

vecA.magnitude = 0.05*ones(numvecsA,1);
[vecA.xcomponent,vecA.ycomponent] = ComputeComponents(vecA.magnitude,vecA.angle,'unit');

% set B
vecB = table();
originB1 = ClusterCoords(vecA.origin,0.05,4,'uniform');
originB2 = ClusterCoords(vecA.origin,0.1,4,'uniform');
originB1 = originB1+rangeRand(size(originB1),-0.05,0.05); % noise
originB2 = originB2+rangeRand(size(originB2),-0.05,0.05); % noise

angleB1 = zeros(length(originB1),1);
angleB1 = angleB1+rangeRand([length(originB1) 1],-0.1745,0.1745); % noise
angleB2 = pi*ones(length(originB2),1);
angleB2 = angleB2+rangeRand([length(originB2) 1],-0.1745,0.1745); % noise

vecB.origin = [originB1; originB2];
vecB.angle = [angleB1; angleB2];
vecB.magnitude = 0.05*ones(length(vecB.angle),1);
[vecB.xcomponent,vecB.ycomponent] = ComputeComponents(vecB.magnitude,vecB.angle,'unit');

%% Compute the pairwise distance matrix between the vector origins
Distances = pairdist(vecA.origin,vecB.origin);

%% Local Alignment
scale = 0.4;

% This function can be used to compute the alignment of each feature with
% respect to neighbors at a given scale. 
alignment= LocalAlignment(scale,Distances,[vecA.xcomponent vecA.ycomponent],[vecB.xcomponent vecB.ycomponent]);


%% Angle K(r) (univariate)
% If we loop the previous two functions over r we get the full angle K
% description.
scales = linspace(0,0.5,21);
scales(1) = []; % Omit the first scale because it's pointless
Kab = AngleK(scales,vecA,vecB);
Kba = AngleK(scales,vecB,vecA);

%% Derivative of Angle K
dKab = gradient(Kab)./gradient(scales);
dKba = gradient(Kba)./gradient(scales);

%% Display results
gap = [0.1 0.1];
subtightplot(1,3,1,gap)
quiver(vecA.origin(:,1),vecA.origin(:,2),vecA.xcomponent,vecA.ycomponent,0.5,'Color','b')
hold on
quiver(vecB.origin(:,1),vecB.origin(:,2),vecB.xcomponent,vecB.ycomponent,0.5,'Color','r')
plot(vecA.origin(:,1),vecA.origin(:,2),'.b','MarkerSize',10)
plot(vecB.origin(:,1),vecB.origin(:,2),'.r','MarkerSize',10)
title('Input Vector Field')
legend('A-Type','B-Type','Location','SouthOutside','Orientation','horizontal')
grid on
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
axis([0 1 0 1])
axis square

subtightplot(1,3,2,gap)
plot(scales,Kab,'.-b','LineWidth',2,'MarkerSize',10)
hold on
plot(scales,Kba,'--.r','LineWidth',2,'MarkerSize',10)
xlabel('Scale (r)')
ylabel('Population Alignment')
legend('\kappa_{ab}','\kappa_{ba}','Location','SouthOutside','Orientation','horizontal')
axis([0 max(scales) -1 1])
axis square
grid on
title('Population Alignment')

subtightplot(1,3,3,gap)
plot(scales,dKab,'.-b','LineWidth',2,'MarkerSize',10)
hold on
plot(scales,dKba,'--.r','LineWidth',2,'MarkerSize',10)
xlabel('Scale (r)')
ylabel('Population Alignment')
legend('\kappa_{ab}','\kappa_{ba}','Location','SouthOutside','Orientation','horizontal')
% axis([0 max(scales) -1 1])
axis square
grid on
title('Population Alignment (derivative)')