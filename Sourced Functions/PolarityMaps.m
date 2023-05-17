function [] = PolarityMaps(CellProps,ImDat,clrMap)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Hair Cell Polarity
figure
data = CellProps.CombinedPolarity(CellProps.Type=='H');
try
    bwIm = ImDat.HairCellMask;
    [datmap,fH,axH] = DataMap(bwIm,data);
catch
    bwIm = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='H',:));
    [datmap,fH,axH] = DataMap(bwIm,abs(data));
end

colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity');
title('Hair Cell MIP')

%% Hair Cell Polarity Blurred
% data = CellProps.CombinedPolarity(CellProps.Type=='H');
% bwIm = ImDat.HairCellMask;

% [datmap,fH,axH] = DataMap(bwIm,data,'Disk',70); 
% colormap(flipud(brewermap([],clrMap)))
% cbar= colorbar;
% 
% ylabel(cbar,'Magnitude of Intracellular Polarity (Blurred)');
% title('Hair Cell MIP Blurred')
%% Support Cell Polarity
figure
    data = CellProps.CombinedPolarity(CellProps.Type=='S');
try
    bwIm = ImDat.SupportCellMask;
    [datmap,fH,axH] = DataMap(bwIm,data);
catch
    bwIm = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='S',:));
    [datmap,fH,axH] = DataMap(bwIm,abs(data));
end



colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;

ylabel(cbar,'Magnitude of Intracellular Polarity');
title('Support Cell MIP')
%% Support Cell Polarity Blurred
% data = CellProps.CombinedPolarity(CellProps.Type=='S');
% bwIm = ImDat.SupportCellMask;

% [datmap,fH,axH] = DataMap(bwIm,data,'Disk',70);
% colormap(flipud(brewermap([],clrMap)))
% cbar= colorbar;
% 
% ylabel(cbar,'Magnitude of Intracellular Polarity');
% title('Support Cell MIP Blurred')
end

