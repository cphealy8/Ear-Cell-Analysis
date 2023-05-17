function [] = OrientOverlay_old(image,CellProps)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
rez = size(image);
imshow(image)
set(gca,'Units','normalized','Position',[0,0,1,1]);
axis normal

nHair = length(CellProps.Orientation);

for k = 1:nHair
    if CellProps.BBDetected(k)==1
    arrowX = [CellProps.Centroid(k,1) CellProps.BBCentroid(k,1)]./rez(2);
    arrowY = 1-[CellProps.Centroid(k,2) CellProps.BBCentroid(k,2)]./rez(1);
    
    ann = annotation('arrow',arrowX,arrowY);
    
    if CellProps.Orientation(k)>0
    ann.Color = [208 28 139]./255;
    else
    ann.Color = [77 172 38]./255;
    end
    
    ann.HeadLength = 10;
    ann.HeadWidth = ann.HeadLength;
    ann.HeadStyle = 'vback1';
    end
    
end
end

