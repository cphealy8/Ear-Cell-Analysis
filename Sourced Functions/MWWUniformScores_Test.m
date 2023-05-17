angs{1} = [35 45 50 55 60 70 85 95 105 120];
angs{2} = [75 80 90 100 110 130 135 140 150 160 165];

ngroups = length(angs);

stat = table;
stat.Angles = cell2mat(angs)';
N = length(stat.Angles);
group = [];
for n = 1:length(angs)
    gsamps(n) = length(angs{n});
    group = [group; ones(gsamps(n),1)*n];
end
stat.Group = group;

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

[W,SigLvl,stat] = MWWUniformScores(angs{1},angs{2});
