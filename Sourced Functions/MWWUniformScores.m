function [W,SigLvl,stat] = MWWUniformScores(varargin)
%MWWUNIFORMSCORES compute the Mardia-Watson-Wheeler Uniform-Scores Test
%   [W,SigLVL] = MWWUNIFORMSCORES(a1,a2) tests whether the two groups of
%   sampled orientations, a1 and a2, specified as vectors, are drawn from 
%   the same distribution. If SigLVL = NS, accept the null hypothesis that
%   the samples are from the same distribution/population. If SigLVL=*, **,
%   or *** accept the alternative hypothesis, that the samples are from
%   different distributions at the indicated significance level. *=0.05,
%   **=0.01, ***=0.001; Stat stores the additional values that are used in
%   the calculation including the rank of each score.
%
%   MUST BE IN DEGREES
%
%   Author: Connor P. Healy, University of Utah, Dept. of Biomedical
%   Engineering.
%
%   SEE ALSO KSSTRUCT, RAYLEIGHTEST.
angs = varargin;
ngroups = length(angs);

stat = table;
try
    vec = cell2mat(angs);
catch
    vec = cell2mat(cellfun(@transpose,angs,'UniformOutput',0));
end
stat.Angles = vec(:);

if range(varargin{1})<=2*pi
    warning('Angle appears to be in radians. MWWUniformScores only accepts inputs in degrees')
end

N = length(stat.Angles);
group = [];
for n = 1:length(angs)
    gsamps(n) = length(angs{n});
    group = [group; ones(gsamps(n),1)*n];
end
stat.Group = group;

NaNRows = isnan(stat.Angles);
stat(NaNRows,:)=[];

stat = sortrows(stat);
stat.Tied = ~isunique(stat.Angles);
stat.Rank = ranknum(stat.Angles,5);
stat.CircularRank = 360*stat.Rank/N;
stat.CosCircRank = cosd(stat.CircularRank);
stat.SinCircRank = sind(stat.CircularRank);

for n =1:ngroups
    C(n) = sum(stat.CosCircRank(stat.Group==n));
    S(n) = sum(stat.SinCircRank(stat.Group==n));
end

W = sum(2*((C.^2+S.^2)./gsamps));

% ChiSq
degOfFreedom = 2*(ngroups-1);
alphas = [0.05 0.01 0.001];
critVals = chi2inv(1-alphas,degOfFreedom);

SigLvl = 'NS';
if W>critVals(1) && W<=critVals(2)
    SigLvl = '*';
elseif W>critVals(2) && W<=critVals(3)
    SigLvl = '**';
elseif W>critVals(3)
    SigLvl = '***';
end

end

