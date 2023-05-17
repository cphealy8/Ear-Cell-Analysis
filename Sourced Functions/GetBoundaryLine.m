function [BoundPts,UserPts,fH,ax] = GetBoundaryLine(im,varargin)
%GETBOUNDARYLINE manually select boundary line for vestibular system
%analysis
%   [BoundPts,UserPts] = GetBoundaryLine(im) displays the image and prompts
%   the user to click to define the boundary, by default adds padding to
%   the edge of the image to permit the boundary to exceed the image
%   bounds. Additionally, a default cubic interpolation is applied.
%   BoundPts is the calculated boundary line with the interpolation,
%   UserPts are the coordinates of the points the user selected. 
%
%   [BoundPts,UserPts] = GetBoundaryLine(im,'Interp','none') turns off
%   interpolation and returns exactly the points the user selected.
%
%   BoundPts = GetBoundaryLine(im,'ndiv',50) by default the number of
%   divisions between user selected points used in interpolation is 20.
%   Specify the ndiv argument to change this number. 
%
%   BoundPts = GetBoundaryLine(im,'pad',false) turn off the image padding
%   that is on by default. 
%
%   BoundPts = GetBoundaryLine(im,'closeselection',true) by default the
%   selection is not closed. To close the selection pass true with the
%   close selection argument. 
%
%
%% parse inputs
p = inputParser;
addRequired(p,'im')
validInterps = {'none','cubic'};
checkInterp = @(x) any(validatestring(x,validInterps));
addParameter(p,'Interp','cubic',checkInterp);
addParameter(p,'ndiv',0.05,@isnumeric);
addParameter(p,'pad',true,@islogical);
addParameter(p,'closeselection',false,@islogical);
addParameter(p,'preview',false,@islogical);
addParameter(p,'dispcenters',[],@isnumeric); % display vector map given starting points of vectors

parse(p,im,varargin{:});

Interp = p.Results.Interp;
ndiv = p.Results.ndiv;
pad = p.Results.pad;
closeselection=p.Results.closeselection;
preview = p.Results.preview;

dispcenters = p.Results.dispcenters;

[imx,imy,imz]=size(im);

%% pad if requested
if pad
    padsize = [ceil(imx/10) ceil(imy/10) 0];
    im = padarray(im,padsize,0);
end

[pimx,pimy,pimz]=size(im);
%%
answer = 'No';


questdlg('Click to select boundary points. Backspace to remove. Enter to finish','','OK','OK')
while strcmp(answer,'No')
fH=figure;
ax=imshow(im);
hold on
xline(pimy/2,'-w')
yline(pimx/2,'-w');
hold off

roi=drawpolyline;
UserPts = roi.Position;
% xq = linspace(UserPts(1,1),UserPts(end,1),npts);
close(fH);

%% Compute interpolation
switch Interp
    case 'none'
        BoundPts = UserPts;
    case 'cubic'
      xy = UserPts';
    %
    %  Repeat the first column at the end so the polygon closes.
    if closeselection
      xy = [ xy, [ xy(:,1) ] ];
    end

      [ m, n ] = size ( xy );
    %
    %  Consider the point index 1:N as the independent variable for X and Y.
    %
      s = ( 1 : n )';
    %
    %  Prepare to evaluate the spline function at a grid 20 times finer.
    %
%       t = ( 1 : 1/ndiv : n )';
      
      dist = sqrt(sum(diff(xy').^2,2))';
      ppspan = ceil(dist.*ndiv);
      
      t=difflinspace(1:n,ppspan)';
    %
    %  Compute splines U and V that treat X and Y as functions of the index.
    %
      u = spline ( s, xy(1,:), t );
      v = spline ( s, xy(2,:), t );
      
    BoundPts = [u v];
    

end

if ~isempty(dispcenters)
    [~,RefAngle,~,~] = pt2ptInfluence(dispcenters+padsize(2:-1:1),BoundPts,'inverse',2);
end

%% Preview results
fH2 = figure;
imshow(im)
hold on
plot(BoundPts(:,1),BoundPts(:,2),'.-r')
plot(UserPts(:,1),UserPts(:,2),'.b','MarkerSize',15)
xline(pimy/2,'-w')
yline(pimx/2,'-w');

if ~isempty(dispcenters)
    quiver(dispcenters(:,1)+padsize(2),dispcenters(:,2)+padsize(1),cosd(RefAngle),-sind(RefAngle),'Color','w','Linewidth',1.5)
end
hold off

answer = questdlg('Accept?', ...
    'Boundary Line Interpolation', ...
    'Yes','No','Cancel','Cancel');
close(fH2)
end

%% correct padding
BoundPts = BoundPts-padsize(1:2);


end

function [out] = difflinspace(v,n)
out = [];
for k=1:length(n)
    out = [out linspace(v(k),v(k+1),n(k))];
end
end