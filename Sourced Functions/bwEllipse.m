function [im,sepmasks] = bwEllipse(Resolution,Centers,MajorAxes,MinorAxes,Angles,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
zeroes = zeros(Resolution(1),Resolution(2),3);
im = zeroes;
nEllipses = length(MajorAxes);

fW= waitbar(0,'Ellipsifying...');
nr = length(Angles);

for n=1:nEllipses
    xcoord = Centers(n,1);
    ycoord = Centers(n,2);
    MajorAxis = MajorAxes(n);
    MinorAxis = MinorAxes(n);
    Angle = Angles(n);
    
%     im = draw_ellipse(ycoord,xcoord,MajorAxis/2,MinorAxis/2,-1*Angle,zeroes,[255 255 255]);
    
    ellipses = draw_ellipse(ycoord,xcoord,MajorAxis/2,MinorAxis/2,-1*Angle,zeroes,[255 255 255]);
    if nargin==6
        sepmask = [];
    else
        sepmasks{n} = imbinarize(rgb2gray(ellipses));
    end
    im = im+ellipses;
    
    waitbar(n/nr,fW,'Ellipsifying...')
end
close(fW)

im(im>0)=1;
im = imbinarize(rgb2gray(uint8(im)));

end

