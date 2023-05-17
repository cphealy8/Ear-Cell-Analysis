function [] = OrientationMaps(CellProps,ImDat,clrMap)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%% Hair Cell Orientation
figure
data = CellProps.NormOrientationR(CellProps.Type=='H');
try
    bwIm = ImDat.HairCellMask;
    [datmap,fH,axH] = DataMap(bwIm,abs(data));
catch
    bwIm = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='H',:));
    [datmap,fH,axH] = DataMap(bwIm,abs(data));
end

colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;
caxis([0 180])

ylabel(cbar,'Orientation with Respect to Utricular Boundary');
title('Hair Cell Orientation')

%% Hair Cell Orientation Blurred
% figure
% data = CellProps.NormOrientation(CellProps.Type=='H');
% bwIm = ImDat.HairCellMask;
% 
% [datmap,fH,axH] = DataMap(bwIm,abs(data),'BlurType','Disk','BlurValue',70);
% colormap(flipud(brewermap([],clrMap)))
% cbar= colorbar;
% caxis([0 180])
% 
% ylabel(cbar,'Orientation with Respect to Utricular Boundary');
% title('Hair Cell Orientation Blurred')

%% Support Cell Orientation
figure
data = CellProps.NormOrientationR(CellProps.Type=='S');
try
    bwIm = ImDat.SupportCellMask;
    [datmap,fH,axH] = DataMap(bwIm,abs(data));
catch
    bwIm = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='S',:));
    [datmap,fH,axH] = DataMap(bwIm,abs(data));
end
    
colormap(flipud(brewermap([],clrMap)))
cbar= colorbar;
caxis([0 180])

ylabel(cbar,'Orientation with Respect to Utricular Boundary');
title('Support Cell Orientation')

%% Support Cell Orientation
% figure
% data = CellProps.NormOrientation(CellProps.Type=='S');
% bwIm = ImDat.SupportCellMask;
% 
% [datmap,fH,axH] = DataMap(bwIm,abs(data),'BlurType','Disk','BlurValue',70);
% colormap(flipud(brewermap([],clrMap)))
% cbar= colorbar;
% caxis([0 180])
% 
% ylabel(cbar,'Orientation with Respect to Utricular Boundary');
% title('Support Cell Orientation Blurred')
end

