im = zeros(100);

im(1:10,46:55) = 1;
im(91:end,46:55) = 1;
im(46:55,1:10) = 1;
im(46:55,91:end) = 1;
im(46:55,46:55) = 1;
im = logical(im);

imshow(im)

[BPts,bmap] = BoundPix(im);
figure
imshow(bmap)

CellProps = regionprops(im,'PixelIdxList');

pixIDs = struct2cell(regionprops(im,'PixelIdxList'));

test = IsOnBoundary(pixIDs,BPts)