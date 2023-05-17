function [] = OrientOverlay(image,CellProps)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
[yrez xrez depth] = size(image);
imshow(image)
set(gca,'Units','normalized','Position',[0,0,1,1]);
axis normal

nHair = length(CellProps.Orientation);

arrowX = [CellProps.Centroid(:,1) CellProps.BBCentroid(:,1)]./xrez;
arrowY = 1-[CellProps.Centroid(:,2) CellProps.BBCentroid(:,2)]./yrez;

% impose boundary
arrowX(arrowX>1) = 1;
arrowX(arrowX<0) = 0;
arrowY(arrowY>1) = 1;
arrowY(arrowY<0) = 0;

for k = 1:nHair
    if CellProps.BBDetected(k)==1
    ann = annotation('arrow',arrowX(k,:),arrowY(k,:));
    
    if CellProps.Orientation(k)>0
    ann.Color = [208 28 139]./255;
    else
    ann.Color = [77 172 38]./255;
    end
    
    ann.HeadLength = 5;
    ann.HeadWidth = ann.HeadLength;
    ann.HeadStyle = 'vback1';
    end
    
end
end

