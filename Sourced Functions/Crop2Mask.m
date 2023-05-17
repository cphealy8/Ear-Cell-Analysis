function [CroppedIm,cropmask,pxrows,pxcols] = Crop2Mask(Image,inMask)
%CROP2MASK Crop an image to a region defined by a binary mask.

nMasks = length(inMask);

if iscell(inMask)
    for k=1:nMasks
    Mask =  double(inMask{k});

    [nrow, ncol,depth] = size(Image);
    [COL,ROW] = meshgrid(1:ncol,1:nrow);

    rowmult = ROW.*Mask;
    colmult = COL.*Mask;

    rowmin = min(rowmult(rowmult~=0));
    rowmax = max(rowmult(:));
    colmin = min(colmult(colmult~=0));
    colmax = max(colmult(:));
    
    pxrows = rowmin:rowmax;
    pxcols = colmin:colmax;

    cropraw = Image(pxrows,pxcols,:);
    cropmask{k} = Mask(pxrows,pxcols);

    CroppedIm{k} = maskimage(cropraw,cropmask{k});
    end
else
Mask =  double(inMask);

[nrow, ncol,depth] = size(Image);
[COL,ROW] = meshgrid(1:ncol,1:nrow);

rowmult = ROW.*Mask;
colmult = COL.*Mask;

rowmin = min(rowmult(rowmult~=0));
rowmax = max(rowmult(:));
colmin = min(colmult(colmult~=0));
colmax = max(colmult(:));

pxrows = rowmin:rowmax;
pxcols = colmin:colmax;

cropraw = Image(pxrows,pxcols,:);
cropmask = Mask(pxrows,pxcols);

CroppedIm = maskimage(cropraw,cropmask);
end
end

