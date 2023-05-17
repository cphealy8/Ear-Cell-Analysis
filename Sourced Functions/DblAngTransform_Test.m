clc; clear; close all;

angs = [0 15 30 45 60 75 90 180 195 210 225 240 255 270];
freq = [15 25 35 45 35 25 15 15 25 35 45 35 25 15];

angD = repelem(angs,freq);
dblAngD = DblAngTransform(angD,'deg');

subplot(1,2,1)
polarhistogram(deg2rad(angD),72);
title('Original - Diametrically Bimodal')
subplot(1,2,2)
polarhistogram(deg2rad(dblAngD),72);
title('After Double Angle Transformation')
