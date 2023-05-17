function [imgthr] = imthresh(img,varargin)
%IMTHRESH Summary of this function goes here
%   Detailed explanation goes here
% check image
if ~isRGB(img)&&~isGray(img)
    error('invalid image type. Image must be RGB or grayscale')
end
varg = varargin;
imgthr = img;

if varg{end}<1
    mult = 255;
else
    mult = 1;
end


if length(varg)==2 % range or greater than instance
    if isnumeric(varg{1})&&isnumeric(varg{2}) % range
        imgthr(imgthr<mult*varg{1}) = 0;
        imgthr(imgthr>mult*varg{2}) = 0;
    elseif isnumeric(varg{2})&&strcmpi(varg{1},'gt')
        imgthr(imgthr<=mult*varg{2}) = 0;
    elseif isnumeric(varg{2})&&strcmpi(varg{1},'lt')
        imgthr(imgthr>=mult*varg{2}) = 0;
    elseif isnumeric(varg{2})&&strcmpi(varg{1},'geq')
        imgthr(imgthr<mult*varg{2}) = 0;
    elseif isnumeric(varg{2})&&strcmpi(varg{1},'leq')
        imgthr(imgthr>mult*varg{2}) = 0;
    else
        error('Invalid thresholding params');
    end
elseif (length(varg)==1)&&isnumeric(varg{1}) % default
    imgthr(imgthr<mult*varg{1}) =0;
elseif length(varg)==3&&strcmpi(varg{1},'range')&&isnumeric(varg{2})&&isnumeric(varg{3})
    imgthr(imgthr<255*mult{2}) = 0;
    imgthr(imgthr>255*mult{3}) = 0;
else
    error('Invalid thresholding params');
end

end

