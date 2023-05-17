function [CellProps,omitIDs,omitType] = Masks2CtrPolOri(CellProps)
%MASKS2CTRPOLORI get visual center, polarity, and orientation of cell using
%individual masks of cell and associated polar body. 
%   Detailed explanation goes here

%% Define Anonymous functions used in this code
getCenter = @(x) BWVisualCenter(x);
detectPB = @(x) sum(x,'all')>0;
getCentroid = @(x) findCentroid(x);
getNum = @(x) numBWComps(x);
getPol = @(x,y) mean(y(BWShrink2Pt(x)),'omitnan');
    
%% Compute Visual Centers
% The visual center is different from the centroid. 
CellProps.LocalCenter = cell2mat(cellfun(getCenter,CellProps.Mask,'UniformOutput',false));
CellProps.Center = CellProps.LocalCenter+[CellProps.colshift CellProps.rowshift];

%% Polar Body Filtration
% Count number of polar bodies in polar body mask. 
NumPB = cell2mat(cellfun(getNum,CellProps.PBMask,'UniformOutput',false));

% Omit cells that do not have exactly one polar body.
omitted=NumPB~=1;
omitIDs = CellProps.ID(omitted);
omitType = CellProps.Type(omitted);
CellProps(omitted,:)=[];

%% Compute Orientation and related parameters;
CellProps.PBLocalCentroid = cell2mat(cellfun(getCentroid,CellProps.PBMask,'UniformOutput',false));
CellProps.PBCentroid = CellProps.PBLocalCentroid + [CellProps.colshift CellProps.rowshift];

% Components of vector connecting cell center to centroid of PB. 
CellProps.PBX = CellProps.PBLocalCentroid(:,1)-CellProps.LocalCenter(:,1);
CellProps.PBY = CellProps.PBLocalCentroid(:,2)-CellProps.LocalCenter(:,2);

% Distance between polar body and cell center
CellProps.CTRPBDist = sqrt((CellProps.PBX).^2+(CellProps.PBY).^2);
CellProps.Orientation = atan2d(-CellProps.PBY,CellProps.PBX);

%% Compute Polarity from Polarity Map
CellProps.Polarity = cell2mat(cellfun(getPol,CellProps.PBMask,CellProps.PolMap,'UniformOutput',false));
end