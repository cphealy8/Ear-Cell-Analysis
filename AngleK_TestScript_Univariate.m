% Generate a set of vectors with random angles, magnitudes, and
% origins.
clc; clear; close all;
addpath('Sourced Functions')
%% Test Set
  
% origin = rand(numvecs,2); % Random
% origin = [linspace(0,1,numvecs)' linspace(0,1,numvecs)']; % Uniformly spaced
angle = (pi/2)*rand(numvecs,1); % Randomly oriented [=] in radians
% angle = 2*pi*ones(numvecs,1); % Uniformly oriented [=] in radians
% angle(1:numvecs/2)= pi;
magnitude = rand(numvecs,1);

vec = table(origin,angle,magnitude);

%% Compute unit vector components
[xcomp,ycomp] = ComputeComponents(vec.magnitude,vec.angle,'unit');
vec.xcomponent = xcomp;
vec.ycomponent = ycomp;

%% Compute the pairwise distance matrix between the vector origins
Distances = pairdist(vec.origin,vec.origin);


%% Local Alignment
scale = 0.05;

% This function can be used to compute the alignment of each feature with
% respect to neighbors at a given scale. 
alignment= LocalAlignment(scale,Distances,[xcomp ycomp]);
%% Average Alignment
% This gives the alignment of the full population at a given scale r. This
% is the Angle K measurement for a given scale. 
AveAlignment = mean(alignment,'omitnan');

%% Angle K(r) (univariate)
% If we loop the previous two functions over r we get the full angle K
% description.
scales = linspace(0,0.5,21);
scales(1) = []; % Omit the first scale because it's pointless
Kuu = AngleK(scales,vec);

%% Display results
figure
gap = [0.1 0.1];
subtightplot(1,2,1,gap)
quiver(vec.origin(:,1),vec.origin(:,2),vec.xcomponent,vec.ycomponent,0.5,'Color','b')
grid on
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);

hold on

plot(vec.origin(:,1),vec.origin(:,2),'.b','MarkerSize',10)
title('Input Vector Field')
axis([0 1 0 1])
axis square

subtightplot(1,2,2,gap)
plot([0 scales(end)],[0 0],'-k','LineWidth',2)
hold on
plot(scales,Kuu,'.-b','LineWidth',2,'MarkerSize',10)
xlabel('Scale (r)')
ylabel('\kappa_{uu}(r)')
axis([0 max(scales) -1 1])
axis square
title('Population Alignment')