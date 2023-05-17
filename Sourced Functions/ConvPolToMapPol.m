function [CellProps] = ConvPolToMapPol(CellProps)
%CONVPOLTOMAPPOL convert polarity to mapped polarity based on
%CellProps.PolMap
%   Detailed explanation goes here
cellmult = @(x,y) x.*y;
    celladd = @(x,y) logical(x+y);
    cellmean = @(x,y) mean(y(x),'all','omitnan');
    
    HCells = CellProps(CellProps.Type=='H',:);
    SCells = CellProps(CellProps.Type=='S',:);
    
    getPol = @(x,y) mean(y(BWShrink2Pt(x)),'omitnan');
    
    HCellsBBCentMask = cellfun(@BWShrink2Pt, HCells.imBB,'UniformOutput',false);
    HCellsBBPol = cell2mat(cellfun(getPol,HCells.imBB,HCells.PolMap,'UniformOutput',false));
    HCellsFontPol = cell2mat(cellfun(getPol,HCells.imFont,HCells.PolMap,'UniformOutput',false));
%     HCellsBBPolb = cell2mat(cellfun(cellmean,HCells.imBB, HCells.PolMap,'UniformOutput',false));
%     HCellsFontPol = cell2mat(cellfun(cellmean,HCells.imFont, HCells.PolMap,'UniformOutput',false));
    HCells.CombinedPolarity = mean([HCellsBBPol HCellsFontPol],2,'omitnan'); % Combine these by averaging. 
    SCells.CombinedPolarity = cell2mat(cellfun(getPol,SCells.imBB, SCells.PolMap,'UniformOutput',false));
    
    % Recombine
    CellProps = [HCells;SCells];
end

