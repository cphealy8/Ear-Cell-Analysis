function [CellProps] = OrientSupportCell_BB(CellProps,varargin)
%% Parse Inputs
p=inputParser;

addRequired(p,'CellProps',@istable);
addParameter(p,'Channel','B',@ischar);
addParameter(p,'MedFilt',2,@isnumeric);
addParameter(p,'BWThresh',0.6,@isnumeric);
addParameter(p,'CloseRad',2,@isnumeric);

parse(p,CellProps,varargin{:})

Channel = p.Results.Channel;
MedFiltR = p.Results.MedFilt;
BWThresh = p.Results.BWThresh;
CloseRad = p.Results.CloseRad;

%%
nCells = length(CellProps.Area);
imBB = cell(1,nCells);

Channs = {'R','G','B'};
channums = 1:3;
ChanNum = channums(strcmp(Channs,Channel));
cnt=0;
imK=cell(7,nCells);

for n = 1:nCells
    CellIm = CellProps.CellIm{n};
    imK{1}=CellIm;
%     [ydim(n) xdim(n)] = size(CellIm);
    bChann = imadjust(CellIm(:,:,ChanNum));
    imK{2}=bChann;
    
    bIsolate = imadjust(ChannelIsolate(CellIm,Channel));
    imK{3}=bIsolate;
    
    % Median filter to reduce noise
    medFilt = imadjust(medfilt2(bIsolate,MedFiltR.*[1 1]));
    imK{4} = medFilt;
    
    % Threshold and Binarize
    imBW = imbinarize(medFilt,BWThresh);
    imK{5} = imBW;
    
    % Solidify
    imSolid = imclose(imBW,strel('disk',CloseRad));
    imK{6} = imSolid;
    
    % Select largest 
    imBB{n} = bwpropfilt(imSolid,'Area',1);
    imK{7}=imBB{n};
%     imshowpair(bChann,imBB{n},'montage')
%     montage(imK);

if sum(imBB{n}(:))>0
    cnt = cnt+1;
    overlayK{cnt}=labeloverlay(bChann,imBB{n});
end
end

CellProps = BBOrient(CellProps,imBB,'BB');
CellProps.imBB = imBB';
end
