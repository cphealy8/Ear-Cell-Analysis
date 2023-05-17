function [StatTab] = KSStruct(x,CDF,CDFType)
%Perform Kolmogorov Smirnov test between the CDFs.
%   Detailed explanation goes here

[xcombo,intCDFs] = InterpCDFs(x,CDF);

CDFs = struct2cell(intCDFs);
fields = fieldnames(intCDFs);

nDists = length(CDFs);
DistIDMat = nchoosek(1:nDists,2);
IDA = DistIDMat(:,1);
IDB = DistIDMat(:,2);

% Distribution Names
DistNameA = fields(IDA);
DistNameB = fields(IDB);
AType = CDFType(IDA)'; 
BType = CDFType(IDB)'; 

% Distributions (Interpolated)
DistA = CDFs(IDA);
DistB = CDFs(IDB);

% Sample Sizes
DistSamps = cellfun('length',struct2cell(CDF));
ASamps = DistSamps(IDA);
BSamps = DistSamps(IDB); 

% KS Stat
nrow = length(IDA);
for n = 1:nrow
    [KS(n) maxLocation(n)] = max(abs(DistA{n} - DistB{n}));
end
KS = KS';
maxLocation = xcombo(maxLocation);


SampleConstant = zeros(nrow,1);
bothE = strcmp(AType,BType);
SampleConstant(bothE) = sqrt((ASamps(bothE)+BSamps(bothE))./(ASamps(bothE).*BSamps(bothE)));
AisT = strcmp(AType,'T');
SampleConstant(AisT) = sqrt(1./BSamps(AisT));
BisT = strcmp(BType,'T');
SampleConstant(BisT) = sqrt(1./BSamps(BisT));


SigLvls = [0.05 0.01 0.001];
AlphaValue = sqrt(-0.5*log(SigLvls));


CritValue = SampleConstant.*AlphaValue;

TestResults = KS>CritValue;
SigID = sum(TestResults,2)+1;

SigSymbols ={'ns';'*';'**';'***'};

Significance = SigSymbols(SigID);

StatTab = table(DistNameA,DistNameB,DistA,DistB,ASamps,BSamps,KS,maxLocation,Significance);
end

