function [outputImage] = PhotoFilter(baseImage,topImage,Filter)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%% preprocess inputs
if isa(baseImage,'uint8')&&isa(topImage,'uint8')
    baseImage = double(baseImage)/255;
    topImage = double(topImage)/255;
    converttype = 'uint8';
elseif max(baseImage(:))<=1&&max(topImage(:))<=1&&min(baseImage(:)>=0)&&min(topImage(:)>=0)
    converttype = 'rgb';
else
    error('Invalid image type. Must either be uint8 or double ranging between 0 and 1')
end

%% Apply Filters
switch Filter
    case 'multiply'
        outputImage = MultiplyFilter(baseImage,topImage);
    case 'screen'
        outputImage = ScreenFilter(baseImage,topImage);
    case 'overlay'
        outputImage = OverlayFilter(baseImage,topImage);
    case 'hardlight'
        outputImage = OverlayFilter(topImage,baseImage);
end

%% Prep outputs
switch converttype
    case 'uint8'
    outputImage = uint8(255.*outputImage);
    case 'rgb'
    outputImage(outputImage<0) = 0;
    outputImage(outputImage>1) = 1;
end
end

function [outputImage] = MultiplyFilter(baseImage,topImage)
    outputImage = baseImage.*topImage;
end

function [outputImage] = ScreenFilter(baseImage,topImage)
    outputImage = 1-(1-baseImage).*(1-topImage); 
end

function [outputImage] = OverlayFilter(baseImage,topImage)
    outputImage =1-2.*(1-baseImage).*(1-topImage);
    multImage = 2*MultiplyFilter(baseImage,topImage);

    pixreplace = baseImage<0.5;

    outputImage(pixreplace) = multImage(pixreplace);
end