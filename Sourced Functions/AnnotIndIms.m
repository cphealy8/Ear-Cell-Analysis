function [Props] = AnnotIndIms(Props)
%ANNOTINDIMS Annotate individual cell images
%   Detailed explanation goes here
%%
nImages = height(Props);
lwd = 1;
MkSz = 4;
fw = waitbar(0,'Please wait...');
AnnotIms = cell(nImages,1);
for k=1:nImages
    fH = figure('visible',false);
    imshow(Props.RAW{k});
    hold on
    quiver(Props.LocalCenter(k,1),Props.LocalCenter(k,2),...
       Props.PBX(k),Props.PBY(k),0,...
       'LineWidth',lwd,'Color','w','ShowArrowHead','off',...
       'Marker','o','MarkerFaceColor','w','MarkerSize',MkSz )
    plot(Props.PBLocalCentroid(k,1),Props.PBLocalCentroid(k,2),'o',...
        'color','w','LineWidth',lwd,'MarkerSize',MkSz+2);
%     text(2,7,num2str(Props.ID(k)),'Color','w')
    F = getframe;
    close(fH)
    waitbar(k/nImages,fw,'Annotating Images');
    AnnotIms{k} = F.cdata;
end
close(fw)
Props.AnnotIm = AnnotIms;
end

