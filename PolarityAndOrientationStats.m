[file,path] = uigetfile('*.mat');
load(fullfile(path,file));

%% Rayleigh Test for Uniformity (must be in degrees)
pval = RayleighTest(CellProps.NormOrientation(CellProps.Type=="P12Support"));

%% Mardia Watson Williams
% Isolate desired values
a1 = CellProps.NormOrientationR(CellProps.Type=="P12Support");
a2 = CellProps.NormOrientationR(CellProps.Type=="P12Hair");

% Double Angles to correct account for bimodality
da1 = wrapTo2Pi(2*a1);
da2 = wrapTo2Pi(2*a2);

% Zero mean if non-uniform (a=0.05)
za1 = ZeroCircularDist(da1);
za2 = ZeroCircularDist(da2);
figure
polarhistogram(za1,32,'Normalization','Probability');
hold on
polarhistogram(za2,32,'Normalization','Probability');
hold off;

% Convert to Degrees
deg1 = za1*180/pi;
deg2 = za2*180/pi;

[M,lvl]=MWWUniformScores(deg1,deg2);
