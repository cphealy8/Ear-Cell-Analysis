RAW = imread('Data\RAW.png');
Control = ~imread('Data\RAW_HairCells.bmp');
Control = imclearborder(Control);

% Hyperparameters
initrate = 0.1;
decayRate = 0.5;
dropRate = 1;

%% Initialize
% % Parameters
% p.MedFilt=15;
% p.FlatField = 100;
% p.Thresh = 0.2;
% p.CLRads = 3;
% p.OPRads = 6;
% p.DILRads = 2;
% p.MinAvgI = 20;

% Parameters
p.MedFilt=100;
p.FlatField = 20;
p.Thresh = 0.6;
p.CLRads = 12;
p.OPRads = 5;
p.DILRads = 10;
p.MinAvgI = 50;


% Learning Rate and Iterator
nparams = length(fieldnames(p));
n=1;
LearningRate = SetLearningRate(initrate,'Step-Based','decay',0.5,'droprate',1,'iteration',n);
bestScore = 0;
randdir = true(nparams,1);

h=animatedline;

%% Learn
while true  
% Segment based upon current params
[~,ImDat] = SelectHairCell(RAW,'MedFilt',p.MedFilt,...
                                'FlatField',p.FlatField,...
                                'BWThresh',p.Thresh,...
                                'CloseRad',p.CLRads,...
                                'OpenRad',p.OPRads,...
                                'DilateRad',p.DILRads,...
                                'MinAvgInt',p.MinAvgI,...
                                'EllipApprox',false,...
                                'Suppress',true);
                            
segResult = ImDat.HairCellMask;

% Score Segmentation
Stats = SegCompare(Control,segResult);
newScore = Stats.F1Score;

%Preview Learning
addpoints(h,n,bestScore)
drawnow

% Update params according to score.
if newScore>bestScore % Segmentation Improved!
    % Keep Param direction
    [p,randdir] = UpdateParams(p,randdir.*LearningRate,...
                            'RandomizeDir',false,...
                            'RoundType',{'round'},...
                            'ForcePos',true);
    bestScore=newScore;
else % Segmentation got worse.XP
    % Randomize Param direction
    [p,randdir] = UpdateParams(p,LearningRate,'RoundType',{'round'},'ForcePos',true);
end

% Update Learning Rate
n=n+1;
[LearningRate] = SetLearningRate(initrate,'Step-Based','decay',0.8,'iteration',n,'droprate',5);
                     
end