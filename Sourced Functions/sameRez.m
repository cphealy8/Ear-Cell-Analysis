function [test] = sameRez(imA,imB)
%SAMEREZ 
%   Detailed explanation goes here

[ax,ay,az]= size(imA);
[bx,by,bz]=size(imB);

if ax==bx&&ay==by
    test = true;
else
    test = false;
end

end

