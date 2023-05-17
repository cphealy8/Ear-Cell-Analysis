function [TypeID,ntypes,types] = GetTypeIDs(PropsTab,SplitField)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
types = unique(PropsTab.Type);
ntypes = length(types);

for k=1:ntypes
    TypeID{k} = PropsTab.(SplitField)==types{k};
end

end