function [im] = PolOriPixPt(Polarity,Orientation,Rez,varargin)
%POLORIPIXPT Convert a polarity (0 to 1) and orientation (degrees) to a
%single pixel in a binary image with Resolution (Rez by Rez) as though
%plotting on a polar plot. Optional, specify a 4th argument 'pxradius' to
%dilate the pixel image by an amount equal to pxradius. 
%   Detailed explanation goes here
%% parse
p = inputParser;
addRequired(p,'Polarity',@isnumeric)
addRequired(p,'Orientation',@isnumeric)
addRequired(p,'Rez',@isnumeric)
addParameter(p,'pxradius',1,@isnumeric);
checkKernType = @(x) any(validatestring(x,{'gaussian','circle'}));
addParameter(p,'kernType','gaussian',@ischar);

parse(p,Polarity,Orientation,Rez,varargin{:});

pxradius = p.Results.pxradius;
kernType = p.Results.kernType;
%%
im = false(Rez);

maxR = Rez/2;
if Polarity>1
    Polarity=1;
    warning('Polarity greater than 1 detected')
end

polr = Polarity*maxR;


ctr = [maxR maxR];
xcomp = polr.*cosd(Orientation);
ycomp = polr.*sind(Orientation);



pixpt = ctr+[xcomp ycomp];


pixID = pts2pix(pixpt,[Rez Rez]);

im(pixID) = true;

if pxradius>1
    switch kernType
        case 'circle'
            im = conv2(im,CircKern(pxradius),'same');
        case 'gaussian'
            im = conv2(im,fspecial('gaussian',pxradius,pxradius/6),'same');
    end
end

im = rot90(im); % To match standard orientation conventions. 
end

