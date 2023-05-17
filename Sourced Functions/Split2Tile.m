function [tile,x,y] = Split2Tile(im,tilewidth,varargin)
%SPLIT2TILE Split an image into equally sized tiles and stores them in cell
%array
%   [tile,x,y] = Split2Tile(im,tilewidth) splits im into tiles with
%   dimensions tilewidth-by-tilewidth. Stores each in the cell array tile
%   and outputs the coordinates of the upperleft corner of each tile in the
%   original image, x and y.
%
%   [tile,x,y] = Split2Tile(im,tilewidth,'SaveDir',pwd) saves each tile as
%   a separate image in the directory specified after 'SaveDir' in this
%   instance saves the image to the current directory. 
%
%   Author: Connor P. Healy (connor.healy@utah.edu)
%   July 12,2021

%% parse inputs
p = inputParser;
addRequired(p,'im');
addRequired(p,'tilewidth',@isnumeric);
addParameter(p,'SaveDir',[]);
addParameter(p,'FileRoot','im',@ischar);
parse(p,im,tilewidth,varargin{:});

SaveDir = p.Results.SaveDir;
FileRoot = p.Results.FileRoot;
%% Get splitting indices
tilewidth = tilewidth-1;
[Wx,Wy,nchann]=size(im);

x = floor(linspace(1,Wx-tilewidth,ceil(Wx/tilewidth)));
y = floor(linspace(1,Wy-tilewidth,ceil(Wy/tilewidth)));

% Tile the image
for i=1:length(x)
    for j=1:length(y)
        tile{i,j}=im(x(i):x(i)+tilewidth,y(j):y(j)+tilewidth,:);
    end
end

if ~isempty(SaveDir)
    ttile = tile(:);
    mkdir(SaveDir)
    zspec = sprintf('%%0%dd',ceil(log10(length(ttile)))); % leading zeros
    
    for k=1:length(ttile)
        imid = sprintf(zspec,k);
        imname = strjoin({FileRoot,'_',imid,'.png'},'');
        imwrite(tile{k},fullfile(SaveDir,imname));
    end
    
    save(fullfile(SaveDir,'tiledata.mat'),'tile','x','y');
end

end

