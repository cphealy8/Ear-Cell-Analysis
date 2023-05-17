function [] = interpCDFPlot(combinedX,intCDFs,plottype)


%%
figure
lwd = 2; 
switch plottype
    case 'xy'
        plot(combinedX,intCDFs.Uniform,'--k','LineWidth',lwd)
        hold on
        plot(combinedX,intCDFs.Combined,'-m','LineWidth',lwd)
        plot(combinedX,intCDFs.Hair,'-r','LineWidth',lwd)
        plot(combinedX,intCDFs.Support,'-c','LineWidth',lwd)


        xlim([-180 180])
        xlabel('Orientation')
        ylabel('Cumulative Probability')
    case 'polar'
        combinedX = combinedX*2*pi/360;
        polarplot(combinedX,intCDFs.Uniform,'--k','LineWidth',lwd)
        hold on
        polarplot(combinedX,intCDFs.Combined,'-m','LineWidth',lwd)
        polarplot(combinedX,intCDFs.Hair,'-r','LineWidth',lwd)
        polarplot(combinedX,intCDFs.Support,'-c','LineWidth',lwd)
end

legend('Uniform','Full Population','Hair Cells','Support Cells')
end

