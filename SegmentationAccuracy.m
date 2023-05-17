clc;clear;close all;

addpath('Source Images')
addpath('Sourced Functions')
addpath('Data')
addpath('Results')

[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

nanrows = isnan(CellProps.CombinedOrientation);
CellProps(nanrows,:)=[];

%%
ControlBB = ~imread('Data\RAW_BasalBodies.bmp');
ControlHair = imclearborder(~imread('Data\RAW_HairCells.bmp'));
ControlSupport = imclearborder(~imread('Data\RAW_SupportCells.bmp'));

testHairBB = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='H',:),'ImField','imBB');
testHairFont = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='H',:),'ImField','imFont');
testSuppBB = BuildMask(ImDat.HairCellMask,CellProps(CellProps.Type=='S',:),'ImField','imBB');
testHair = ImDat.HairCellMask;
testSupport = ImDat.SupportCellMask;

ComboHair = logical(ControlHair+testHair);
ComboSupport = logical(ControlSupport+testSupport);

ControlHairBB = ControlBB.*testHair;
ControlSupportBB = ControlBB.*testSupport;
%% Compare
figure
AccuMap(ControlHair,testHair);
title('Hair Cell Segmentation');

figure
AccuMap(ControlSupport,testSupport);
title('Support Cell Segmentation');

figure
AccuMap(ControlHairBB,testHairBB,ComboHair);
title('Hair Cell BB Segmentation');

figure
AccuMap(ControlHairBB,testHairFont,ComboHair);
title('Hair Cell Fonticulus Segmentation');

figure
AccuMap(ControlSupportBB,testSuppBB,ComboSupport);
title('Support Cell BB Segmentation');
