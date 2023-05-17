function [ax] = MyBullseye(theta,r,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% parse
p = inputParser;
addRequired(p,'r',@isnumeric);
addRequired(p,'theta',@isnumeric);
addParameter(p,'Units','radians',@ischar);
addParameter(p,'EllipseApprox',true,@islogical);
addParameter(p,'Color','r',@ischar);
addParameter(p,'Marker','o',@ischar);
addParameter(p,'MarkerSize',3,@isnumeric);

parse(p,theta,r,varargin{:})

Units = p.Results.Units;
EllipseApprox = p.Results.EllipseApprox;
Color = p.Results.Color;
Marker = p.Results.Marker;
MarkerSz = p.Results.MarkerSize;

% convert to radians if specified in degrees. 
if strcmp(Units,'degrees')
    theta = theta*2*pi/360;
end

%%
ax=polarplot(theta,r,'Color',Color,'MarkerFaceColor',Color,...
    'Marker',Marker,...
    'LineStyle','none',...
    'MarkerSize',MarkerSz);

if EllipseApprox
    [ex,ey] = pol2cart(theta,r);
    elF = fit_ellipse(ex,ey);
    eltheta = linspace(0,2*pi,100);
    elr = (elF.a*elF.b)./sqrt((elF.b*cos(eltheta)).^2+(elF.a*sin(eltheta)).^2);
    hold on
    polarplot(eltheta,elr,'-k')
end

end

