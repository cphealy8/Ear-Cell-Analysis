clc;clear;close all;
load('SupportCellDat.mat')
RAW = imread('RAW.png');

CellProps = BBOrient(CellProps,imBB);

figure
OrientOverlay(RAW,CellProps)