function [CellProps,imK,overlayK] = OrientHairCell_BB(CellProps,varargin)
%% Parse Inputs
p = inputParser;

addRequired(p,'CellProps',@istable);
addParameter(p,'Channel','B',@ischar);
addParameter(p,'MedFilt',2,@isnumeric);
addParameter(p,'BWThresh',0.8,@isnumeric);
addParameter(p,'CloseRad',5,@isnumeric);
addParameter(p,'DilateRad',1,@isnumeric);

parse(p,CellProps,varargin{:});

Channel=p.Results.Channel;
MedFiltR = p.Results.MedFilt;
BWThresh = p.Results.BWThresh;
CloseRad = p.Results.CloseRad;
DilateRad = p.Results.DilateRad;

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
    imK{1,n}= CellIm;
    
    bChann = imadjust(CellIm(:,:,ChanNum));
    imK{2,n}= bChann;
    
    bIsolate = imadjust(ChannelIsolate(CellIm,Channel));
    imK{3,n}= bIsolate;
    
    % Median filter to reduce noise
    medFilt = imadjust(medfilt2(bIsolate,MedFiltR.*[1 1]));
    imK{4,n} = medFilt;
    
    % Threshold and Binarize
    imBW = imbinarize(medFilt,BWThresh);
    imK{5,n} = imBW;
    
    % Solidify
    imSolid = imdilate(imclose(imBW,strel('disk',CloseRad)),strel('disk',DilateRad));
    imK{6,n} = imSolid;
    
    % Select largest 
    imBB{n} = bwpropfilt (imSolid,bChann,'MeanIntensity',1);
%     imshowpair(bChann,imBB{n},'montage')

    imK{7,n} =imBB{n};
    
%     montage(imK)

if sum(imBB{n}(:))>0
    cnt = cnt+1;
    overlayK{cnt}=labeloverlay(bChann,imBB{n});
end

end
CellProps = BBOrient(CellProps,imBB,'BB');
CellProps.imBB = imBB';
end
