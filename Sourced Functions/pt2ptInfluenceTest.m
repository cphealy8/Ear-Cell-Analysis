clc; clear; close all;

% refx = -10:10;
% refy = refx;
% refline = [refx' refy'];

% [XX,YY] = meshgrid(refx,refy);
% respts =[XX(:) YY(:)];

refx = -10:10;
% refy = -abs(refx)+10;
refy = 5*sin(refx/4);
refline = [refx' refy'];

spacer = linspace(refx(1),refx(end),11);
[XX,YY] = meshgrid(spacer,spacer);
respts =[XX(:) YY(:)];

% xpts = linspace(-4.5,4.5,7);
% ypts = ones(1,length(xpts))*5.5;
% respts = [xpts;ypts]';



plot(refx,refy,'-or','LineWidth',2)
hold on 
plot(respts(:,1),respts(:,2),'.b')
ax = gca;

[refMagnitude,refAngle,aveX,aveY] = pt2ptInfluence(respts,refline,'none');

unitX = cosd(refAngle);
unitY = sind(refAngle);

quiver(respts(:,1),respts(:,2),unitX,unitY,0.5)
% quiver(respts(:,1),respts(:,2),aveX,aveY)
axis tight
axis equal

legend('Reference Line','Response Points','Orientation Vectors','Location','SouthOutside')
