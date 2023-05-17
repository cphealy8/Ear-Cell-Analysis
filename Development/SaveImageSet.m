function [outputArg1,outputArg2] = SaveImageSet(imSet,root,savedir)
%SAVEIMAGESET Save a set of images. 
%   Detailed explanation goes here
ID = 0;
numIms = length(imSet);
numLvls = length(num2str(numIms));
IDspec = sprintf('%%0%1dd',numLvls);

for k = 1:length(imSet)
    CurIm = imSet{k};
    ID = ID+1;
    filename = strcat(root,'_',sprintf(IDspec,ID),'.png');
    fullname = fullfile(savedir,filename);
    imwrite(CurIm,fullname);
end
end

