function [rgb] = hex2rgb(hex)
%HEX2RGB convert hexadecimal code to rgb color. 
%   Detailed explanation goes here
rgb = sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;
end

