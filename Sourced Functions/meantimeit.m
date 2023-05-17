function [meantime,sdtime] = meantimeit(testfun,reps)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

funtime = zeros(1,reps); 
for n=1:reps
    funtime(n) = timeit(testfun);
    pause
end

meantime = mean(funtime);
sdtime = std(funtime);

end

