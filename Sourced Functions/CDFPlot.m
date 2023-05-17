function [CDF,x] = CDFPlot(CellProps,Variable,type,transform)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

HairID = CellProps.Type=='H';
SupportID = CellProps.Type=='S';

switch Variable
    case 'Polarity'
        y = CellProps.CombinedPolarity;
    case 'Orientation'
        y = CellProps.NormOrientation;
end

[cf,cx] = ecdf(y);
[hf,hx] = ecdf(y(HairID));
[sf,sx] = ecdf(y(SupportID));

switch Variable
    case 'Polarity'
        nullc = cx.^2;
        nullh = hx.^2;
        nulls = sx.^2;
    case 'Orientation'
        nullc = (cx+180)./(360);
        nullh = (hx+180)./(360);
        nulls = (sx+180)./(360);
end

ylab = 'Cumulative Probability';

if strcmp(transform,'FoldDifference')
    cf = cf./nullc-1;
    hf = hf./nullh-1;
    sf = sf./nulls-1;
    nullc = nullc./nullc -1;
    
    % Remove divide by zero errors
    n = 1:10;
    cf(n) = [];
    cx(n)= [];
    hf(n) = [];
    hx(n)= [];
    sf(n) = [];
    sx(n)= [];
    nullc(n) = [];
    
    ylab = 'Cumulative Probability (Fold Difference vs. Null)';
end


figure
lwd =2;
switch type
    case 'xy'
        plot(cx,nullc,':k','LineWidth',lwd)
        hold on
        plot(cx,cf,'-m','LineWidth',lwd)
        plot(hx,hf,'-r','LineWidth',lwd);
        plot(sx,sf,'-c','LineWidth',lwd);
        xlabel(Variable);
        ylabel('Cumulative Probability');
        legend('Null','Full Population','Hair Cells','Support Cells')
        axis tight
    case 'polar'
        polarplot(deg2rad(cx),nullc,':k','LineWidth',lwd)
        hold on
        polarplot(deg2rad(cx),cf,'-m','LineWidth',lwd)
        polarplot(deg2rad(hx),hf,'-r','LineWidth',lwd);
        polarplot(deg2rad(sx),sf,'-c','LineWidth',lwd);
        
        legend('Null','Full Population','Hair Cells','Support Cells')
end

%% Store and output vars
x.Combined = cx;
x.Hair = hx;
x.Support = sx;
x.Uniform = cx;

CDF.Combined = cf;
CDF.Hair = hf;
CDF.Support = sf;
CDF.Uniform = nullc;
end



