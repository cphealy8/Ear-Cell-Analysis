function [DatMap,fig,ax,cax,sld] = DataMapSlider(x,yy,mask)
%DATAMAPSLIDER slide through values of x and y-values (yy) corresponding to
%each on the datamap (mask). 

%% Compute all Data maps
for k=1:length(x)
datmap = DataMap(mask,yy(:,k),'Display',false);
DatMap{k} = datmap;
end

%% Generate Slider
xmin = min(x);
xmax = max(x);

[startval,startind] = FindNear((xmax-xmin)/2,x);


mapsz = size(mask);
ARatio = mapsz(1)/mapsz(2);

fig = uifigure('Position',[50 50 765 600*ARatio]);
ax = uiaxes(fig,'Position',[10 50 500*ARatio-10 540]);
imagesc(ax,DatMap{startind});
axis(ax,'tight')
[cax]=colorbar(ax);
caxis(ax,[min(yy(:)) max(yy(:))])
% cg = uigauge(fig,'Position',[100 100 120 120]);

sld = uislider(fig,...
               'Value',startval,...
               'Limits',[xmin xmax],...
               'Position',[(300*ARatio)-(200/2) 30 200 3],...
               'ValueChangingFcn',@(sld,event) sliderMoving(event,ax,DatMap,x));

end

% Create ValueChangingFcn callback
function sliderMoving(event,ax,datmap,x)
slVal = event.Value;
[~,slID] = FindNear(slVal,x);
imagesc(ax,datmap{slID});
axis(ax,'tight')
end