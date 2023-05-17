function [CellProps] = addFonticulusVals(CellProps,varargin)
%ADDFONTICULUSVALS Summary of this function goes here
%   Detailed explanation goes here
nCells = length(CellProps.Area);

if ~isempty(varargin)
    CellProps.FDetected = CellProps.BBDetected;
    CellProps.FArea = CellProps.BBArea;
    CellProps.FLocalCentroid = CellProps.BBLocalCentroid;
    CellProps.FX = CellProps.BBX;
    CellProps.FY = CellProps.BBY;
    CellProps.FCentroid = CellProps.BBCentroid;
    CellProps.FOrientation = CellProps.BBOrientation;
    CellProps.FDistance = CellProps.BBDistance;
    CellProps.FEdgeDist = CellProps.BBEdgeDist;
    CellProps.FPolarity = CellProps.BBPolarity;
    CellProps.imFont = imBB;
else
    CellProps.FDetected = zeros(nCells,1);
    CellProps.FArea = NaN(nCells,1);
    CellProps.FLocalCentroid = NaN(nCells,2);
    CellProps.FX = NaN(nCells,1);
    CellProps.FY = NaN(nCells,1);
    CellProps.FCentroid = NaN(nCells,2);
    CellProps.FOrientation = NaN(nCells,1);
    CellProps.FDistance = NaN(nCells,1);
    CellProps.FEdgeDist = NaN(nCells,1);
    CellProps.FPolarity = NaN(nCells,1);
    CellProps.imFont = cell(nCells,1);
end
end

