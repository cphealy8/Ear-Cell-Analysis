function [imageOut] = ChannelIsolate(image,channel,varargin)
%CHANNELISOLATE Isolate a channel in an rgb image.
%   [imageOut] = ChannelIsolate(image,channel) subtracts the unselected
%   channels from the input image. channel must be either 'green', 'red',
%   or 'blue'.

r = image(:,:,1);
g = image(:,:,2);
b = image(:,:,3);

if nargin==3 && strcmp(varargin{1},'contrast')
    r = imadjust(r);
    g = imadjust(g);
    b = imadjust(b);
end


if ~isa(image,'uint8')
    error('Input must be an RGB image')
end


if ismember(channel,{'R','red','Red','RED','r'})
    imageOut = imsubtract(imsubtract(r,b),g);
elseif ismember(channel,{'B','blue','Blue','b','BLUE'})
    imageOut = imsubtract(imsubtract(b,r),g);
elseif ismember(channel,{'G','g','green','Green','GREEN'})
    imageOut = imsubtract(imsubtract(g,b),r);
else
    error('Invalid channel Identifier')
end

end

