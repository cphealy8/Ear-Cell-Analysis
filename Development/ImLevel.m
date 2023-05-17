function [LeveledIm] = ImLevel(im,magnitude)
%IMLEVEL Correct uneven illumination in an image. 
%   [LeveledIm] = ImLevel(im,magnitude) levels the input image (im) at a
%   magnitude equal to (magnitude) and outputs the Leveled Image
%   (LeveledIm). 
dims = length(size(im));

switch dims
    case 2 %grayscale
        %% Leveling
        imBlur = imgaussfilt(im,magnitude);
        imEven = double(im)./double(imBlur);
        maxPix = max(imEven(:));
        
        %% Thresholding
        lowThresh = prctile(imEven(:),1);
        highThresh = prctile(imEven(:),99);

        %% Binary operations
        LeveledIm = uint8(255*(imEven-lowThresh)/(highThresh-lowThresh));
        
    case 3 %color
        for n = 1:dims
            LeveledIm(:,:,n) = ImLevel(im(:,:,n),magnitude);
        end
end
end

