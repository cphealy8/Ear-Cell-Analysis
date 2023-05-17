function [CroppedIm] = Crop2Mask(Image,Mask)
%CROP2MASK Crop an image to a region defined by a binary mask.

[nrow, ncol,depth] = size(Image);
[COL,ROW] = meshgrid(1:ncol,1:nrow);

rowmult = ROW.*Mask;
colmult = COL.*Mask;

rowmin = min(rowmult(rowmult~=0));
rowmax = max(rowmult(:));
colmin = min(colmult(colmult~=0));
colmax = max(colmult(:));

cropraw = Image(rowmin:rowmax,colmin:colmax,:);
cropmask = Mask(rowmin:rowmax,colmin:colmax);

CroppedIm = maskimage(cropraw,cropmask);

end

