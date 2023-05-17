function [imarr,masks] = ConvertToCompIms(varargin)
%CONVERTOCOMPIMS Convert image to image array based on binary mask
%   Prompts the user to select and image and a binary mask. The connected
%   components in the mask are used isolate subregions of the image that
%   are saved as individual images in an image array. Then prompts the user
%   to save the array. 

    [imarray,imfiles,impath]=uigetimages({'*.png','.jpg'},'Select Image File');
    [maskarray,maskfiles,maskpath] =uigetimages('*.bmp','Select Mask File',impath);

    im = imarray{1};
    
    mask = maskarray{1};
    
    
    
    labim = bwlabel(mask);
    imarr = labelSeparate(im,labim,'mask');
    imarr = imarr';
    

    nims = length(imarr);


    imRez = size(im);
    
    trueIm = true(imRez(1),imRez(2));
    idIm = reshape(1:(imRez(1).*imRez(2)),imRez(1:2));
    masks = labelSeparate(trueIm,labim,'mask');
    idIms = labelSeparate(idIm,labim,'crop');
    
    [~,root,~]=fileparts(imfiles{1});
    [~,mroot,~]=fileparts(maskfiles{1});
    
    if nargin>0
        nkeep = varargin{1};
        if nkeep>nims
            nkeep = nims;
            
        end
        
        rng(8)
        randrem = randsample(1:nims,nims-nkeep,false);
        imarr(randrem) = [];
        masks(randrem) = [];
        idIms(randrem) = [];
    end
    ims = imarr;
  
    
    defname = [root erase(mroot,root) '_SepIms.mat'];
    [file,path] = uiputfile('*.mat','Save image array',[impath defname]);
    save([path file],'ims');
    
    ims = masks;
    defname = [root erase(mroot,root) '_SepImsMask.mat'];
    [file,path] = uiputfile('*.mat','Save mask array',[impath defname]);
    save([path file],'ims','idIms','imRez');
end
