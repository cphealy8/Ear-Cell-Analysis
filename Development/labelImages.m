function [LDat] = labelImages(imDir,categories,mappedKeys,startID,varargin)
%labelImages Summary of this function goes here
%   Detailed explanation goes here

% Display a guide for labeling. 
f = figure('Units','Inches','Position',[3 3 2 4]);
thand = uitable(f,'Data',[mappedKeys,categories]);
thand.ColumnName = {'Key','Category'};

imDir = fullfile(imDir,'*.png'); % pattern to match filenames.

imDS = imageDatastore(imDir);

% Optional mask applied
if nargin==5
    maskDS = imageDatastore(varargin{1});
end


% Loop through the datastore.
ID = startID;

f2 = figure('Units','Inches','Position',[5.5,3,4,4]);
while hasdata(imDS)
    CurIm = readimage(imDS,ID);
    
    if nargin==5
        CurMaskBnd = bwboundaries(readimage(maskDS,ID));
    end
    
    [imheight,imwidth] = size(CurIm);
    maxdim = max([imheight imwidth]);
    imshow(CurIm,'InitialMagnification',500);
    if nargin==5
        hold on
        visboundaries(CurMaskBnd)
        hold off
    end
    
    % User input stuff. 
    UIKey = getkey;
    
    if ismember(char(UIKey),mappedKeys) % The user has pressed a valid key.
        % Store the key number and the label 
        stInd = ID-startID+1;
        
        LabelID(stInd,1) = str2double(char(UIKey));
        Labels{stInd,1} = categories{LabelID(stInd,1)};
        [~,imID{stInd,1}] = fileparts(imDS.Files{ID});
        
        ID = ID+1;
        
    elseif UIKey==8 % The user has pressed backspace. Step back one.
        ID = ID-1;
        
        if ID==0 % Catch the case where the user hits backspace on first image.
            ID=1;
        end
        
    elseif UIKey==27 % The user has pressed cancel. Terminate the loop.
        break
    end
end
close(f)
close(f2)
% Store data 
LDat.ImageID = imID;
LDat.Labels = Labels;
LDat.LabelID = LabelID;

end