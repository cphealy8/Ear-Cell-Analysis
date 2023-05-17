function [K,Ori,KsimMax,KsimMin,name] = AngleKTypeComp(scales,props,splitvar)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

[TypeID,ntypes,types] = GetTypeIDs(props,splitvar);

for k =1:ntypes
    hvec{k}.origin = props.Center(TypeID{k},:);
    hvec{k}.angle = props.OrientationR(TypeID{k});
    hvec{k}.magnitude = ones(sum(TypeID{k}),1);
end

% Compute AngleK stats 
alpha = 0.01;

for n=1:ntypes
    for m=1:ntypes
        [K{n,m},Ori{n,m}] = AngleK(scales,hvec{n},hvec{m}); 
        [~,KsimMax{n,m},KsimMin{n,m}] = AngleK_Env(scales,hvec{n},alpha,'vecB',hvec{m});
        name{n,m} = strcat(types{n},'To',types{m});
    end
end

% reshape to column array
shapmat = [ntypes.^2 1];
K = reshape(K,shapmat);
Ori = reshape(Ori,shapmat);
KsimMax = reshape(KsimMax,shapmat);
KsimMin = reshape(KsimMin,shapmat);
name = reshape(name,shapmat);
end

