function [SigLvl,pval,D] = NullPolKSTest(data)
%NULLPOLKSTEST Tests the hypothesis that polarity data (data) is from the
%null polarity distribution
%   Detailed explanation goes here

p = sort(data);
[~,pval,D] = kstest(p,'CDF',[p p.^2]);

if pval<0.05
    SigLvl="*";
    
    if pval<0.01
        SigLvl = "**";
        
        if pval<0.001
            SigLvl = "***";
        end
        
    end
    
elseif pval>0.05
    SigLvl = "NS";
end

end

