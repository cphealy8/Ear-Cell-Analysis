function [CellProps,imK,overlayK] = OrientHairCell_Fonticulus(CellProps,varargin)

%% Parse Inputs
p = inputParser;

addRequired(p,'CellProps',@istable);
addParameter(p,'Channel','R',@ischar);
addParameter(p,'ConSpecs',[0.1 1],@isnumeric);
addParameter(p,'Blur',2,@isnumeric);
addParameter(p,'ErodeRads',[2 4],@isnumeric);
addParameter(p,'BWThresh',0.8,@isnumeric);
addParameter(p,'AreaRng',[0.01 0.15],@isnumeric);
addParameter(p,'SolidRng',[0.7 1],@isnumeric);

parse(p,CellProps,varargin{:})

Channel = p.Results.Channel;
ConSpecs = p.Results.ConSpecs;
Blur = p.Results.Blur;
ErodeRads = p.Results.ErodeRads;
BWThresh = p.Results.BWThresh;
AreaRng = p.Results.AreaRng;
SolidRng = p.Results.SolidRng;

%%
switch Channel
    case 'R'
        SepCells = CellProps.CellImRed;
    case 'G'
        SepCells = CellProps.CellImGreen;
    case 'B'
        SepCells = CellProps.CellImBlue;
end

SepMask = CellProps.CellMask;
SepEllipse = CellProps.CellMaskEllipse;
nHair = length(SepMask); 

morFilt4 = cell(1,nHair);

imK = cell(12,nHair);
cnt = 0;
for k = 1:nHair
curIm = SepCells{k};
curMask = uint8(SepMask{k});
curEllipse = uint8(SepEllipse{k});
MaskArea = sum(sum(curMask));
% [ydim(k) xdim(k)] = size(curIm);

imK{1,k}=curIm;

conIm = imadjust(curIm,ConSpecs).*curEllipse;
blurIm = imadjust(medfilt2(conIm)).*curEllipse;
flatIm = imadjust(medfilt2(imflatfield(blurIm,Blur))).*curEllipse;
erodeIm1 = imadjust(imerode(flatIm,strel('disk',ErodeRads(1))));
invertIm = imadjust(imcomplement(erodeIm1).*curEllipse);
erodeIm2 = imadjust(invertIm.*imerode(curEllipse,strel('disk',ErodeRads(2))));
bwIm = imbinarize(localcontrast(erodeIm2),BWThresh);

imK{2,k}=conIm;
imK{3,k}=blurIm;
imK{4,k}=flatIm;
imK{5,k}=erodeIm1;
imK{6,k}=invertIm;
imK{7,k}=erodeIm2;
imK{8,k} = bwIm;

% Filter by region properties
% Filtering by eccentricity will reduce the options to only the most
% circular regions.
morFilt1 = bwpropfilt(bwIm,'Area',[5 1000]); % Remove single pixel noise.
% Size-based area filtration.
morFilt2 = bwpropfilt(morFilt1,'Area',AreaRng.*MaskArea);
morFilt3 = bwpropfilt(morFilt2,'Solidity',SolidRng);
morFilt4{k} = bwpropfilt(morFilt3,'Area',1,'Largest');

imK{9,k} = morFilt1;
imK{10,k}=morFilt2;
imK{11,k}=morFilt3;
imK{12,k}=morFilt4{k};

if sum(morFilt4{k}(:))>0
    cnt = cnt+1;
    overlayK{cnt}=labeloverlay(curIm,morFilt4{k});
end

% montage(imK)

% Omit Extras

% overlay{k} = imoverlay(curIm,morFilt4{k},'r');

end

CellProps = BBOrient(CellProps,morFilt4,'F');
CellProps.imFont = morFilt4';
end
