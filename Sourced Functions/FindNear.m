function [nearval,idx] = FindNear(tgt,values)
%FINDNEAR find nearest value (tgt) within an array of values (values). 
%   Detailed explanation goes here

nearvals = interp1(values,values,tgt,'previous');
nearval = nearvals(1);
ids = 1:length(values);
idx = ids(values==nearval);
end

