function [outim] = CropCellIms(cellim,xInds,yInds)
%CROPCELLIMS Crop all images stored in cell array
%   Detailed explanation goes here

for k=1:length(cellim)
    curIm = cellim{k};
    outim{k} = curIm(xInds,yInds);
end

end

