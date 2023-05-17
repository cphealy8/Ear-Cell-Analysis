[file,path] = uigetfile('*.bmp');
scale = 2;
im = imresize(imread(fullfile(path,file)),scale);

figure
vidname = strcat(file(1:end-4),'_CenterSelection','.mp4');
vidfile = VideoWriter(strcat('../Results/Videos/',vidname),'MPEG-4');
vidfile.FrameRate = 16;
vidfile.Quality = 100;

open(vidfile);
for k=1:ceil(scale*35)
    shrimage(:,:,k) = bwmorph(im,'shrink',k);
    imshow(imoverlay(im,shrimage(:,:,k),'r'));
    set(gca,'Position',[0.07 0.07 0.9 0.9]);
    F(k) = getframe(gcf);
    writeVideo(vidfile,F(k));
    
    
end
imshow(imoverlay(im,imdilate(shrimage(:,:,k),strel('disk',4)),'g'));
set(gca,'Position',[0.07 0.07 0.9 0.9]);
F(k+1) = getframe(gcf);
    writeVideo(vidfile,F(k+1));
close(vidfile)