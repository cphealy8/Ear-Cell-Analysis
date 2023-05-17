function [nrows, ncols] = squaresubplotdims(numplots)
%squaresubplotdims Given a number of plots, outputs the number of subplot
%rows (nrows) and subplot cols (ncols) that will produce a figure that is
%approximately square. 
%   Detailed explanation goes here
nrows = floor(sqrt(numplots));
ncols = ceil(numplots./nrows);
end

