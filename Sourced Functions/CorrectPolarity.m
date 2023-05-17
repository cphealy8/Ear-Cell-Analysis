function [CellProps] = CorrectPolarity(CellProps)
%CORRECTPOLARITY Correct or omit polarities greater than 1. 
%   Detailed explanation goes here
incorrectMIPID = CellProps.CombinedPolarity>1;
incorrectMIPDat = CellProps(incorrectMIPID ,:);

if ~isempty(incorrectMIPDat)
    
numNeedInput = sum(incorrectMIPID); 
percNeedInput = 100*numNeedInput/height(CellProps);

boxmsg = sprintf('%d cells (%0.1f%% of population) have polarities that exceed 1. Would you like to manually correct them?',numNeedInput,percNeedInput);

fig = uifigure;
selection = uiconfirm(fig,boxmsg,'Polarity Correction',...
    'Options',{'Correct Cells','Omit Cells'});
close(fig)

switch selection
    case 'Correct Cells'
        [correctMIPDat] = VCellManAnnot(incorrectMIPDat,'manual');
    case 'Omit Cells'
        [correctMIPDat] = VCellManAnnot(incorrectMIPDat,'ignore');
end
CellProps(incorrectMIPID,:) = correctMIPDat;
CellProps.CombinedPolarity(CellProps.CombinedPolarity>1)= NaN;
end

end

