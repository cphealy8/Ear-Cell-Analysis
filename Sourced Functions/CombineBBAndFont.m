function [CellProps] = CombineBBAndFont(CellProps,Threshold)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Add Extra columns for the combined data.
nCells = length(CellProps.ID);
CellProps.CombinedPolarity = NaN(nCells,1);
CellProps.CombinedOrientation = NaN(nCells,1);
CellProps.UserInput = false(nCells,1);

% Next assign the correct values for the observations that do not need to
% be consolidated
JustBB = CellProps.ID(CellProps.BBDetected & ~CellProps.FDetected);
CellProps.CombinedPolarity(JustBB) = CellProps.BBPolarity(JustBB);
CellProps.CombinedOrientation(JustBB) = CellProps.BBOrientation(JustBB);

JustF = CellProps.ID(CellProps.FDetected & ~CellProps.BBDetected);
CellProps.CombinedPolarity(JustF) = CellProps.FPolarity(JustF);
CellProps.CombinedOrientation(JustF) = CellProps.FOrientation(JustF);

% Reimpose Values for support cells
CellProps.CombinedPolarity(CellProps.Type=='S')= CellProps.BBPolarity(CellProps.Type=='S');
CellProps.CombinedOrientation(CellProps.Type=='S')= CellProps.BBOrientation(CellProps.Type=='S');
% Now identify the observations that need to be consolidated
NeedCons = CellProps.ID(CellProps.BBDetected & CellProps.FDetected);

% Isolate those observations;
SepProps = CellProps(NeedCons,:);

% Find the difference between the FOrientation and BBOrientatoin
DiffAngle = SepProps.BBOrientation-SepProps.FOrientation;
DiffAngle = wrapTo180(DiffAngle);

% Identify the observations that require user input

% Those who's fonticulus value is significantly different from their basal
% body value. 
NeedInput = find(abs(DiffAngle)>Threshold);
NeedAveraging =find(abs(DiffAngle)<=Threshold);

SepProps.CombinedPolarity(NeedAveraging) = mean([SepProps.BBPolarity(NeedAveraging) SepProps.FPolarity(NeedAveraging)],2);
SepProps.CombinedOrientation(NeedAveraging) = mean([SepProps.BBOrientation(NeedAveraging) SepProps.FOrientation(NeedAveraging)],2);

% Scroll through each observation that needs input, and get that input
NeedInputProps = SepProps(NeedInput,:);

numNeedInput = length(NeedInput); 
percNeedInput = 100*numNeedInput/nCells;

boxmsg = sprintf('%d cells (%0.1f%% of population) appear to be incorrectly segmented. Would you like to manually correct them?',numNeedInput,percNeedInput);

fig = uifigure;
selection = uiconfirm(fig,boxmsg,'Segmentation Correction',...
    'Options',{'Correct Cells','Omit Cells'});
close(fig)
switch selection
    case 'Correct Cells'
        [NeedInputProps] = VCellManAnnot(NeedInputProps,'manual');
    case 'Omit Cells'
        [NeedInputProps] = VCellManAnnot(NeedInputProps,'ignore');
end
        SepProps(NeedInput,:) = NeedInputProps;
        CellProps(NeedCons,:) = SepProps;
end

