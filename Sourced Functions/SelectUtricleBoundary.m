function [CellProps,BoundPts,imClose,UserPts] = SelectUtricleBoundary(RAW,varargin)
%SELECTUTRICLEBOUNDARY finds the boundary of the Utricle. 
%   [CellProps,BoundPts] = SELECTUTRICLEBOUNDARY(RAW,CellProps) compute the
%   utricular boundary given a RAW full color image and a table of Cell
%   properties. Compute the boundary points and reference angle for the
%   cells who's centroids are stored in cell points and append them to the 
%   CellProps Table.
%
%   [CellProps,BoundPts] =
%   SELECTUTRICLEBOUNDARY(RAW,CELLPROPS,'Smooth',fraction) sample a
%   fraction of the boundary points computed by SELECTUTRICLEBOUNDARY and
%   use these to compute the reference angles.
%
%   SELECTUTRICLEBOUNDARY(RAW,CellProps,'CloseFactor',factor) multiply the
%   size of the closing kernel by factor. The greater this factor the
%   smoother the utricular boundary will be. 

%% parse inputs
p = inputParser;

addRequired(p,'RAW');
% addRequired(p,'CellProps');

addParameter(p,'Smooth',0,@isnumeric);
addParameter(p,'CloseRad',1,@isnumeric);
addParameter(p,'MedFilt',100,@isnumeric);
addParameter(p,'GaussFilt',60,@isnumeric);
addParameter(p,'BWThresh',200,@isnumeric);
addParameter(p,'RefAngType','inverse',@ischar);
addParameter(p,'RefAngParams',2,@isnumeric);
addParameter(p,'CellProps',[],@istable);
checkSelectType = @(x) any(validatestring(x,{'Auto','Manual'}));
addParameter(p,'SelectType','Manual',checkSelectType);

parse(p,RAW,varargin{:})

smooth = p.Results.Smooth;
CloseRad = p.Results.CloseRad;
MedFiltR = p.Results.MedFilt;
GaussFilt = p.Results.GaussFilt;
BWThresh = p.Results.BWThresh;
RefAngType = p.Results.RefAngType;
RefAngParams = p.Results.RefAngParams;
CellProps = p.Results.CellProps;
SelectType = p.Results.SelectType;

[imX,imY,imZ] =size(RAW);

%%
switch SelectType
    case 'Auto'
        % contrast
        Contrasted = localcontrast(RAW);
        imK{1} = Contrasted;

        % Convert to grayscale
        Gray = rgb2gray(Contrasted);
        imK{2} = Gray;

        % Even illumination;
        imFlat = imadjust(imflatfield(Gray,1));
        imK{3} = imFlat;
        % Blur
        imMedian = imadjust(medfilt2(imFlat,MedFiltR.*[1 1],'symmetric'));
        imK{4} = imMedian;

        % Blur Again to smooth boundary
        imGauss = imadjust(imgaussfilt(imFlat,GaussFilt));
        imK{5} = imGauss;

        % Threshold
        imThresh = imGauss>=BWThresh;
        imK{6} = imThresh;

        % Fill small holes
        imClose = imclose(imThresh,strel('disk',CloseRad*round(numel(RAW)/2e4)));
        imK{7} = imClose;

        % Convert to single pixel boundary;
        imBound = bwmorph(imClose,'remove');
        imK{8}=imBound;

        % Delete boundary pixels
        imBound(:,1) = 0;
        imBound(1,:) = 0;
        imBound(:,end) = 0;
        imBound(end,:) = 0;

        % convert pixel boundary to points
        BoundPts = pix2pts(imBound);
        UserPts = BoundPts;
        correction = 180;
    case 'Manual'
        imClose = zeros(imX,imY);
        [BoundPts,UserPts] = GetBoundaryLine(RAW,'preview',true);
        correction = 0;
end

npts = length(BoundPts);

if smooth>0
    mpts = floor(npts.*smooth); 
    sampInd = datasample(1:npts,mpts,'Replace',false);
end

%% Display Results
if ~isempty(CellProps)
[~,CellProps.RefAngle] = pt2ptInfluence(CellProps.Centroid,BoundPts,RefAngType,RefAngParams);

CellProps.PixID = pts2pix(fliplr(CellProps.Centroid),size(imClose));
CellProps.InBound = imClose(CellProps.PixID);

CellProps.RefAngle(~CellProps.InBound)= CellProps.RefAngle(~CellProps.InBound)+correction;
end

% unitX = cosd(refAngle);
% unitY = sind(refAngle);
% 
% quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),unitX,unitY,0.3,'Color','w')
% 
% % Define a vector field for orientation
% cellX = cosd(CellProps.GlobalOrientation);
% cellY = sind(CellProps.GlobalOrientation);
% 
% quiver(CellProps.Centroid(:,1),CellProps.Centroid(:,2),cellX,cellY,0.3,'Color','m')
end