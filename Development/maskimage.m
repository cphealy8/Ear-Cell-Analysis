function [maskedimage] = maskimage(image,mask)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

[~,~,depth] = size(image);

maskedimage = double(image).*repmat(double(mask),[1 1 depth]);
if isa(image,'uint8')
    maskedimage = uint8(maskedimage);
elseif isa(image,'logical')
    maskedimage = logical(maskedimage);
else
    error('Image must be uint8 or logical.')
end

end

