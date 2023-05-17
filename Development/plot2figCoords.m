function [FigX,FigY] = plot2figCoords(xdata,ydata,axesHandle)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% Convert plot coordinate to axes coordinates
xlims = xlim(axesHandle);
ylims = ylim(axesHandle);

xmin = xlims(1);
ymin = ylims(1);

xrange = abs(diff(xlims));
yrange = abs(diff(ylims));

AxX = (xdata-xmin)/xrange;
AxY = (ydata-ymin)/yrange;

leftshift = axesHandle.Position(1);
botshift = axesHandle.Position(2);
axwidth = axesHandle.Position(3);
axheight = axesHandle.Position(4);

FigX = AxX*axwidth+leftshift;
FigY = AxY*axheight+botshift;
end

