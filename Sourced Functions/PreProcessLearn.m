 function [bestScale,bestSNRatio,bestIm] = PreProcessLearn(rawimage,target)
%PREPROCESSLEARN Learn the best pre-processing settings
%   Detailed explanation goes here

scale = 20;
bestScale = scale; 
pIm = ImagePreProcess(rawimage,scale);
SNRatio = SigToNoise(pIm,target);
bestSNRatio = SNRatio;
dir =1;
n=0;
preJump = NaN;
while true
    n=n+1;
    
    % Try one direction
    Jump = dir*ceil(SetLearningRate(20,'Time-Based','decay',0.5,'iteration',n));
    if abs(Jump)>=abs(preJump)
        Jump = (abs(preJump)-1)*sign(Jump);
    end
    scale = bestScale+Jump;
    if scale<=0
        scale=1;
    end
    pIm = ImagePreProcess(rawimage,scale);
    SNRatio = SigToNoise(pIm,target);
    change = SNRatio-bestSNRatio;

% If the first direction didnt work try the opposite direction
if change<0
    dir = -1*dir;
    Jump = dir*Jump;
    scale = bestScale+Jump;
    if scale<=0
        scale = 1;
    end
    pIm = ImagePreProcess(rawimage,scale);
    SNRatio = SigToNoise(pIm,target);
    change = SNRatio-bestSNRatio;
end

% If the change improved the Signal to noise ratio, update it. 
if change>0
    bestSNRatio = SNRatio;
    bestScale = scale;
end
preJump = Jump; 

% Termination conditions
if abs(Jump)==1 && change<0
    break
end
    %%     n=n+1;
%     LearningRate = ceil(SetLearningRate(LearningRate,'Time-Based','decay',0.1,'iteration',n));
%     scale(n) = bestScale+LearningRate;
%     pIm = ImagePreProcess(rawimage,scale(n));
%     
%     % compare to target
%     SNRatio(n) = SigToNoise(pIm,target);
%     
%     if SNRatio(n)>bestSNRatio
%         bestScale = scale(n);
%         bestSNRatio = SNRatio(n);
%         bestIm = pIm;
%         nfail = 0;
%     else
%         nfail = nfail+1;
%     end
%     
%     % termination conditions
%     if nfail>=buffer
%         break
%     end
    
end

bestIm = pIm;
end

function SNRatio = SigToNoise(image,mask)
image = double(image);
mask = double(mask);

totpix = sum(image(:));
Signal = image.*mask;
totsignal = sum(Signal(:));

SNRatio = totsignal/(totpix-totsignal);
end

