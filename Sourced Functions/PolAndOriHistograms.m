function [] = PolAndOriHistograms(CellProps,sidedness)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
opt = {0.1, 0.1, 0.1};
subplot = @(m,n,p) subtightplot(m,n,p,opt{:});
if strcmp(sidedness,'Full')
    CellProps.NormOrientation = CellProps.NormOrientation;
elseif strcmp(sidedness,'Half')
    CellProps.NormOrientation = abs(CellProps.NormOrientation);
elseif strcmp(sidedness,'Quarter')
    CellProps.NormOrientation = wrapTo90(CellProps.NormOrientation);
else
    error('Invalid Sideness')
end

%%
nbins = ceil(pi*FDBins(CellProps.NormOrientation));

figure
% subplot(1,3,1)
% ph=polarhistogram(CellProps.NormOrientation*2*pi/360,nbins);
% ph.Normalization = 'probability';
% ph.FaceColor = 'm';
% title('Combined');

subplot(1,2,1)
ph=polarhistogram(CellProps.NormOrientation(CellProps.Type=='H')*2*pi/360,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'r';
title('Hair Cells');

subplot(1,2,2)
ph=polarhistogram(CellProps.NormOrientation(CellProps.Type=='S')*2*pi/360,nbins);
ph.Normalization = 'probability';
ph.FaceColor = 'c';
title('Support Cells');


sgtitle('Orientation Distribution')
%%
% nbins = 20;
nbins = ceil(FDBins(CellProps.CombinedPolarity));

comboCounts = histcounts(CellProps.CombinedPolarity,nbins);...
hairCounts = histcounts(CellProps.CombinedPolarity(CellProps.Type=='H'),nbins);
supportCounts = histcounts(CellProps.CombinedPolarity(CellProps.Type=='S'),nbins);

comboFreq = comboCounts./sum(comboCounts);
hairFreq = hairCounts./sum(hairCounts);
supportFreq = supportCounts./sum(supportCounts);

maxFreq = max([comboFreq hairFreq supportFreq]);



figure
% s1=subplot(1,3,1);
curdat = CellProps.CombinedPolarity;
reps = 200;
lwd=2;

% h1=histogram(curdat,nbins);
% h1.Normalization = 'probability';
% title('Combined');
% h1.FaceColor = 'm';
% xlabel('Magnitude of Polarity')
% ylim([0 maxFreq*1.1]);
% [NullP,~,NullX]=NullPolarity(curdat,nbins,reps);
% hold on
% plot(NullX,NullP,'-k','LineWidth',lwd)
% hold off


s2=subplot(1,2,1);
curdat = CellProps.CombinedPolarity(CellProps.Type=='H');
h2=histogram(curdat,nbins);
h2.Normalization = 'probability';
h2.FaceColor = 'r';
title('Hair Cells');
xlabel('Magnitude of Polarity')
ylim([0 maxFreq*1.1]);
[NullP,~,NullX]=NullPolarity(curdat,nbins,reps);
hold on
plot(NullX,NullP,'-k','LineWidth',lwd)
hold off


s3=subplot(1,2,2);
curdat = CellProps.CombinedPolarity(CellProps.Type=='S');
h3=histogram(curdat,nbins);
h3.Normalization = 'probability';
h3.FaceColor = 'c';
title('Support Cells');
xlabel('Magnitude of Polarity')
ylim([0 maxFreq*1.1]);
[NullP,~,NullX]=NullPolarity(curdat,nbins,reps);
hold on
plot(NullX,NullP,'-k','LineWidth',lwd)
hold off


maxFreq = max([h2.Values h3.Values])*1.1;
s1.YLim = [0 maxFreq];
s2.YLim = [0 maxFreq];
s3.YLim = [0 maxFreq];


sgtitle('Magnitude of Polarity Distribution')

end

function [NullMean,NullSD,nullx,NullCounts] = NullPolarity(data,nbins,reps)
    for k =1:reps
        ndatapts = length(data);
        RandData = sqrt(rand(1,ndatapts)); % Null probability
        [NullCounts(k,:),edges]=histcounts(RandData,nbins,'Normalization','Probability');
    end
    nullx = edges(1:end-1)+(diff(edges)/2);
    NullMean = mean(NullCounts);
    NullSD = std(NullCounts);
end
