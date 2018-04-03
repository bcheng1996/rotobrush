function [outWindows] = getShapeModel(inWindows,wSize)
%GETSHAPEMODEL Summary of this function goes here
%   Detailed explanation goes here
%%
windows = inWindows;
for i=1:size(windows,2)
    bw = windows{i}.EdgeBoundary;
    [D IDX] = bwdist(bw);
    Wc = exp(-(D.^2)/(wSize/8)^2);
    Fs = 1 - Wc;
    windows{i}.ShapeModel = Fs;
end
outWindows=windows;
end

