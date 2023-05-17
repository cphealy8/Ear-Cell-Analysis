function [CellsMask] = SelectCells(RawImage,BoundaryChannel,varargin)
%SELECTCELLS Generate binary mask selecting cells in an image.
%   Detailed explanation goes here
%% parse inputs
p = inputParser;

addRequired(p,'RawImage',@isnumeric);
addRequired(p,'BoundaryChannel',@ischar);
addParameter(p,'RemBoundCells',false,@islogical)

parse(p,RawImage,BoundaryChannel,varargin{:})

RemBoundCells = p.Results.RemBoundCells;
%%
Contrasted = localcontrast(RawImage);
% Next separate the channels
imR = Contrasted(:,:,1);
imG = Contrasted(:,:,2);
imB = Contrasted(:,:,3);

switch BoundaryChannel
    case 'Red'
        startIm = imR;
    case 'Green'
        startIm = imG;
    case 'Blue'
        startIm = imB;
    case 'All'
        startIm = rgb2gray(Contrasted);
end

%% 
% To segment the hair cells we will use the blue channel. The next step is 
% to apply a filter to reduce noise. We will compare a gaussian filter and a median 
% filter.

imMedian = medfilt2(startIm,5.*[1 1]);

%% 
% Notice how the illumination of each hair cell is different. To correct 
% this the median filtered image was flat fielded. This requires blurring the 
% image then subtracting the blurred image from the original. 
imFlat = imflatfield(imMedian,30);

%% 
% Of these flat-fielded images, the one that used sigma=100 gave the best 
% balance between leveling the illumination and preserving shape. If we apply 
% local contrasting again, the 
imFlatCon = localcontrast(imFlat,0.9,0.9);

%% 
% Finally the image can be adaptively thresholded to obtain a binary mask 
% indicating the position of hair cells. 
imBW = imbinarize(imFlatCon,0.4);


%% Watershed? (Connect the edges)
[imShed] = imWatershed(~imBW); % Connect the lines
imShedinv = ~imShed; % invert
NoHoles = imfill(imShedinv,'holes'); % fill holes
imSkel = bwmorph(~NoHoles,'thin',inf); % skeltonize

%% 
% Next we will apply a small binary close to solidify the cells followed 
% by a larger binary open to remove small pixel noise. Finally, a small dilation 
% will be applied to make sure that the selection includes the entire hair cells. 

% Close and invert
imClose = ~imclose(imSkel,strel('disk',3));
CellsMask = imerode(imClose,strel('disk',1));
% imOpen = imopen(imClose,strel('disk',8));
% imDil = imdilate(imOpen,strel('disk',2));

% Omit Boundary Features from further analysis
if RemBoundCells
CellsMask= imclearborder(CellsMask);
end

end

